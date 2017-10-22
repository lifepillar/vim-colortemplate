" vim: foldmethod=marker nowrap
"
" Grammar {{{
" <Template>                  ::= <Line>*
" <Line>                      ::= <EmptyLine> | <Comment> | <KeyValuePair> | <HiGroupDef> | <VerbatimText>
" <Comment>                   ::= # .*
" <KeyValuePair>              ::= <ColorDef> | <Key> : <Value>
" <Key>                       ::= Full name | Short name | Author | Background | ...
" <Value>                     ::= .*
" <ColorDef>                  ::= Color : <ColorName> <GUIValue> <Base256Value> <Base16Value>
" <ColorName>                 ::= [a-z1-9_]+
" <GUIValue>                  ::= <HexValue> | <RGBValue>
" <HexValue>                  ::= #[a-f0-9]{6}
" <RGBValue>                  ::= rgb ( <8BitNumber> , <8BitNumber> , <8BitNumber> )
" <Base256Value>              ::= <8BitNumber> | <StandardColorName> | ' <StandardCompoundColorName> '
" <8BitNumber>                ::= 0 | 1 | ... | 255
" <StandardColorName>         ::= AliceBlue | AntiqueWhite | ...
" <StandardCompoundColorName> ::= alice blue | antique white | ...
" <Base16Value>               ::= 0 | 1 | ... | 15 | Black | DarkRed | ...
" <HiGroupDef>                ::= <LinkedGroup> | <BaseGroup>
" <LinkedGroup>               ::= <HiGroupName> -> <HiGroupName>
" <BaseGroup>                 ::= <HiGroupName> <FgColor> <BgColor> <Attributes>
" <FgColor>                   ::= <ColorName> | <ColorName> / <ColorName>
" <BgColor>                   ::= <ColorName> | <ColorName> / <ColorName>
" <Attributes>                ::= <StyleDef>*
" <StyleDef>                  ::= t[term] = <AttrList> | g[ui] = <AttrList> | guisp = <ColorName> | s = <ColorName> | <AttrList>
" <AttrList>                  ::= <Attr> [, <AttrList]
" <Attr>                      ::= bold | italic | reverse | inverse | underline | ...
" }}}

" Internal state {{{

" Template data
let s:template = {
      \ 'path': '',
      \ 'data': [],
      \ 'linenr': -1,
      \ 'numlines': 0
      \ }

fun! s:template.load(path) dict
  let self.path = a:path
  let self.data = readfile(fnameescape(a:path))
  let self.numlines = len(self.data)
  let self.linenr = -1
  call setloclist(0, [], 'r')
endf

" Get current line
fun! s:template.getl() dict
  return self.data[self.linenr]
endf

fun! s:template.next_line() dict
  let self.linenr += 1
  call s:token.reset()
  return self.linenr < self.numlines
endf

fun! s:template.add_error(msg)
  call setloclist(0, [{'filename': self.path,
        \              'lnum'    : self.linenr + 1,
        \              'col'     : s:token.pos + 1,
        \              'text'    : a:msg,
        \              'type'    : 'E'
        \            }], 'a')
endf

fun! s:template.add_warning(msg)
  call setloclist(0, [{'filename': self.path,
        \              'lnum'    : self.linenr + 1,
        \              'col'     : s:token.pos + 1,
        \              'text'    : a:msg,
        \              'type'    : 'W'
        \            }], 'a')
endf

" Current token in the currently parsed line
let s:token = {
      \ 'pos'  :  0,
      \ 'value': '',
      \ 'kind' : ''
      \ }

fun! s:token.reset() dict
  let self.pos = 0
  let self.value = ''
  let self.kind = ''
endf

fun! s:token.next() dict
  let [l:char, _, self.pos] = matchstrpos(s:template.getl(), '\s*\zs.', self.pos) " Get first non-white character starting at pos
  if empty(l:char)
    let self.kind = 'EOL'
  elseif l:char =~? '\a'
    let [self.value, _, self.pos] = matchstrpos(s:template.getl(), '\w\+', self.pos - 1)
    let self.kind = 'WORD'
  elseif l:char =~# '[0-9]'
    let [self.value, _, self.pos] = matchstrpos(s:template.getl(), '\d\+', self.pos - 1)
    let self.kind = 'NUM'
  elseif l:char =~# "[:=().#,'->/]"
    let self.value = l:char
    let self.kind = l:char
  else
    throw 'Invalid token'
  endif
  return self
