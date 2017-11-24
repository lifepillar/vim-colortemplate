" vim: foldmethod=marker nowrap
"
" Grammar {{{
" <Template>                  ::= <Line>*
" <Line>                      ::= <EmptyLine> | <Comment> | <KeyValuePair> | <HiGroupDef> |
"                                 <VerbatimText>  | <AuxFile> | <Documentation>
" <VerbatimText>              ::= verbatim <Anything> endverbatim
" <AuxFile>                   ::= auxfile <Path> <Anything> endauxfile
" <Path>                      ::= .+
" <Documentation>             ::= documentation <Anything> enddocumentation
" <Anything>                  ::= .*
" <Comment>                   ::= # .*
" <KeyValuePair>              ::= <ColorDef> | <Key> : <Value>
" <Key>                       ::= Full name | Short name | Author | Background | ...
" <Value>                     ::= .*
" <ColorDef>                  ::= Color : <ColorName> <GUIValue> <Base256Value> [ <Base16Value> ]
" <ColorName>                 ::= [a-z1-9_]+
" <GUIValue>                  ::= <HexValue> | <RGBValue> | <RGBColorName>
" <HexValue>                  ::= #[a-f0-9]{6}
" <RGBValue>                  ::= rgb ( <8BitNumber> , <8BitNumber> , <8BitNumber> )
" <RGBColorName>              ::= See $VIMRUNTIME/rgb.txt
" <Base256Value>              ::= ~ | <8BitNumber>
" <8BitNumber>                ::= 0 | 1 | ... | 255
" <Base16Value>               ::= 0 | 1 | ... | 15 | Black | DarkRed | ...
" <HiGroupDef>                ::= <LinkedGroup> | <BaseGroup>
" <LinkedGroup>               ::= <HiGroupName> -> <HiGroupName>
" <BaseGroup>                 ::= <HiGroupName> <FgColor> <BgColor> <Attributes>
" <FgColor>                   ::= <ColorName>
" <BgColor>                   ::= <ColorName>
" <Attributes>                ::= <StyleDef>*
" <StyleDef>                  ::= t[term] = <AttrList> | g[ui] = <AttrList> | guisp = <ColorName> | s = <ColorName> | <AttrList>
" <AttrList>                  ::= <Attr> [, <AttrList]
" <Attr>                      ::= bold | italic | reverse | inverse | underline | ...
" }}}
" Generic helper functions {{{
fun! s:slash() abort " Code borrowed from Pathogen (thanks T. Pope!)
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endf

fun! s:is_absolute(path) abort " Code borrowed from Pathogen (thanks T. Pope)
  return a:path =~# (has('win32') ? '^\%([\\/]\|\w:\)[\\/]\|^[~$]' : '^[/~$]')
endf

" Returns path as an absolute path, after verifying that path is valid,
" i.e., it is inside the directory specified in env.
"
" path: a String specifying a relative or absolute path
" env:  a Dictionary with a 'dir' key specifying a valid directory for path.
fun! s:full_path(path, env)
  if s:is_absolute(a:path)
    let l:path = simplify(fnamemodify(a:path, ":p"))
  else
    let l:path = simplify(fnamemodify(a:env['dir'] . s:slash() . a:path, ":p"))
  endif
  let l:dir = simplify(fnamemodify(a:env['dir'], ":p"))
  if !isdirectory(l:dir)
    throw 'FATAL: Path is not a directory: ' . l:dir
  endif
  if match(l:path, '^' . l:dir) == -1
    throw 'Path ' . l:path . ' outside valid directory: ' . l:dir
  endif
  return l:path
endf

fun! s:make_dir(dirpath)
  let l:dirpath = fnamemodify(a:dirpath, ":p")
  if isdirectory(l:dirpath)
    return
  endif
  try
    call mkdir(fnameescape(l:dirpath), "p")
  catch /.*/
    throw 'Could not create directory: ' . l:dirpath
  endtry
endf

" Write the current buffer into path. The path must be inside env['dir'].
fun! s:write_buffer(path, env, overwrite)
  let l:path = s:full_path(a:path, a:env)
  call s:make_dir(fnamemodify(l:path, ":h"))
  try
    execute (a:overwrite ? 'silent! write!' : 'write') fnameescape(l:path)
  catch /.*/
    throw 'Could not write ' . l:path . ': ' . v:exception
  endtry
endf

" Without arguments, returns a Dictionary of the color names from $VIMRUNTIME/rgb.txt
" (converted to all lowercase), with the associated hex values.
" If an argument is given, returns the hex value of the specified color name.
fun! s:get_rgb_colors(...) abort
  if !exists('s:rgb_colors')
    let s:rgb_colors = {}
    let l:rgb = readfile($VIMRUNTIME . s:slash() . 'rgb.txt')
    for l:line in l:rgb
      let l:match = matchlist(l:line, '^\s*\(\d\+\)\s*\(\d\+\)\s*\(\d\+\)\s*\(.*\)$')
      if len(l:match) > 4
        let [l:name, l:r, l:g, l:b] = [l:match[4], str2nr(l:match[1]), str2nr(l:match[2]), str2nr(l:match[3])]
        let s:rgb_colors[tolower(l:name)] = colortemplate#colorspace#rgb2hex(l:r, l:g, l:b)
      endif
    endfor
    " Add some other valid color names, not in rgb.txt (see syntax.c for the values)
    let s:rgb_colors['darkyellow']   = '#af5f00' " 130
    let s:rgb_colors['lightmagenta'] = '#ffd7ff' " 225
    let s:rgb_colors['lightred']     = '#ffd7d7' " 224
  endif
  if a:0 > 0
    if has_key(s:rgb_colors, tolower(a:1))
      return s:rgb_colors[tolower(a:1)]
    else
      throw 'Unknown RGB color name: ' . a:1
    endif
  endif
  return s:rgb_colors
endf

fun! s:add_error(path, line, col, msg)
  call setloclist(0, [{'filename': a:path, 'lnum' : a:line + 1, 'col': a:col, 'text' : a:msg, 'type' : 'E'}], 'a')
