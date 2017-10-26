" vim: foldmethod=marker nowrap
"
" Grammar {{{
" <Template>                  ::= <Line>*
" <Line>                      ::= <EmptyLine> | <Comment> | <KeyValuePair> | <HiGroupDef> |
"                                 <VerbatimText>  | <Documentation>
" <VerbatimText>              ::= verbatim <Anything> endverbatim
" <Documentation>             ::= documentation <Anything> enddocumentation
" <Comment>                   ::= # .*
" <KeyValuePair>              ::= <ColorDef> | <Key> : <Value>
" <Key>                       ::= Full name | Short name | Author | Background | ...
" <Value>                     ::= .*
" <ColorDef>                  ::= Color : <ColorName> <GUIValue> <Base256Value> [ <Base16Value> ]
" <ColorName>                 ::= [a-z1-9_]+
" <GUIValue>                  ::= <HexValue> | <RGBValue>
" <HexValue>                  ::= #[a-f0-9]{6}
" <RGBValue>                  ::= rgb ( <8BitNumber> , <8BitNumber> , <8BitNumber> )
" <Base256Value>              ::= ~ | <8BitNumber> | <StandardColorName> | ' <StandardCompoundColorName> '
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
  call setloclist(0, [{'filename': self.path, 'lnum' : self.linenr + 1, 'col': s:token.spos + 1, 'text' : a:msg, 'type' : 'E'}], 'a')
endf

fun! s:template.add_warning(msg)
  call setloclist(0, [{'filename': self.path, 'lnum' : self.linenr + 1, 'col': s:token.spos + 1, 'text' : a:msg, 'type' : 'W'}], 'a')
endf

" Current token in the currently parsed line
let s:token = { 'spos' :  0, 'pos'  :  0, 'value': '', 'kind' : '' }

fun! s:token.reset() dict
  let self.spos  = 0
  let self.pos   = 0
  let self.value = ''
  let self.kind  = ''
endf

fun! s:token.next() dict
  let [l:char, self.spos, self.pos] = matchstrpos(s:template.getl(), '\s*\zs.', self.pos) " Get first non-white character starting at pos
  if empty(l:char)
    let self.kind = 'EOL'
    let self.spos = len(s:template.getl()) - 1 " For correct error location
  elseif l:char =~? '\a'
    let [self.value, self.spos, self.pos] = matchstrpos(s:template.getl(), '\w\+', self.pos - 1)
    let self.kind = 'WORD'
  elseif l:char =~# '[0-9]'
    let [self.value, self.spos, self.pos] = matchstrpos(s:template.getl(), '\d\+', self.pos - 1)
    let self.kind = 'NUM'
  elseif l:char ==# '#'
    if match(s:template.getl(), '[0-9a-f]\{6}', self.pos) > -1
      let [self.value, self.spos, self.pos] = matchstrpos(s:template.getl(), '#[0-9a-f]\{6}', self.pos - 1)
      let self.kind = 'HEX'
    else
      let self.value = '#'
      let self.kind = 'COMMENT'
    endif
  elseif l:char =~# "[:=().,'->/~]"
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
  let s:use16colors               = get(g:, 'colortemplate_use16', 0)
  let s:info = {
        \ 'fullname': '',
        \ 'shortname': '',
        \ 'author': '',
        \ 'maintainer': '',
        \ 'website': '',
        \ 'description': '',
        \ 'license': ''
        \ }
  let s:background                = 'dark' " Current background
  let s:uses_background           = { 'dark': 0, 'light': 0 }
  let s:is_verbatim               = 0 " When set to 1, source is copied (almost) verbatim
  let s:is_documentation          = 0 " Set to 1 when inside a help block

  " A palette is a dictionary of color names and their definitions. Each
  " definition consists of a GUI color value, a base-256 color value,
  " a base-16 color value, and a distance between the GUI value and the
  " base-256 value (in this order). Base-16 color values are used instead of
  " base-256 values when g:colortemplate_use16 is set to 1.
  let s:palette                  = {
        \                           'none': ['NONE', 'NONE', 'NONE', 0.0],
        \                           'fg':   ['fg',   'fg',   'fg',   0.0],
        \                           'bg':   ['bg',   'bg',   'bg',   0.0]
        \ }

  " Dictionary to store highlight group definitions. Definitions for dark and
  " light background are kept distinct. Besides, for each background type, we
  " distinguish among (a) definitions that must be applied only when the
  " background is opaque, (b) definitions that must be applied only when the
  " background is transparent, and (c) definitions that apply unconditionally.
  let s:hi_group                 = {}
  let s:hi_group['dark']         = { 'opaque': [], 'transp': [], 'any': [] }
  let s:hi_group['light']        = { 'opaque': [], 'transp': [], 'any': [] }

  let s:normal_group_defined     = { 'dark': 0, 'light': 0 }
  let s:doc                      = [] " For help file