endf

fun! s:token.peek() dict
  let l:token = copy(self)
  return l:token.next()
endf

fun! s:init()
  let g:colortemplate_exit_status = 0
  let s:use16colors               = get(g:, 'base16template', 0)
  let s:info                      = {}        " General information
  let s:background                = ''        " Current background
  let s:uses_background           = { 'dark': 0, 'light': 0 }
  let s:verbatim                  = 0 " When set to 1, source is copied (almost) verbatim

  " A palette is a dictionary of color names and their definitions.
  " Each definition consists of a GUI color value, a base-256 color value and
  " a base-16 color value (in this order). Base-16 color values are used
  " instead of base-256 values when g:colortemplate_use16 is set to 1.
  let s:palette                  = {
        \                           'none': ['NONE', 'NONE', 'NONE'],
        \                           'fg':   ['fg',   'fg',   'fg'  ],
        \                           'bg':   ['bg',   'bg',   'bg'  ]
        \ }

  " Dictionary to store highlight group definitions. Definitions for dark and
  " light background are kept distinct. Besides, for each background type, we
  " distinguish among (a) definitions that must be applied only when the
  " background is opaque, (b) definitions that must be applied only when the
  " background is transparent, and (c) definitions that apply unconditionally.
  let s:hi_group                 = {}
  let s:hi_group['dark']         = { 'opaque': [], 'transp': [], 'any': [] }
  let s:hi_group['light']        = { 'opaque': [], 'transp': [], 'any': [] }

  let s:normal_group_defined = { 'dark': 0, 'light': 0 }
endf
" }}} Internal state

" Helper functions {{{
" Verify that a color name has been defined before it is used.
fun! s:is_undefined_color(color)
  return !has_key(s:palette, a:color)
endf

" Add or override a color definition
fun! s:add_color(name, gui, base256, base16)
  if a:name ==? 'none' || a:name ==? 'fg' || a:name ==? 'bg'
    throw "Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden"
  endif
  let s:palette[a:name] = [a:gui, a:base256, a:base16]
endf

" Store a line to send to the output.
" scope must be 'opaque', 'transp', or 'any'.
" definition is the line as it should appear in the output.
fun! s:add_line(scope, definition)
  call add(s:hi_group[s:background][a:scope], a:definition)
endf

" Store a generic key-value pair
fun! s:add_info(key, value)
  let s:info[a:key] = a:value
endf

" Return a highlight group definition as a String.
"
" group: the name of the highlight group
" fg: the name of the foreground color for the group
" bg: the name of the background color for the group
" guisp: the name of the special color
" cterm: a list of term attributes
" gui: a list of gui attributes
"
" Color names are as specified in the color palette of the template.
fun! s:hlstring(group, fg, bg, guisp, cterm, gui)
  return join([
        \ 'hi', a:group,
        \ 'ctermfg='   . s:palette[a:fg][s:use16colors ? 2 : 1],
        \ 'ctermbg='   . s:palette[a:bg][s:use16colors ? 2 : 1],
        \ 'guifg='     . s:palette[a:fg][0],
        \ 'guibg='     . s:palette[a:bg][0],
        \ 'guisp='     . get(s:palette, a:guisp, ['NONE'])[0],
        \ 'cterm=NONE' . (empty(a:cterm) ? '' : ',' . join(a:cterm, ',')),
        \ 'gui=NONE'   . (empty(a:gui)   ? '' : ',' . join(a:gui,   ','))
        \ ])
endf