endf

fun! s:add_warning(path, line, col, msg)
  if !get(g:, 'colortemplate_no_warnings', 0)
    call setloclist(0, [{'filename': a:path, 'lnum' : a:line + 1, 'col': a:col, 'text' : a:msg, 'type' : 'W'}], 'a')
  endif
endf

fun! s:add_fatal_error(path, line, col, msg)
  call s:add_error(a:path, a:line, a:col, 1, 'FATAL: ' . a:msg)
endf

fun! s:add_generic_error(msg)
  call s:add_error(bufname('%'), 0, 1, a:msg)
endf

fun! s:add_generic_warning(msg)
  call s:add_warning(bufname('%'), 0, 1, a:msg)
endf

fun! s:print_error_msg(msg, rethrow)
  redraw
  echo "\r"
  if a:rethrow
    echoerr '[Colortemplate]' a:msg
  else
    echohl Error
    echomsg '[Colortemplate]' a:msg
    echohl None
  endif
endf

" Append a String to the end of the current buffer.
fun! s:put(line)
  call append('$', a:line)
endf
" }}} Helper functions
" Internal state {{{
" Working directory {{{
fun! s:init_working_directory(path)
  if !isdirectory(a:path)
    throw 'FATAL: Path is not a directory: ' . a:path
  endif
  let s:work_dir = fnamemodify(a:path, ":p")
  execute 'lcd' s:work_dir
endf

fun! s:working_directory()
  return s:work_dir
endf
" }}}
" Template {{{
" path: path of the currently processed file
" data: the List of the lines from the file
" linenr: the currently processed line from data
" numlines: total number of lines in the file (i.e. length of data)
" includes: the currently processed included file
" NOTE: we do not keep the whole tree of included files because we process
" everything in one pass in a streaming fashion.
fun! s:new_template()
  return {
        \ 'path':      '',
        \ 'data':      [],
        \ 'linenr':     0,
        \ 'numlines':   0,
        \ 'includes':  {},
        \ 'load':      function("s:load"),
        \ 'include':   function("s:include"),
        \ 'getl':      function("s:getl"),
        \ 'next_line': function("s:next_line"),
        \ 'eof':       function("s:eof"),
        \ 'curr_pos':  function("s:curr_pos")
        \ }
endf

fun! s:init_template()
  let s:template = s:new_template()
endf

fun! s:load(path) dict
  let self.path = fnameescape(s:full_path(a:path, {'dir': s:work_dir}))
  let self.data = readfile(self.path)
  let self.numlines = len(self.data)
endf

fun! s:include(path) dict
  let self.includes = s:new_template()
  call self.includes.load(a:path)
endf

fun! s:eof() dict
  return self.linenr >= self.numlines
endf

" Get current line
fun! s:getl() dict
  if empty(self.includes) || self.includes.eof()
    return self.data[self.linenr]
  else
    return self.includes.getl()
  endif
endf

" Move to the next line. Returns 0 if at eof, 1 otherwise.
fun! s:next_line() dict
  if self.eof()
    return 0
  endif
  if empty(self.includes) || !self.includes.next_line()
    let self.linenr += 1
    return !self.eof()
  endif
  return 1
endf

fun! s:curr_pos() dict
  if empty(self.includes) || self.includes.eof()
    return [self.path, self.linenr]
  else
    return self.includes.curr_pos()
  endif
endf
" }}}
" Tokenizer {{{
" Current token in the currently parsed line
let s:token = { 'spos' :  0, 'pos'  :  0, 'value': '', 'kind' : '' }

fun! s:token.reset() dict
  let self.spos  = 0
  let self.pos   = 0
  let self.value = ''
  let self.kind  = ''
endf

fun! s:token.next() dict
  let [l:char, self.spos, self.pos] = matchstrpos(s:template.getl(), '\s*\zs\S', self.pos) " Get first non-white character starting at pos
  if empty(l:char)
    let self.kind = 'EOL'
    let self.spos = len(s:template.getl()) - 1 " For correct error location
  elseif l:char =~? '\m\a'
    let [self.value, self.spos, self.pos] = matchstrpos(s:template.getl(), '\w\+', self.pos - 1)
    let self.kind = 'WORD'
  elseif l:char =~# '\m[0-9]'
    let [self.value, self.spos, self.pos] = matchstrpos(s:template.getl(), '\d\+', self.pos - 1)
    let self.kind = 'NUM'
  elseif l:char ==# '#'
    if match(s:template.getl(), '^[0-9a-f]\{6}', self.pos) > -1
      let [self.value, self.spos, self.pos] = matchstrpos(s:template.getl(), '#[0-9a-f]\{6}', self.pos - 1)
      let self.kind = 'HEX'
    else
      let self.value = '#'
      let self.kind = 'COMMENT'
    endif
  elseif match(l:char, "[:=.,>~)(-]") > -1
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
" }}}
" Info {{{
fun! s:init_info()
  let s:info = {
        \ 'fullname': '',
        \ 'shortname': '',
        \ 'author': '',
        \ 'maintainer': '',
        \ 'website': '',
        \ 'description': '',
        \ 'license': '',
        \ 'terminalcolors': ['256'],
        \ 'prefer16colors': 0,
        \ 'optionprefix': ''
        \ }
endf

fun! s:get_info(key)
  return s:info[a:key]
endf

fun! s:set_info(key, value)
  if !has_key(s:info, a:key)
    throw 'Unknown key: ' . a:key
  endif
  if a:key ==# 'terminalcolors'
    if type(a:value) != type([])
      throw 'FATAL: terminalcolors value must be a List (add_info)'
    endif
    if empty(a:value)
      let a:value = ['256']
    endif
    let s:info['prefer16colors'] = (a:value[0] == '16')
  else
    if type(a:value) != type('')
      throw "FATAL: key value must be a String (add_info)"
    endif
  endif
  let s:info[a:key] = a:value
  if a:key ==# 'shortname'
    if empty(a:value)
      throw 'Please specify a short name for your colorscheme'
    elseif len(a:value) > 24
      throw 'The short name must be at most 24 characters long'
    elseif a:value !~? '\m^\w\+$'
      throw 'The short name may contain only letters, numbers and underscore'
    endif
    if empty(s:info['optionprefix'])
      let s:info['optionprefix'] = s:info['shortname']
    endif
  elseif a:key ==# 'optionprefix'
    if a:value !~? '\m\w\+$'
      throw 'The option prefix may contain only letters, numbers and underscore'
    endif
  endif