endf
" }}} Internal state

" Helper functions {{{
fun! s:slash() abort
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endf

" Verify that a color name has been defined before it is used.
fun! s:is_undefined_color(color)
  return !has_key(s:palette, a:color)
endf

" Add or override a color definition
fun! s:add_color(name, gui, base256, base16, delta)
  if a:name ==? 'none' || a:name ==? 'fg' || a:name ==? 'bg'
    throw "Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden"
  endif
  " Do not overwrite existing color, but rename it (keep older version for color similarity table)
  if has_key(s:palette, a:name) && (s:palette[a:name][0] !=# a:gui || s:palette[a:name][1] !=# a:base256)
    let s:palette[a:name . ' (' .(s:background ==# 'light' ? 'dark' : 'light') .')'] = s:palette[a:name]
  endif
  let s:palette[a:name] = [a:gui, a:base256, a:base16, a:delta]
endf

" Store a line to send to the output.
" scope must be 'opaque', 'transp', or 'any'.
" definition is the line as it should appear in the output.
fun! s:add_line(scope, definition)
  call add(s:hi_group[s:background][a:scope], a:definition)
endf

" Store a line to send to the help file.
fun! s:add_help(line)
  call add(s:doc, a:line)
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

" The Normal highlight group needs special treatment.
fun! s:check_normal_group(hi_group)
  let l:hi_group = a:hi_group
  if !empty(s:hi_group[s:background]['opaque']) || !empty(s:hi_group[s:background]['any'])
    throw 'The Normal highlight group for ' .s:background. ' background must be the first defined group'
  endif
  if !has_key(l:hi_group, 'tbg')
    let l:hi_group['tbg'] = 'none' " Transparent background
  elseif l:hi_group['tbg'] !=# 'none'
    throw "Alternate background for Normal group can only be 'none'"
  endif
  if l:hi_group['fg'] =~# '^\%(none\|fg\|bg\)$' || l:hi_group['bg'] =~# '^\%(none\|fg\|bg\)$'
    throw "The colors for Normal cannot be 'none', 'fg', or 'bg'"
  endif
  if match(l:hi_group['cterm'], '\%(inv\|rev\)erse') > -1 || match(l:hi_group['gui'], '\%(inv\|rev\)erse') > -1
    throw "Do not use reverse mode for the Normal group"
  endif
  let s:normal_group_defined[s:background] = 1
  return l:hi_group
endf

" Returns a string containing a highlight group definition.
fun! s:build_hi_group_def(hi_group)
  if a:hi_group['name'] ==# 'Normal'
    let l:hi_group = s:check_normal_group(a:hi_group)
  else
    let l:hi_group = a:hi_group
  endif
  if has_key(l:hi_group, 'tfg') || has_key(l:hi_group, 'tbg') || has_key(l:hi_group, 'tsp')
    call s:add_line('opaque', s:hlstring(
          \                           l:hi_group['name'],
          \                           l:hi_group['fg'],
          \                           l:hi_group['bg'],
          \                           l:hi_group['sp'],
          \                           l:hi_group['cterm'],
          \                           l:hi_group['gui']
          \ ))
    call s:add_line('transp', s:hlstring(
          \                           l:hi_group['name'],
          \                           get(l:hi_group, 'tfg', l:hi_group['fg']),
          \                           get(l:hi_group, 'tbg', l:hi_group['bg']),
          \                           get(l:hi_group, 'tsp', l:hi_group['sp']),
          \                           l:hi_group['cterm'],
          \                           l:hi_group['gui']
          \ ))
  else
    call s:add_line('any', s:hlstring(
          \                           l:hi_group['name'],
          \                           l:hi_group['fg'],
          \                           l:hi_group['bg'],
          \                           l:hi_group['sp'],
          \                           l:hi_group['cterm'],
          \                           l:hi_group['gui']
          \ ))
  endif
endf

fun! s:add_linked_group_def(src, tgt)
  call add(s:hi_group[s:background]['any'], 'hi! link ' . a:src . ' ' . a:tgt)
endf

fun! s:has_dark_and_light()
  return s:uses_background['dark'] && s:uses_background['light']
endf

fun! s:add_warning(msg)
  call setloclist(0, [{'filename': s:template.path, 'lnum': 1, 'text': a:msg, 'type': 'W'}], 'a')
endf

fun! s:add_error(msg)
  call setloclist(0, [{'filename': s:template.path, 'lnum': 1, 'text': a:msg, 'type': 'E'}], 'a')
endf

fun! s:check_requirements()
  if empty(s:info['fullname'])
    call s:add_error('Please specify the full name of your color scheme')
  endif
  if empty(s:info['shortname'])
    call s:add_error('Please specify a short name for your colorscheme')
  elseif s:info['shortname'] !~? '^\w\+$'
    call s:add_error('The short name may contain only letters, numbers and underscore.')
  endif
  if empty(s:info['author'])
    call s:add_error('Please specify an author and the corresponding email')
  endif
  if empty(s:info['maintainer'])
    call s:add_error('Please specify a maintainer and the corresponding email')
  endif
  if empty(s:info['license'])
    let s:info['license'] = 'Vim License (see `:help license`)'
  endif
  if s:has_dark_and_light() && !(s:normal_group_defined['dark'] && s:normal_group_defined['light'])
    call s:add_error('Please define the Normal highlight group for both dark and light background')
  elseif !s:normal_group_defined[s:background]
    call s:add_error('Please define the Normal highlight group')
  endif
endf

" Append a String to the end of the current buffer.
fun! s:put(line)
  call append(line('$'), a:line)
endf

fun! s:print_header()
  call setline(1, '" Name:         ' . s:info['fullname']                                             )
  if !empty(s:info['description'])
    call s:put(   '" Description:  ' . s:info['description']                                          )
  endif
  call s:put  (   '" Author:       ' . s:info['author']                                               )
  call s:put  (   '" Maintainer:   ' . s:info['maintainer']                                           )
  if !empty(s:info['website'])
    call s:put(   '" Website:      ' . s:info['website']                                              )
  endif
  call s:put  (   '" License:      ' . s:info['license']                                              )
  call s:put  (   '" Last Updated: ' . strftime("%c")                                                 )
  call s:put  (   ''                                                                                  )
  call s:put  (   "if !(has('termguicolors') && &termguicolors) && !has('gui_running')"               )
  call s:put  (   "      \\ && (!exists('&t_Co') || &t_Co < " . (s:use16colors ? '16)' : '256)')      )
  call s:put  (   "  echoerr '[" . s:info['fullname'] . "] There are not enough colors.'"             )
  call s:put  (   '  finish'                                                                          )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  if !s:has_dark_and_light()
    call s:put(   'set background=' . s:background                                                    )
    call s:put(   ''                                                                                  )
  endif
  call s:put  (   'hi clear'                                                                          )
  call s:put  (   "if exists('syntax_on')"                                                            )
  call s:put  (   '  syntax reset'                                                                    )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  call s:put  (   "let g:colors_name = '" . s:info['shortname'] . "'"                                 )
endf

" Print details about the color palette as comments
fun! s:print_color_details()
  if s:use16colors
    return
  endif
  call s:put('" Color similarity table')
  " Find maximum length of color names (used for formatting)
  let l:len = max(map(copy(s:palette), { k,_ -> len(k)}))
  " Sort colors by increasing delta
  let l:color_names = keys(s:palette)
  call sort(l:color_names, { c1,c2 -> s:palette[c1][3] < s:palette[c2][3] ? -1 : (s:palette[c1][3] > s:palette[c2][3] ? 1 : 0) })
  for l:color in l:color_names
    if l:color =~? '^\%(fg\|bg\|none\)$'
      continue
    endif
    let l:colgui = s:palette[l:color][0]
    let l:col256 = s:palette[l:color][1]
    let l:delta  = s:palette[l:color][3]
    let l:rgbgui = colortemplate#colorspace#hex2rgb(l:colgui)
    if l:col256 > 15 && l:col256 < 256
      let l:hex256 = g:colortemplate#colorspace#xterm256[l:col256 - 16]
      let l:rgb256 = colortemplate#colorspace#hex2rgb(l:hex256)
    else
      let l:hex256 = '#NNNNNN'
      let l:rgb256 = [-1, -1, -1]
    endif
    let l:fmt = '" %'.l:len.'s: GUI=%s/rgb(%3d,%3d,%3d)  Term=%3d %s/rgb(%3d,%3d,%3d)  [delta=%f]'
    call s:put(printf(l:fmt, l:color,  l:colgui, l:rgbgui[0], l:rgbgui[1], l:rgbgui[2],
          \                  l:col256, l:hex256, l:rgb256[0], l:rgb256[1], l:rgb256[2], l:delta
          \   ))
  endfor
  call s:put('')
endf

fun! s:generate_colorscheme()
  silent tabnew +setlocal\ ft=vim
  call s:print_header()
  call s:put('')
  call s:print_color_details()
  if s:has_dark_and_light()
    for l:bg in ['dark', 'light']
      call s:put("if &background ==# '" .l:bg. "'")
      call s:put("if !has('gui_running') && get(g:, '".s:info['shortname']."_transp_bg', 0)")
      call append('$', s:hi_group[l:bg]['transp'])
      call s:put("else")
      call append('$', s:hi_group[l:bg]['opaque'])
      call s:put("endif")
      call append('$', s:hi_group[l:bg]['any'])
      call s:put("endif")
    endfor
  else
    call s:put("if !has('gui_running') && get(g:, '".s:info['shortname']."_transp_bg', 0)")
    call append('$', s:hi_group[s:background]['transp'])
    call s:put("else")
    call append('$', s:hi_group[s:background]['opaque'])
    call s:put("endif")
    call append('$', s:hi_group[s:background]['any'])
  end
  call s:put('')
  " Add template as a comment (only colors and hi group definitions)
  " to make the color scheme reproducible.
  call append('$', map(
        \              filter(s:template.data,
        \                     { _,l -> l =~? '^\s*color\s*:'      ||
        \                              l =~? '^\s*background\s*:' ||
        \                            !(l =~? '^\s*$'              ||
        \                              l =~? '^\s*#'              ||
        \                              l =~? '^\s*\%(\w[^:]*\):'
        \                             )
        \                     }
        \                    ),
        \              { _,l -> '" ' . l }
        \    ))
endf

fun! s:generate_documentation()
  new +setlocal\ ft=help
  for l:line in s:doc
    call s:put(l:line)
  endfor
endf

fun! s:save_buffer(path, filename, overwrite)
  " Create output directory if it does not exist
  if !isdirectory(a:path)
    try
      call mkdir(a:path)
    catch /.*/
      echoerr '[Colortemplate] Could not create directory: ' . a:path
      let g:colortemplate_exit_status = 1
      return
    endtry
  endif
  " Write file
  try
    execute "write".(a:overwrite ? '!' : '') fnameescape(a:path . s:slash() . a:filename)
  catch /.*/
    echoerr '[Colortemplate] Error while writing ' . a:filename . ': ' . v:exception
    let g:colortemplate_exit_status = 1
    return
  endtry
endf

" }}} Helper functions

" Parser {{{
fun! s:parse_verbatim_line()
  if s:template.getl() =~? '^\s*endverbatim'
    let s:is_verbatim = 0
    if s:template.getl() !~? '^\s*endverbatim\s*$'
      throw "Extra characters after 'endverbatim'"
    endif
  else
    try " to interpolate colors
      let l:line = substitute(s:template.getl(), '@term\(\w\+\)', '\=s:palette[submatch(1)][s:use16colors ? 2 : 1]', 'g')
      let l:line = substitute(l:line, '@gui\(\w\+\)',  '\=s:palette[submatch(1)][0]', 'g')
      let l:line = substitute(l:line, '\(term[bf]g=\)@\(\w\+\)', '\=submatch(1).s:palette[submatch(2)][s:use16colors ? 2 : 1]', 'g')
      let l:line = substitute(l:line, '\(gui[bf]g=\|guisp=\)@\(\w\+\)', '\=submatch(1).s:palette[submatch(2)][0]', 'g')
    catch /.*/
      throw 'Undefined color'
    endtry
    call s:add_line('any', l:line)
  endif
endf

fun! s:parse_documentation_line()
  if s:template.getl() =~? '^\s*enddocumentation'
    let s:is_documentation = 0
    if s:template.getl() !~? '^\s*enddocumentation\s*$'
      throw "Extra characters after 'enddocumentation'"
    endif
  else
    try " to interpolate keywords
      let l:line = substitute(s:template.getl(), '@\(\a\+\)', '\=s:info[submatch(1)]', 'g')
    catch /.*/
      throw 'Undefined keyword'
    endtry
    call s:add_help(l:line)
  endif
endf

fun! s:parse_line()
  if s:token.next().kind ==# 'EOL' " Empty line
    return
  elseif s:token.kind ==# 'COMMENT'
    return s:parse_comment()
  elseif s:token.kind ==# 'WORD'
    if s:token.value ==? 'verbatim'
      let s:is_verbatim = 1
      if s:token.next().kind !=# 'EOL'
        throw "Extra characters after 'verbatim'"
      endif
    elseif s:token.value ==? 'documentation'
      let s:is_documentation = 1
      if s:token.next().kind !=# 'EOL'
        throw "Extra characters after 'documentation'"
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
  if s:token.value ==? 'color'
    call s:parse_color_def()
  else " Generic key-value pair
    let l:key_tokens = [s:token.value]
    while s:token.next().kind !=# ':'
      if s:token.kind !=# 'WORD' || s:token.value !~? '^\a\+$'
        throw 'Only letters from a to z are allowed in keys'
      endif
      call add(l:key_tokens, s:token.value)
    endwhile
    let l:key = tolower(join(l:key_tokens, ''))
    let l:val = matchstr(s:template.getl(), '\s*\zs.*$', s:token.pos)
    if l:key ==# 'background'
      if l:val =~? '^dark\s*$'
        let s:background = 'dark'
      elseif l:val =~? '^light\s*$'
        let s:background = 'light'
      else
        throw 'Background can only be dark or light.'
      endif
      let s:uses_background[s:background] = 1
    elseif !has_key(s:info, l:key)
      throw 'Unknown key: ' . l:key
    else
      let s:info[l:key] = l:val
    endif
  endif
endf

fun! s:parse_color_def()
  if s:token.next().kind !=# ':'
    throw 'Expected colon after Color keyword'
  endif
  let l:colorname          = s:parse_color_name()
  let l:col_gui            = s:parse_gui_value()
  let [l:col_256, l:delta] = s:parse_base_256_value(l:col_gui)
  let l:col_16             = s:parse_base_16_value()
  call s:add_color(l:colorname, l:col_gui, l:col_256, l:col_16, l:delta)
endf

fun! s:parse_color_name()
  if s:token.next().kind !=# 'WORD'
    throw 'Invalid color name'
  endif
  return s:token.value
endf

fun! s:parse_gui_value()
  if s:token.next().kind ==# 'HEX'
    return s:token.value
  elseif s:token.kind !=# 'WORD'
    throw 'Invalid GUI color value'
  elseif s:token.value ==? 'rgb'
    return s:parse_rgb_value()
  else
    throw 'Only hex and RGB values are allowed'
  endif
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

fun! s:parse_base_256_value(guicolor)
  if s:token.next().kind ==# '~' " Find best approximation automatically
    let l:color256 = colortemplate#colorspace#approx(a:guicolor)
    return [l:color256['index'], l:color256['delta']]
  elseif s:token.kind ==# 'NUM'
    let l:val = str2nr(s:token.value)
    if l:val > 255 || l:val < 0
      throw "Base-256 color value is out of range"
    endif
    if l:val >= 16
      let l:delta = colortemplate#colorspace#hex_delta_e(a:guicolor, g:colortemplate#colorspace#xterm256[l:val - 16])
    else
      let l:delta = 0.0 / 0.0
    endif
    return [l:val, l:delta]
  elseif s:token.kind ==# 'WORD'
    return [s:token.value, 0.0 / 0.0]
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
    return ["'" . join(l:colorname, ' ') . "'", 0.0/0.0]
  else
    throw 'Expected base-256 number or color name'
  endif
endf

fun! s:parse_base_16_value()
  if s:token.next().kind ==# 'EOL'
    return 'Black'
  elseif s:token.kind ==# 'NUM'
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
  if l:transp ==# 'bg'
    throw "Transparent color cannot be 'bg'"
  endif
  " Set transparent color to 'none' when the color is 'bg' and no transparent
  " color has been specified by the user
  if l:color ==# 'bg' && empty(l:transp)
    let l:transp = 'none'
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
  if s:token.kind !=# 'WORD'
    throw 'Invalid attribute'
  endif
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
" }}} Parser

" Public interface {{{
fun! colortemplate#parse(filename) abort
  call s:init()
  call s:template.load(a:filename)
  while s:template.next_line()
    try
      if s:is_verbatim
        call s:parse_verbatim_line()
      elseif s:is_documentation
        call s:parse_documentation_line()
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

" a:1 is the optional path to an output directory
" a:2 is ! when files should be overridden
fun! colortemplate#make(...)
  if !empty(a:1)
    if !isdirectory(a:1)
      echoerr "[Colortemplate] Path is not a directory:" a:1
      return
    endif
  endif

  try
    call colortemplate#parse(expand('%'))
  catch /Parse error/
    let g:colortemplate_exit_status = 1
    lopen
    return
  catch /.*/
    echoerr '[Colortemplate] Unexpected error: ' v:exception
    let g:colortemplate_exit_status = 1
    return
  endtry

  let l:doc_dir = a:1 . s:slash() . 'doc'
  let l:col_dir = a:1 . s:slash() . 'colors'
  let l:overwrite = (a:0 > 1 ? 1 : 0)
  call s:generate_colorscheme()
  call s:save_buffer(l:col_dir, s:info['shortname'].'.vim', l:overwrite)
  if !get(g:, 'colortemplate_no_doc', 0)
    call s:generate_documentation()
    call s:save_buffer(l:doc_dir, s:info['shortname'].'.txt', l:overwrite)
  endif
  redraw
  echo "\r"
  if g:colortemplate_exit_status == 0
    echomsg '[Colortemplate] Colorscheme written successfully!'
  else
    echoerr '[Colortemplate] Colorscheme was not written'
  endif
endf
" }}} Public interface