" Returns a string containing a highlight group definition.
fun! s:build_hi_group_def(hi_group)
  if has_key(a:hi_group, 'tfg') || has_key(a:hi_group, 'tbg') || has_key(a:hi_group, 'tsp')
    call s:add_line('opaque', s:hlstring(
          \                           a:hi_group['name'],
          \                           a:hi_group['fg'],
          \                           a:hi_group['bg'],
          \                           a:hi_group['sp'],
          \                           a:hi_group['cterm'],
          \                           a:hi_group['gui']
          \ ))
    call s:add_line('transp', s:hlstring(
          \                           a:hi_group['name'],
          \                           get(a:hi_group, 'tfg', a:hi_group['fg']),
          \                           get(a:hi_group, 'tbg', a:hi_group['bg']),
          \                           get(a:hi_group, 'tsp', a:hi_group['sp']),
          \                           a:hi_group['cterm'],
          \                           a:hi_group['gui']
          \ ))
  else
    call s:add_line('any', s:hlstring(
          \                           a:hi_group['name'],
          \                           a:hi_group['fg'],
          \                           a:hi_group['bg'],
          \                           a:hi_group['sp'],
          \                           a:hi_group['cterm'],
          \                           a:hi_group['gui']
          \ ))
  endif
endf

fun! s:add_linked_group_def(src, tgt)
  call add(s:hi_group[s:background]['any'], 'hi! link ' . a:src . ' ' . a:tgt)
endf
" }}} Helper functions

" Parser {{{
fun! s:parse_verbatim_line()
  if s:token.next().kind ==? 'endverbatim'
    let s:verbatim = 0
    if s:token.next().kind !=# 'EOL' && s:token.kind !=# '#'
      throw "Extra characters after 'endverbatim'"
    endif
  else
    try " to interpolate colors
      let l:line = substitute(s:template.getl(), '\(term[bf]g=\)@\(\w\+\)', '\=submatch(1).s:palette[submatch(2)][s:use16colors ? 2 : 1]', 'g')
      let l:line = substitute(l:line, '\(gui[bf]g=\|guisp=\)@\(\w\+\)', '\=submatch(1).s:palette[submatch(2)][0]', 'g')
    catch /.*/
      throw 'Undefined color'
    endtry
    call s:add_line('any', l:line)
  endif
endf

fun! s:parse_line()
  if s:token.next().kind ==# 'EOL' " Empty line
    return
  elseif s:token.kind ==# '#'
    return s:parse_comment()
  elseif s:token.kind ==# 'WORD'
    if s:token.value ==? 'verbatim'
      let s:verbatim = 1
      if s:token.next().kind !=# 'EOL' && s:token.kind !=# '#'
        throw "Extra characters after 'verbatim'"
      endif
    elseif s:template.getl() =~? ':' " Look ahead
      call s:parse_key_value_pair()
    else
      call s:parse_hi_group_def()
    endif
  else
    throw 'Unexpected token at start of line'
  endif
endf

fun! s:parse_comment()
  " Nothing to do here
endf

fun! s:parse_key_value_pair()
  if s:token.value ==? 'Color'
    call s:parse_color_def()
  else " Generic key-value pair
    let l:key_tokens = [s:token.value]
    while s:token.next().kind !=# ':'
      if s:token.kind !=# 'WORD'
        throw 'Only alphanumeric characters are allowed in keys'
      endif
      call add(l:key_tokens, s:token.value)
    endwhile
    let l:key = tolower(join(l:key_tokens))
    let l:value = matchstr(s:template.getl(), '\s*\zs.*$', s:token.pos)
    if l:key ==# 'background'
      if l:value =~? '^dark\s*$'
        let s:background = 'dark'
      elseif l:value =~? '^light\s*$'
        let s:background = 'light'
      else
        throw 'Background can only be dark or light.'
      endif
    else
      call s:add_info(l:key, l:value)
    endif
  endif
endf

fun! s:parse_color_def()
  if s:token.next().kind !=# ':'
    throw 'Expected colon after Color keyword'
  endif
  let l:colorname = s:parse_color_name()
  let l:col_gui   = s:parse_gui_value()
  let l:col_256   = s:parse_base_256_value()
  let l:col_16    = s:parse_base_16_value()
  call s:add_color(l:colorname, l:col_gui, l:col_256, l:col_16)
endf

fun! s:parse_color_name()
  if s:token.next().kind !=# 'WORD'
    throw 'Invalid color name'
  endif
  return s:token.value
endf