endf

fun! s:fullname()
  return s:info['fullname']
endf

fun! s:shortname()
  return s:info['shortname']
endf

fun! s:author()
  return s:info['author']
endf

fun! s:maintainer()
  return s:info['maintainer']
endf

fun! s:description()
  return s:info['description']
endf

fun! s:website()
  return s:info['website']
endf

fun! s:license()
  return s:info['license']
endf

fun! s:optionprefix()
  return s:info['optionprefix']
endf

fun! s:terminalcolors()
  return s:info['terminalcolors']
endf

fun! s:has16and256colors()
  return len(s:info['terminalcolors']) > 1
endf

fun! s:prefer16colors()
  return s:info['prefer16colors']
endf

fun! s:preferred_number_of_colors()
  return get(s:info['terminalcolors'], 0, 256)
endf

fun! s:secondary_number_of_colors()
  return get(s:info['terminalcolors'], 1, 16)
endf
" }}}
" Source {{{
fun! s:init_source()
  let s:source = [] " Keep the source lines here
endf

fun! s:add_source_line(line)
  call add(s:source, a:line)
endf

fun! s:print_source_as_comment()
  for l:line in s:source
    call s:put('" ' . l:line)
  endfor
endf
" }}}
" Background {{{
fun! s:init_current_background()
  let s:current_background = ''
  let s:uses_background = { 'dark': 0, 'light': 0 }
endf

fun! s:current_background()
  return empty(s:current_background) ? 'dark' : s:current_background
endf

fun! s:set_current_background(value)
  if a:value !=# 'dark' && a:value !=# 'light'
    throw 'Background can only be dark or light'
  endif
  if s:has_background(a:value)
    throw 'Cannot select ' . a:value . ' background more than once'
  endif
  let s:current_background = a:value
  let s:uses_background[s:current_background] = 1
endf

fun! s:background_undefined()
  return empty(s:current_background)
endf

fun! s:has_background(value)
  if a:value !=# 'dark' && a:value !=# 'light'
    throw 'FATAL: invalid background value (has_background)'
  endif
  return s:uses_background[a:value]
endf

fun! s:has_dark_and_light()
  return s:has_background('dark') && s:has_background('light')
endf
" }}}
" Palette {{{
" A palette is a Dictionary of color names and their definitions. Each
" definition consists of a GUI color value, a base-256 color value,
" a base-16 color value, and a distance between the GUI value and the
" base-256 value (in this order).
" Each background (dark, light) has its own palette.
fun! s:init_palette()
  let s:palette = {
        \ 'dark':  { 'none': ['NONE', 'NONE', 'NONE', 0.0],
        \            'fg':   ['fg',   'fg',   'fg',   0.0],
        \            'bg':   ['bg',   'bg',   'bg',   0.0]
        \          },
        \ 'light': { 'none': ['NONE', 'NONE', 'NONE', 0.0],
        \            'fg':   ['fg',   'fg',   'fg',   0.0],
        \            'bg':   ['bg',   'bg',   'bg',   0.0]
        \          }
        \ }
endf

fun! s:current_palette()
  return s:palette[s:current_background()]
endf

fun! s:palette(background)
  return s:palette[a:background]
endf

fun! s:color_exists(name, background)
  return has_key(s:palette[a:background], a:name)
endf

fun! s:get_color(name, background)
  return s:palette[a:background][a:name]
endf

fun! s:get_term_color(name, background, use16colors)
  return s:palette[a:background][a:name][a:use16colors ? 2 : 1]
endf

fun! s:get_gui_color(name, background)
  let l:col = s:palette[a:background][a:name][0]
  if match(l:col, '\s') > -1 " Quote RGB color name with spaces
    return "'" . l:col . "'"
  else
    return l:col
  endif
endf

" If the GUI value is a color name, convert it to a hex value
fun! s:rgbname2hex(color)
  return match(a:color, '^#') == - 1 ? s:get_rgb_colors(a:color) : a:color
endf

" name:    A color name
" gui:     GUI color name (e.g, indianred) or hex value (e.g., #c4fed6)
" base256: Base-256 color number or -1
" base16:  Base-16 color number or color name
"
" If base256 is -1, its value is inferred.
fun! s:add_color(name, gui, base256, base16)
  let l:gui = s:rgbname2hex(a:gui)
  " Find an approximation and/or a distance from the GUI value if none was provided
  if a:base256 < 0
    let l:approx_color = colortemplate#colorspace#approx(l:gui)
    let l:base256 = l:approx_color['index']
    let l:delta = l:approx_color['delta']
  else
    let l:base256 = a:base256
    let l:delta = (l:base256 >= 16 && l:base256 <= 255
          \ ? colortemplate#colorspace#hex_delta_e(l:gui, g:colortemplate#colorspace#xterm256_hexvalue(l:base256))
          \ : 0.0 / 0.0)
  endif
  if s:background_undefined()
    " Assume color definitions common to both backgrounds
    let s:palette['dark' ][a:name] = [a:gui, l:base256, a:base16, l:delta]
    let s:palette['light'][a:name] = [a:gui, l:base256, a:base16, l:delta]
  else
    " Assume color definition for the current background
    let s:palette[s:current_background()][a:name] = [a:gui, l:base256, a:base16, l:delta]
  endif
endf

fun! s:assert_valid_color_name(name)
  if a:name ==? 'none' || a:name ==? 'fg' || a:name ==? 'bg'
    throw "Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden"
  endif
  if s:color_exists(a:name, s:current_background())
    throw "Color already defined for " . s:current_background() . " background"
  endif
  " TODO: check that color name starts with alphabetic char
  return 1
endf

fun! s:interpolate(line, use16colors)
  let l:i = (a:use16colors ? 2 : 1)
  let l:line = substitute(a:line, '@term16\(\w\+\)', '\=s:current_palette()[submatch(1)][2]', 'g')
  let l:line = substitute(l:line, '@term256\(\w\+\)', '\=s:current_palette()[submatch(1)][1]', 'g')
  let l:line = substitute(l:line, '@term\(\w\+\)', '\=s:current_palette()[submatch(1)][l:i]', 'g')
  let l:line = substitute(l:line, '@gui\(\w\+\)',  '\=s:current_palette()[submatch(1)][0]', 'g')
  let l:line = substitute(l:line, '\(term[bf]g=\)@\(\w\+\)', '\=submatch(1).s:current_palette()[submatch(2)][l:i]', 'g')
  let l:line = substitute(l:line, '\(gui[bf]g=\|guisp=\)@\(\w\+\)', '\=submatch(1).s:current_palette()[submatch(2)][0]', 'g')
  let l:line = substitute(l:line, '@\(\a\+\)', '\=s:get_info(submatch(1))', 'g')
  return l:line
endf
" }}}
" Highlight group {{{
let s:default_hi_groups = {
      \ 'Normal': 0,
      \ 'ColorColumn': 0,
      \ 'Conceal': 0,
      \ 'Cursor': 0,
      \ 'CursorColumn': 0,
      \ 'CursorLine': 0,
      \ 'CursorLineNr': 0,
      \ 'DiffAdd': 0,
      \ 'DiffChange': 0,
      \ 'DiffDelete': 0,
      \ 'DiffText': 0,
      \ 'Directory': 0,
      \ 'EndOfBuffer': 0,
      \ 'ErrorMsg': 0,
      \ 'FoldColumn': 0,
      \ 'Folded': 0,
      \ 'IncSearch': 0,
      \ 'LineNr': 0,
      \ 'MatchParen': 0,
      \ 'ModeMsg': 0,
      \ 'MoreMsg': 0,
      \ 'NonText': 0,
      \ 'Pmenu': 0,
      \ 'PmenuSbar': 0,
      \ 'PmenuSel': 0,
      \ 'PmenuThumb': 0,
      \ 'Question': 0,
      \ 'QuickFixLine': 0,
      \ 'Search': 0,
      \ 'SignColumn': 0,
      \ 'SpecialKey': 0,
      \ 'SpellBad': 0,
      \ 'SpellCap': 0,
      \ 'SpellLocal': 0,
      \ 'SpellRare': 0,
      \ 'StatusLine': 0,
      \ 'StatusLineNC': 0,
      \ 'StatusLineTerm': 0,
      \ 'StatusLineTermNC': 0,
      \ 'TabLine': 0,
      \ 'TabLineFill': 0,
      \ 'TabLineSel': 0,
      \ 'Title': 0,
      \ 'VertSplit': 0,
      \ 'Visual': 0,
      \ 'VisualNOS': 0,
      \ 'WarningMsg': 0,
      \ 'WildMenu': 0,
      \ 'Comment': 0,
      \ 'Constant': 0,
      \ 'Error': 0,
      \ 'Identifier': 0,
      \ 'Ignore': 0,
      \ 'PreProc': 0,
      \ 'Special': 0,
      \ 'Statement': 0,
      \ 'Todo': 0,
      \ 'Type': 0,
      \ 'Underlined': 0
      \ }

fun! s:undefined_default_groups()
  return keys(filter(copy(s:default_hi_groups), { k,v -> v == 0 }))
endf

fun! s:new_hi_group(name)
  if has_key(s:default_hi_groups, a:name)
    let s:default_hi_groups[a:name] = 1
  endif
  return {
        \ 'name': a:name,
        \ 'fg': '',
        \ 'bg': '',
        \ 'sp': 'none',
        \ 'term': [],
        \ 'gui': []
        \}
endf

fun! s:hi_name(hg)
  return a:hg['name']
endf

fun! s:fg(hg)
  return a:hg['fg']
endf

fun! s:bg(hg)
  return a:hg['bg']
endf

fun! s:sp(hg)
  return a:hg['sp']
endf

fun! s:term_attr(hg)
  return a:hg['term']
endf

fun! s:gui_attr(hg)
  return a:hg['gui']
endf

fun! s:set_fg(hg, colorname)
  if a:colorname ==# 'bg'
    call s:add_warning(s:template.path, s:template.linenr, s:token.pos, "Using 'bg' may cause an error with transparent backgrounds")
  endif
  let a:hg['fg'] = a:colorname
endf

fun! s:set_bg(hg, colorname)
  if a:colorname ==# 'bg'
    call s:add_warning(s:template.path, s:template.linenr, s:token.pos, "Using 'bg' may cause an error with transparent backgrounds")
  endif
  let a:hg['bg'] = a:colorname
endf

fun! s:set_sp(hg, colorname)
  let a:hg['sp'] = a:colorname
endf

fun! s:has_term_attr(hg)
  return !empty(a:hg['term'])
endf

fun! s:has_gui_attr(hg)
  return !empty(a:hg['gui'])
endf

fun! s:add_term_attr(hg, attrlist)
  let a:hg['term'] += a:attrlist
  call uniq(sort(a:hg['term']))
endf

fun! s:add_gui_attr(hg, attrlist)
  let a:hg['gui'] += a:attrlist
  call uniq(sort(a:hg['gui']))
endf

fun! s:term_fg(hg, use16colors)
  return s:get_term_color(s:fg(a:hg), s:current_background(), a:use16colors)
endf

fun! s:term_bg(hg, use16colors)
  return s:get_term_color(s:bg(a:hg), s:current_background(), a:use16colors)
endf

fun! s:gui_fg(hg)
  return s:get_gui_color(s:fg(a:hg), s:current_background())
endf

fun! s:gui_bg(hg)
  return s:get_gui_color(s:bg(a:hg), s:current_background())