fun! s:parse_gui_value()
  if s:token.next().kind ==# '#'
    return s:parse_hex_value()
  elseif s:token.kind !=# 'WORD'
    throw 'Invalid GUI color value'
  elseif s:token.value ==? 'rgb'
    return s:parse_rgb_value()
  else
    throw 'Invalid GUI color value'
  endif
endf

fun! s:parse_hex_value()
  if s:token.next().kind !=# 'WORD' || s:token.value !~? '[a-f0-9]\{6\}'
    throw 'Invalid hex color value'
  endif
  return '#' . s:token.value
endf

fun! s:parse_rgb_value()
  if s:token.next().kind !=# '('
    throw 'Missing opening parenthesis'
  endif
  if s:token.next().kind !=# 'NUM'
    throw 'Expected number'
  endif
  let l:red = str2nr(s:token.value)
  if l:red > 255 || l:red < 0
    throw "RGB red component value is out of range"
  endif
  if s:token.next().kind !=# ','
    throw 'Missing comma'
  endif
  if s:token.next().kind !=# 'NUM'
    throw 'Expected number'
  endif
  let l:green = str2nr(s:token.value)
  if l:green > 255 || l:green < 0
    throw "RGB green component value is out of range"
  endif
  if s:token.next().kind !=# ','
    throw 'Missing comma'
  endif
  if s:token.next().kind !=# 'NUM'
    throw 'Expected number'
  endif
  let l:blue = str2nr(s:token.value)
  if l:blue > 255 || l:blue < 0
    throw "RGB blue component value is out of range"
  endif
  if s:token.next().kind !=# ')'
    throw 'Missing closing parenthesis'
  endif
  return colortemplate#colorspace#rgb2hex(l:red, l:green, l:blue)
endf

fun! s:parse_base_256_value()
  if s:token.next().kind ==# 'NUM'
    let l:val = str2nr(s:token.value)
    if l:val > 255 || l:val < 0
      throw "Base-256 color value is out of range"
    endif
    return l:val
  elseif s:token.kind ==# 'WORD'
    return s:token.value
  elseif s:token.kind ==# "'"    " Compound color name (e.g., 'alice blue')
    let l:colorname = []
    while s:token.next().kind ==# 'WORD'
      call add(l:colorname, s:token.value)
    endwhile
    if s:token.kind !=# "'"
      throw 'Missing closing single quote'
    endif
    if empty(l:colorname)
      throw 'Empty quoted color name'
    endif
    return "'" . join(l:colorname, ' ') . "'"
  else
    throw 'Expected base-256 number or color name'
  endif
endf

fun! s:parse_base_16_value()
  if s:token.next().kind ==# 'NUM'
    let l:val = str2nr(s:token.value)
    if l:val > 15 || l:val < 0
      throw 'Base-16 color value is out of range'
    endif
    return l:val
  elseif s:token.kind ==# 'WORD'
    return s:token.value
  else
    throw 'Expected base-16 number or color name'
  endif
endf

fun! s:parse_hi_group_def()
  if s:template.getl() =~# '->' " Look ahead
    return s:parse_linked_group_def()
  endif

  let l:hi_group = {}
  " Base highlight group definition
  let l:hi_group['name'] = s:token.value " Name of highlight group

  " Foreground color
  if s:token.next().kind !=# 'WORD'
    throw 'Foreground color name missing'
  endif
  let [l:hi_group['fg'], l:tfg] = s:parse_color_value()
  if !empty(l:tfg)
    let l:hi_group['tfg'] = l:tfg
  endif
  " Background color
  if s:token.next().kind !=# 'WORD'
    throw 'Background color name missing'
  endif
  let [l:hi_group['bg'], l:tbg] = s:parse_color_value()
  if !empty(l:tbg)
    let l:hi_group['tbg'] = l:tbg
  endif

  call extend(l:hi_group, s:parse_attributes())

  " Add highlight group's definition
  call s:build_hi_group_def(l:hi_group)
endf