endf

fun! s:gui_sp(hg)
  return s:get_gui_color(s:sp(a:hg), s:current_background())
endf
" }}}
" Colorscheme {{{
fun! s:init_colorscheme()
  let s:colorscheme =  {
        \ '16'       : { 'dark': [], 'light': [], 'preamble': [] },
        \ '256'      : { 'dark': [], 'light': [], 'preamble': [] },
        \ 'outpath'  : '/',
        \ 'has_normal': { 'dark': 0, 'light': 0 }
        \ }
endf

fun! s:has_normal_group(background)
  return s:colorscheme['has_normal'][a:background]
endf

fun! s:add_linked_group_def(src, tgt)
  for l:numcol in s:terminalcolors()
    call add(s:colorscheme[l:numcol][s:current_background()],
          \ 'hi! link ' . a:src . ' ' . a:tgt)
  endfor
  if has_key(s:default_hi_groups, a:src)
    let s:default_hi_groups[a:src] = 1
  endif
endf

" Adds the current highlight group to the colorscheme
" This function must be called only after the background is defined
fun! s:add_highlight_group(hg)
  let l:bg = s:current_background()
  if s:hi_name(a:hg) ==# 'Normal' " Normal group needs special treatment
    if s:fg(a:hg) =~# '\m^\%(fg\|bg\)$' || s:bg(a:hg) =~# '\m^\%(fg\|bg\)$'
      throw "The colors for Normal cannot be 'fg' or 'bg'"
    endif
    if match(s:term_attr(a:hg), '\%(inv\|rev\)erse') > -1 || match(s:gui_attr(a:hg), '\%(inv\|rev\)erse') > -1
      throw "Do not use reverse mode for the Normal group"
    endif
    let s:colorscheme['has_normal'][l:bg] = 1
  endif
  for l:numcol in s:terminalcolors()
    let l:use16colors = (l:numcol == '16')
    call add(s:colorscheme[l:numcol][l:bg],
          \ join(['hi', s:hi_name(a:hg),
          \       'ctermfg='  . s:term_fg(a:hg, l:use16colors),
          \       'ctermbg='  . s:term_bg(a:hg, l:use16colors),
          \       'guifg='    . s:gui_fg(a:hg),
          \       'guibg='    . s:gui_bg(a:hg),
          \       'guisp='    . s:gui_sp(a:hg),
          \       'cterm=NONE'. (s:has_term_attr(a:hg) ? ',' . join(s:term_attr(a:hg), ',') : ''),
          \       'gui=NONE'  . (s:has_gui_attr(a:hg)  ? ',' . join(s:gui_attr(a:hg), ',')  : '')
          \ ])
          \ )
  endfor
endf

fun! s:print_colorscheme_preamble(use16colors)
  if !empty(s:colorscheme[a:use16colors ? '16' : '256']['preamble'])
    call append('$', s:colorscheme[a:use16colors ? '16' : '256']['preamble'])
    call s:put('')
  endif
endf

fun! s:print_colorscheme(background, use16colors)
  call append('$', s:colorscheme[a:use16colors ? '16' : '256'][a:background])
endf
" }}}
" Verbatim {{{
fun! s:init_verbatim()
  let s:is_verbatim_block = 0
endf

fun! s:start_verbatim()
  let s:is_verbatim_block = 1
endf

fun! s:stop_verbatim()
  let s:is_verbatim_block = 0
endf

fun! s:is_verbatim()
  return s:is_verbatim_block
endf

fun! s:add_verbatim_line(line)
  for l:numcol in s:terminalcolors()
    try
      let l:line = s:interpolate(a:line, l:numcol == '16')
    catch /.*/
      throw 'Undefined @ value'
    endtry
    if s:background_undefined()
      call add(s:colorscheme[l:numcol]['preamble'], l:line)
    else " Add to current background
      call add(s:colorscheme[l:numcol][s:current_background()], l:line)
    endif
  endfor
endf
" }}}
" Aux files {{{
fun! s:init_aux_files()
  let s:auxfiles = {}    " Mappings from paths to list of lines
  let s:auxfilepath = '' " Path to the currently processed aux file
  let s:is_auxfile = 0   " Set to 1 when processing an aux file
  let s:is_helpfile = 0  " Set to 1 when processing a documentation block
endf

" path: path of the aux file as specified in the template
fun! s:start_aux_file(path)
  let s:is_auxfile = 1
  if empty(a:path)
    throw 'Missing path'
  endif
  let s:auxfiles[a:path] = []
  let s:auxfilepath = a:path
endf

fun! s:stop_aux_file()
  let s:is_auxfile = 0
endf

fun! s:is_aux_file()
  return s:is_auxfile
endf

fun! s:start_help_file()
  let l:path = 'doc' . s:slash() . s:shortname() . '.txt'
  let s:auxfiles[l:path] = []
  let s:auxfilepath = l:path
  let s:is_helpfile = 1
endf

fun! s:is_help_file()
  return s:is_helpfile
endf

fun! s:stop_help_file()
  let s:is_helpfile = 0
endf

fun! s:add_line_to_aux_file(line)
  try " to interpolate variables
    let l:line = s:interpolate(a:line, s:prefer16colors())
  catch /.*/
    throw 'Undefined keyword'
  endtry
  call add(s:auxfiles[s:auxfilepath], l:line)
endf

fun! s:generate_aux_files(outdir, overwrite)
  if get (g:, 'colortemplate_no_aux_files', 0)
    return
  endif
  for l:path in keys(s:auxfiles)
    if match(l:path, '^doc' . s:slash()) > -1 " Help file
      if get(g:, 'colortemplate_no_doc', 0)
        continue
      endif
      silent bot new +setlocal\ tw=78\ ts=8\ ft=help\ norl
      call append(0, s:auxfiles[l:path])
      call s:predefined_help_text()
    else                                      " Other aux files
      if fnamemodify(l:path, ":e") ==# 'vim'
        silent bot new +setlocal\ ft=vim
      else
        silent bot new
      endif
      call append(0, s:auxfiles[l:path])
    endif
    if !empty(a:outdir)
      call s:write_buffer(l:path, { 'dir': a:outdir }, a:overwrite)
    endif
  endfor
endf

fun! s:predefined_help_text()
  if s:has16and256colors()
    let l:default = s:prefer16colors()
    let l:pad = len(s:fullname()) + len(s:shortname())
    call s:put(              '=============================================================================='                  )
    call s:put(s:interpolate('@fullname other options' . repeat("\t", max([1,(40-l:pad)/8])) . '*@shortname-other-options*', 0))
    call s:put(              ''                                                                                                )
    let l:pad = len(s:optionprefix())
    call s:put(s:interpolate(repeat("\t", max([1,(68-l:pad)/8])) . '*g:@optionprefix_use16*', 0)                               )
    call s:put(              'Set to ' . (1-l:default) . ' if you want to use ' .s:secondary_number_of_colors() . ' colors.'   )
    call s:put(              '>'                                                                                               )
    call s:put(s:interpolate('	let g:@optionprefix_use16 = ', 0) . l:default                                                  )
    call s:put(              '<'                                                                                               )
  endif
  call s:put(              'vim:tw=78:ts=8:ft=help:norl:'                                                                      )
endf
" }}}
" Initialize state {{{
fun! s:init(work_dir)
  let g:colortemplate_exit_status = 0

  call setloclist(0, [], 'r') " Reset location list

  call s:init_working_directory(a:work_dir)
  call s:init_template()
  call s:init_info()
  call s:init_source()
  call s:init_current_background()
  call s:init_palette()
  call s:init_colorscheme()
  call s:init_aux_files()
  call s:init_verbatim()
endf
" }}}
" }}} Internal state
" Colorscheme generation {{{
fun! s:assert_requirements()
  if empty(s:fullname())
    call s:add_generic_error('Please specify the full name of your color scheme')
  endif
  if empty(s:author())
    call s:add_generic_error('Please specify an author and the corresponding email')
  endif
  if empty(s:maintainer())
    call s:add_generic_error('Please specify a maintainer and the corresponding email')
  endif
  if empty(s:license())
    let s:info['license'] = 'Vim License (see `:help license`)'
  endif
  if s:has_dark_and_light() && !(s:has_normal_group('dark') && s:has_normal_group('light'))
    call s:add_generic_error('Please define the Normal highlight group for both dark and light background')
  elseif !s:has_normal_group(s:current_background())
    call s:add_generic_error('Please define the Normal highlight group')
  endif
  let l:missing_groups = s:undefined_default_groups()
  for l:hg in l:missing_groups
    call s:add_generic_warning('No definition for ' . l:hg . ' highlight group')
  endfor
endf

fun! s:print_header()
  if s:has16and256colors()
    let l:limit = "(get(g:, '" . s:optionprefix() . "_use16', " . string(s:prefer16colors()) . ") ? 16 : 256)"
  else
    let l:limit = s:preferred_number_of_colors()
  endif
  call setline(1, '" Name:         ' . s:fullname()                                                   )
  if !empty(s:description())
    call s:put(   '" Description:  ' . s:description()                                                )
  endif
  call s:put  (   '" Author:       ' . s:author()                                                     )
  call s:put  (   '" Maintainer:   ' . s:maintainer()                                                 )
  if !empty(s:website())
    call s:put(   '" Website:      ' . s:website()                                                    )
  endif
  call s:put  (   '" License:      ' . s:license()                                                    )
  call s:put  (   '" Last Updated: ' . strftime("%c")                                                 )
  call s:put  (   ''                                                                                  )
  call s:put  (   "if !(has('termguicolors') && &termguicolors) && !has('gui_running')"               )
  call s:put  (   "      \\ && (!exists('&t_Co') || &t_Co < " . l:limit . ')'                         )
  call s:put  (   "  echoerr '[" . s:fullname() . "] There are not enough colors.'"                   )
  call s:put  (   '  finish'                                                                          )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  if !s:has_dark_and_light()
    call s:put(   'set background=' . s:current_background()                                          )
    call s:put(   ''                                                                                  )
  endif
  call s:put  (   'hi clear'                                                                          )
  call s:put  (   "if exists('syntax_on')"                                                            )
  call s:put  (   '  syntax reset'                                                                    )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  call s:put  (   "let g:colors_name = '" . s:shortname() . "'"                                       )
  call s:put  (   ''                                                                                  )
endf

" Print details about the color palette for the specified background as comments
fun! s:print_color_details(bg, use16colors)
  if a:use16colors
    return
  endif
  call s:put('" Color similarity table (' . a:bg . ' background)')
  let l:palette = s:palette(a:bg)
  " Find maximum length of color names (used for formatting)
  let l:len = max(map(copy(l:palette), { k,_ -> len(k)}))
  " Sort colors by increasing delta
  let l:color_names = keys(l:palette)
  call sort(l:color_names, { c1,c2 ->
        \ isnan(l:palette[c1][3])
        \      ? (isnan(l:palette[c2][3]) ? 0 : 1)
        \      : (isnan(l:palette[c2][3]) ? -1 : (l:palette[c1][3] < l:palette[c2][3] ? -1 : (l:palette[c1][3] > l:palette[c2][3] ? 1 : 0)))
        \ })
  for l:color in l:color_names
    if l:color =~? '\m^\%(fg\|bg\|none\)$'
      continue
    endif
    let l:colgui = s:rgbname2hex(l:palette[l:color][0])
    let l:col256 = l:palette[l:color][1]
    let l:delta  = l:palette[l:color][3]
    let l:rgbgui = colortemplate#colorspace#hex2rgb(l:colgui)
    if l:col256 > 15 && l:col256 < 256
      let l:hex256 = g:colortemplate#colorspace#xterm256[l:col256 - 16]
      let l:rgb256 = colortemplate#colorspace#hex2rgb(l:hex256)
      let l:def256 = l:hex256 . printf('/rgb(%3d,%3d,%3d)', l:rgb256[0], l:rgb256[1], l:rgb256[2])
    else
      let l:def256 = repeat(' ', 24)
    endif
    let l:fmt = '" %'.l:len.'s: GUI=%s/rgb(%3d,%3d,%3d)  Term=%3d %s  [delta=%f]'
    call s:put(printf(l:fmt, l:color, l:colgui, l:rgbgui[0], l:rgbgui[1], l:rgbgui[2], l:col256, l:def256, l:delta))
  endfor