" A color value has the form <name> or <name>/<name>, where <name> are
" user-defined color names.
fun! s:parse_color_value()
  let l:color = s:token.value
  if s:is_undefined_color(l:color)
    throw 'Undefined color name: ' . l:color
  endif
  let l:transp = ''
  if s:token.peek().kind ==# '/'
    if s:token.next().next().kind !=# 'WORD'
      throw 'Missing transparent color name'
    endif
    let l:transp = s:token.value
    if s:is_undefined_color(l:transp)
      throw 'Undefined color name: ' . l:transp
    endif
  endif
  return [l:color, l:transp]
endf

fun! s:parse_attributes()
  let l:attributes = { 'cterm': [], 'gui': [], 'sp': '' }

  while s:token.next().kind !=# 'EOL'
    if s:token.kind !=# 'WORD'
      throw 'Invalid attributes'
    endif

    if s:token.value ==? 't' || s:token.value ==? 'term'
      if s:token.next().kind !=# '='
        throw "Expected = symbol after 'term'"
      endif
      call s:token.next()
      let l:attributes['cterm'] += s:parse_attr_list()
    elseif s:token.value ==? 'g' || s:token.value ==? 'gui'
      if s:token.next().kind !=# '='
        throw "Expected = symbol after 'gui'"
      endif
      call s:token.next()
      let l:attributes['gui'] += s:parse_attr_list()
    elseif s:token.value ==? 's' || s:token.value ==? 'guisp'
      if s:token.next().kind !=# '='
        throw "Expected = symbol after 'guisp'"
      endif
      call s:token.next()
      let [l:attributes['sp'], l:tsp] = s:parse_color_value()
      if !empty(l:tsp)
        let l:attrlist['tsp'] = l:tsp
      endif
    else
      let l:attrlist = s:parse_attr_list()
      let l:attributes['cterm'] += l:attrlist
      let l:attributes['gui']   += l:attrlist
    endif
  endwhile

  call uniq(sort(l:attributes['cterm']))
  call uniq(sort(l:attributes['gui']))

  return l:attributes
endf

fun! s:parse_attr_list()
  let l:attrlist = [s:token.value]
  while s:token.peek().kind ==# ','
    if s:token.next().next().kind !=# 'WORD'
      throw 'Invalid attribute list'
    endif
    call add(l:attrlist, s:token.value)
  endwhile
  return l:attrlist
endf

fun! s:parse_linked_group_def()
  let l:source_group = s:token.value
  if s:token.next().kind !=# '-' || s:token.next().kind !=# '>'
    throw 'Expected ->'
  endif
  if s:token.next().kind !=# 'WORD'
    throw 'Expected highlight group name'
  endif
  call s:add_linked_group_def(l:source_group, s:token.value)
endf

fun! s:add_warning(msg)
  call setloclist(0, [{'filename': s:template.path, 'lnum': 1, 'text': a:msg, 'type': 'W'}], 'a')
endf

fun! s:add_error(msg)
  call setloclist(0, [{'filename': s:template.path, 'lnum': 1, 'text': a:msg, 'type': 'E'}], 'a')
endf

fun! s:check_requirements()
  if !has_key(s:info, 'full name')
    call s:add_error('Please specify the full name of your color scheme')
  endif
  if !has_key(s:info, 'author')
    call s:add_error('Please specify an author and the corresponding email')
  endif
  if !has_key(s:info, 'maintainer')
    call s:add_error('Please specify a maintainer and the corresponding email')
  endif
  " if s:has_dark_and_light() && !(s:normal_group_defined['dark'] && s:normal_group_defined['light'])
  "   call s:add_error('Please define the Normal highlight group for both dark and light background')
  " elseif !s:normal_group_defined[s:background]
  "   call s:add_error('Please define the Normal highlight group')
  " endif
endf
" }}} Parser

" Public interface {{{

fun! colortemplate#parse(filename) abort
  call s:init()
  call s:template.load(a:filename)
  while s:template.next_line()
    try
      if s:verbatim
        call s:parse_verbatim_line()
      else
        call s:parse_line()
      endif
    catch /.*/
      call s:template.add_error(v:exception)
    endtry
  endwhile

  call s:check_requirements()

  if !empty(getloclist(0))
    lopen
    throw 'Parse error'
  endif

  lclose
endf
" }}} Public interface