endf

fun! s:generate_colorscheme(outdir, overwrite)
  silent tabnew +setlocal\ ft=vim
  call s:print_header()
  for l:numcol in s:terminalcolors()
    let l:use16colors = (l:numcol == 16)
    if s:has16and256colors() && l:numcol == s:preferred_number_of_colors()
      call s:put('" ' . l:numcol . '-color variant')
      let l:not = s:prefer16colors() ? '' : '!'
      call s:put("if " .l:not."get(g:, '" . s:optionprefix() . "_use16', " . s:prefer16colors() .")")
    endif
    call s:print_colorscheme_preamble(l:use16colors)
    if s:has_dark_and_light()
      call s:put("if &background ==# 'dark'")
      call s:print_color_details('dark', l:use16colors)
      call s:print_colorscheme('dark', l:use16colors)
      call s:put("finish")
      call s:put("endif")
      call s:put('')
      call s:print_color_details('light', l:use16colors)
      call s:print_colorscheme('light', l:use16colors)
    else " One background
      call s:print_color_details(s:current_background(), l:use16colors)
      call s:print_colorscheme(s:current_background(), l:use16colors)
    end
    if s:has16and256colors() && l:numcol == s:preferred_number_of_colors()
      call s:put('finish')
      call s:put('endif')
      call s:put('')
      call s:put('" ' . s:secondary_number_of_colors() . '-color variant')
    endif
  endfor
  call s:put('finish')
  call s:put('')
  call s:print_source_as_comment()
  " Reindent
  norm gg=G
  if !empty(a:outdir)
    call s:write_buffer(
          \ a:outdir . s:slash() . 'colors' . s:slash() . s:shortname() . '.vim',
          \ { 'dir': a:outdir },
          \ a:overwrite)
  endif
endf
" }}}
" Parser {{{
fun! s:parse_verbatim_line()
  if s:template.getl() =~? '\m^\s*endverbatim'
    call s:stop_verbatim()
    if s:template.getl() !~? '\m^\s*endverbatim\s*$'
      throw "Extra characters after 'endverbatim'"
    endif
  else
    call s:add_verbatim_line(s:template.getl())
  endif
endf

fun! s:parse_help_line()
  if s:template.getl() =~? '\m^\s*enddocumentation'
    call s:stop_help_file()
    if s:template.getl() !~? '\m^\s*enddocumentation\s*$'
      throw "Extra characters after 'enddocumentation'"
    endif
  else
    call s:add_line_to_aux_file(s:template.getl())
  endif
endf

fun! s:parse_auxfile_line()
  if s:template.getl() =~? '\m^\s*endauxfile'
    call s:stop_aux_file()
    if s:template.getl() !~? '\m^\s*endauxfile\s*$'
      throw "Extra characters after 'endauxfile'"
    endif
  else
    call s:add_line_to_aux_file(s:template.getl())
  endif
endf

fun! s:parse_line()
  if s:token.next().kind ==# 'EOL' " Empty line
    return
  elseif s:token.kind ==# 'COMMENT'
    return s:parse_comment()
  elseif s:token.kind ==# 'WORD'
    if s:token.value ==? 'verbatim'
      call s:start_verbatim()
      if s:token.next().kind !=# 'EOL'
        throw "Extra characters after 'verbatim'"
      endif
    elseif s:token.value ==? 'auxfile'
      call s:start_aux_file(matchstr(s:template.getl(), '^\s*auxfile\s\+\zs.*'))
    elseif s:token.value ==? 'documentation'
      call s:start_help_file()
    elseif s:template.getl() =~? '\m:' " Look ahead
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
    call s:add_source_line(s:template.getl())
    call s:parse_color_def()
  else " Generic key-value pair
    let l:key_tokens = [s:token.value]
    while s:token.next().kind !=# ':'
      if s:token.kind !=# 'WORD' || s:token.value !~? '\m^\a\+$'
        throw 'Only letters from a to z are allowed in keys'
      endif
      call add(l:key_tokens, s:token.value)
    endwhile
    let l:key = tolower(join(l:key_tokens, ''))
    let l:val = matchstr(s:template.getl(), '\s*\zs.*$', s:token.pos)
    if l:key ==# 'background'
      call s:add_source_line(s:template.getl())
      if l:val =~? '\m^dark\s*$'
        call s:set_current_background('dark')
      elseif l:val =~? '\m^light\s*$'
        call s:set_current_background('light')
      else
        throw 'Background can only be dark or light.'
      endif
    elseif l:key ==# 'terminalcolors'
      let l:numcol = uniq(map(split(l:val, '\s*,\s*'), { _,v -> string(str2nr(v)) }))
      if !empty(l:numcol)
        if len(l:numcol) > 2 || (l:numcol[0] != 16 && l:numcol[0] != 256) ||
              \ (len(l:numcol) == 2 && l:numcol[1] != 16 && l:numcol[1] != 256)
          throw 'Only 16 and/or 256 colors can be specified.'
        else
          call s:set_info('terminalcolors', l:numcol)
        endif
      endif
    elseif l:key ==# 'include'
      call s:template.include(l:val)
    else
      call s:set_info(l:key, l:val)
    endif
  endif
endf

fun! s:parse_color_def()
  if s:token.next().kind !=# ':'
    throw 'Expected colon after Color keyword'
  endif
  let l:colorname = s:parse_color_name()
  let l:col_gui   = s:parse_gui_value()
  let l:col_256   = s:parse_base_256_value(l:col_gui)
  let l:col_16    = s:parse_base_16_value()
  call s:add_color(l:colorname, l:col_gui, l:col_256, l:col_16)
endf

fun! s:parse_color_name()
  if s:token.next().kind !=# 'WORD'
    throw 'Invalid color name'
  endif
  call s:assert_valid_color_name(s:token.value)
  return s:token.value
endf

fun! s:parse_gui_value()
  if s:token.next().kind ==# 'HEX'
    return s:token.value
  elseif s:token.kind !=# 'WORD'
    throw 'Invalid GUI color value'
  elseif s:token.value ==? 'rgb'
    return s:parse_rgb_value()
  else " Assume RGB name from $VIMRUNTIME/rgb.txt
    let l:rgb_name = s:token.value
    while s:token.peek().kind ==# 'WORD'
      let l:rgb_name .= ' ' . s:token.next().value
    endwhile
    if !has_key(s:get_rgb_colors(), tolower(l:rgb_name))
      throw 'Unknown RGB color name'
    else
      return l:rgb_name
    endif
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
    return -1
  elseif s:token.kind ==# 'NUM'
    let l:val = str2nr(s:token.value)
    if l:val > 255 || l:val < 0
      throw "Base-256 color value is out of range"
    endif
    return l:val
  endif
  throw 'Expected base-256 number or tilde'
endf

fun! s:parse_base_16_value()
  if s:token.next().kind ==# 'EOL' || s:token.kind ==# 'COMMENT'
    return 'Black' " Just a placeholder: we assume that base-16 colors are not used
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
  call s:add_source_line(s:template.getl())

  if s:template.getl() =~# '\m->' " Look ahead
    return s:parse_linked_group_def()
  endif

  " Base highlight group definition
  let l:hg = s:new_hi_group(s:token.value)
  " Foreground color
  if s:token.next().kind !=# 'WORD'
    throw 'Foreground color name missing'
  endif
  call s:set_fg(l:hg, s:parse_color_value())
  " Background color
  if s:token.next().kind !=# 'WORD'
    throw 'Background color name missing'
  endif
  call s:set_bg(l:hg, s:parse_color_value())

  let l:hg = s:parse_attributes(l:hg)

  call s:add_highlight_group(l:hg)
endf

fun! s:parse_color_value()
  let l:color = s:token.value
  if !s:color_exists(l:color, s:current_background())
    throw 'Undefined color name: ' . l:color
  endif
  return l:color
endf

fun! s:parse_attributes(hg)
  while s:token.next().kind !=# 'EOL' && s:token.kind !=# 'COMMENT'
    if s:token.kind !=# 'WORD'
      throw 'Invalid attributes'
    endif

    if s:token.value ==? 't' || s:token.value ==? 'term'
      if s:token.next().kind !=# '='
        throw "Expected = symbol after 'term'"
      endif
      call s:token.next()
      call s:add_term_attr(a:hg, s:parse_attr_list())
    elseif s:token.value ==? 'g' || s:token.value ==? 'gui'
      if s:token.next().kind !=# '='
        throw "Expected = symbol after 'gui'"
      endif
      call s:token.next()
      call s:add_gui_attr(a:hg, s:parse_attr_list())
    elseif s:token.value ==? 's' || s:token.value ==? 'guisp'
      if s:token.next().kind !=# '='
        throw "Expected = symbol after 'guisp'"
      endif
      call s:token.next()
      call s:set_sp(a:hg, s:parse_color_value())
    else
      let l:attrlist = s:parse_attr_list()
      call s:add_term_attr(a:hg, l:attrlist)
      call s:add_gui_attr(a:hg, l:attrlist)
    endif
  endwhile

  return a:hg
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
  call s:init(fnamemodify(a:filename, ":h"))
  call s:template.load(a:filename)
  while !s:template.eof()
    call s:token.reset()
    try
      if s:is_verbatim()
        call s:parse_verbatim_line()
      elseif s:is_aux_file()
        call s:parse_auxfile_line()
      elseif s:is_help_file()
        call s:parse_help_line()
      else
        call s:parse_line()
      endif
    catch /^FATAL/
      let [l:path, l:line] = s:template.curr_pos()
      call s:add_error(l:path, l:line, s:token.spos + 1, v:exception)
      throw 'Parse error'
    catch /.*/
      let [l:path, l:line] = s:template.curr_pos()
      call s:add_error(l:path, l:line, s:token.spos + 1, v:exception)
    endtry
    call s:template.next_line()
  endwhile

  call s:assert_requirements()

  if !empty(getloclist(0))
    lopen
    if !empty(filter(getloclist(0), { i,v -> v['type'] !=# 'W' }))
      throw 'Parse error'
    endif
  else
    lclose
  endif
endf

" a:1 is the optional path to an output directory
" a:2 is ! when files should be overridden
fun! colortemplate#make(...)
  let l:outdir = (a:0 > 0 && !empty(a:1) ? simplify(fnamemodify(a:1, ':p')) : '')
  let l:overwrite = (a:0 > 1 ? (a:2 == '!') : 0)
  if !empty(l:outdir)
    if !isdirectory(l:outdir)
      call s:print_error_msg("Path is not a directory: " . l:outdir, 0)
      let g:colortemplate_exit_status = 1
      return
    elseif filewritable(l:outdir) != 2
      call s:print_error_msg("Directory is not writable: " . l:outdir, 0)
      let g:colortemplate_exit_status = 1
      return
    endif
  endif

  try
    call colortemplate#parse(expand('%:p'))
  catch /Parse error/
    let g:colortemplate_exit_status = 1
    lopen
    return
  catch /.*/
    echoerr '[Colortemplate] Unexpected error: ' v:exception
    let g:colortemplate_exit_status = 1
    return
  endtry

  try
    call s:generate_colorscheme(l:outdir, l:overwrite)
    call s:generate_aux_files(l:outdir, l:overwrite)
  catch /.*/
    call s:print_error_msg(v:exception, 0)
    return
  endtry

  redraw
  echo "\r"
  echomsg '[Colortemplate] Colorscheme successfully created!'
endf
" }}} Public interface
