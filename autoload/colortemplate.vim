" vim: foldmethod=marker nowrap
let s:VERSION = '2.0.0b'
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
" <KeyValuePair>              ::= <PaletteSpec> | <ColorDef> | <Key> : <Value>
" <Key>                       ::= Full name | Short name | Author | Background | ...
" <Value>                     ::= .*
" <PaletteSpec>               ::= <PaletteName> [<Arg> [<Arg>]*]
" <PaletteName>               ::= \w\+
" <Arg>                       ::= number or word
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
" Working directory {{{
fun! s:setwd(path)
  if !isdirectory(a:path)
    throw 'FATAL: Path is not a directory: ' . a:path
  endif
  let s:wd = fnamemodify(a:path, ":p")
  execute 'lcd' s:wd
endf

fun! s:getwd()
  return s:wd
endf
" }}}
" Stack functions {{{
fun! s:push(S, e)
  return add(a:S, a:e)
endf

fun! s:pop(S)
  return remove(a:S, -1)
endf

fun! s:top(S)
  return a:S[-1]
endf
" }}}
" Path manipulation {{{
fun! s:slash() abort " Code borrowed from Pathogen (thanks T. Pope!)
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endf

fun! s:is_absolute(path) abort " Code borrowed from Pathogen (thanks T. Pope)
  return a:path =~# (has('win32') ? '^\%([\\/]\|\w:\)[\\/]\|^[~$]' : '^[/~$]')
endf

fun! s:match_path(path, regexp)
  if exists('+shellslash') && !&shellslash
    return match(tr(a:path, '\', '/'), tr(a:regexp, '\', '/')) > -1
  else
    return match(a:path, a:regexp) > -1
  endif
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
  if !s:match_path(l:path, '^' . l:dir)
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

" Write the specified buffer into path. The path must be inside env['dir'].
fun! s:write_buffer(bufnr, path, env, overwrite)
  let l:path = s:full_path(a:path, a:env)
  call s:make_dir(fnamemodify(l:path, ":h"))
  if bufloaded(l:path)
    if a:overwrite
      execute "bdelete" bufname(a:path)
    else
      throw "Buffer " . l:path . " exists. Use ! to override."
    endif
  endif
  if a:overwrite || !filereadable(l:path)
    if writefile(getbufline(a:bufnr, 1, "$"), l:path) < 0
      throw 'Could not write ' . l:path . ': ' . v:exception
    endif
  else
    throw 'File exists: ' . l:path . '. Use ! to overwrite it.'
  endif
endf
" }}}
" Errors and warnings {{{
fun! s:add_error(path, line, col, msg)
  call setloclist(0, [{'filename': a:path, 'lnum' : a:line, 'col': a:col, 'text' : a:msg, 'type' : 'E'}], 'a')
endf

fun! s:add_warning(path, line, col, msg)
  if !get(g:, 'colortemplate_no_warnings', 0)
    call setloclist(0, [{'filename': a:path, 'lnum' : a:line, 'col': a:col, 'text' : a:msg, 'type' : 'W'}], 'a')
  endif
endf

fun! s:add_generic_error(msg)
  call s:add_error(bufname('%'), 1, 1, a:msg)
endf

fun! s:add_generic_warning(msg)
  call s:add_warning(bufname('%'), 1, 1, a:msg)
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
" }}}
" Misc {{{
if has('nvim')
  fun! s:isnan(x)
    return printf("%f", a:x) ==# 'nan'
  endf
else
  fun! s:isnan(x)
    return isnan(a:x)
  endf
endif
" }}}
" }}} Helper functions
" Data structures {{{
" Data and functions common to the parser and the generator
" Source code {{{
fun! s:init_source_code()
  let s:source = [] " Keep the source lines here
endf

fun! s:add_source_line(line)
  call add(s:source, a:line)
endf

fun! s:source_lines()
  return s:source
endf
" }}}
" Color palette {{{
fun! s:init_color_palette()
  let s:guicol = { 'dark': {'fg':'fg', 'bg':'bg', 'none': 'NONE'}, 'light': {'fg':'fg', 'bg':'bg', 'none': 'NONE'} }
  let s:col256 = { 'dark': {'fg':'fg', 'bg':'bg', 'none': 'NONE'}, 'light': {'fg':'fg', 'bg':'bg', 'none': 'NONE'} }
  let s:col16  = { 'dark': {'fg':'fg', 'bg':'bg', 'none': 'NONE'}, 'light': {'fg':'fg', 'bg':'bg', 'none': 'NONE'} }
  call s:reset_backgrounds()
endf

fun! s:reset_backgrounds()
  let s:active_bg = ['dark', 'light']
  let s:bg_set = 0
endf

fun! s:set_active_bg(v)
  let s:active_bg = [a:v]
  let s:bg_set = 1
endf

" Returns 'dark' or 'light'
fun! s:default_bg()
  return s:active_bg[0]
endf

" Returns 'dark', 'light' or 'any'
fun! s:current_bg()
  return len(s:active_bg) == 1 ? s:active_bg[0] : 'any'
endf

fun! s:active_backgrounds()
  return s:active_bg
endf

fun! s:background_is_set()
  return s:bg_set
endf

" name: color name as defined by the user
" gui: GUI value (either a hex value or a standard name)
" base256: a numeric value between 16 and 255 or -1 (=infer the value)
" base16: a numeric value between 0 and 15
fun! s:add_color(name, gui, base256, base16)
  " If the GUI color is given by name, quote it if the name contains spaces
  let l:gui = match(a:gui, '\s') > - 1 ? "'".a:gui."'" : a:gui
  for l:bg in s:active_backgrounds()
    let s:guicol[l:bg][a:name] = l:gui
    let s:col256[l:bg][a:name] = a:base256
    let  s:col16[l:bg][a:name] = a:base16
  endfor
endf

fun! s:col16(name)
  return s:col16[s:default_bg()][a:name]
endf

fun! s:col256(name)
  if s:col256[s:default_bg()][a:name] == -1 " Infer the value from GUI color
    let s:col256[s:default_bg()][a:name] =
          \ colortemplate#colorspace#approx(s:guicol[s:default_bg()][a:name])['index']
  endif
  return s:col256[s:default_bg()][a:name]
endf

fun! s:termcol(name, t_Co)
  return a:t_Co <= 16 ? s:col16(a:name) : s:col256(a:name)
endf

fun! s:guicol(name)
  return s:guicol[s:default_bg()][a:name]
endf

fun! s:is_color_defined(name)
  return has_key(s:guicol[s:default_bg()], a:name)
endf
" }}}
" Terminal ANSI colors {{{
fun! s:init_term_colors()
  let s:term_colors = { 'dark': [], 'light': [] }
endf

fun! s:add_term_ansi_color(color)
  for l:bg in s:active_backgrounds()
    call add(s:term_colors[l:bg], a:color)
  endfor
endf

fun! s:term_colors()
  return s:term_colors[s:default_bg()]
endf
" }}}
" Highlight groups {{{
fun! s:init_highlight_groups()
  return 1
endf

let s:default_hi_groups = [
      \ 'ColorColumn',
      \ 'Comment',
      \ 'Conceal',
      \ 'Constant',
      \ 'Cursor',
      \ 'CursorColumn',
      \ 'CursorLine',
      \ 'CursorLineNr',
      \ 'DiffAdd',
      \ 'DiffChange',
      \ 'DiffDelete',
      \ 'DiffText',
      \ 'Directory',
      \ 'EndOfBuffer',
      \ 'Error',
      \ 'ErrorMsg',
      \ 'FoldColumn',
      \ 'Folded',
      \ 'Identifier',
      \ 'Ignore',
      \ 'IncSearch',
      \ 'LineNr',
      \ 'MatchParen',
      \ 'ModeMsg',
      \ 'MoreMsg',
      \ 'NonText',
      \ 'Normal',
      \ 'Pmenu',
      \ 'PmenuSbar',
      \ 'PmenuSel',
      \ 'PmenuThumb',
      \ 'PreProc',
      \ 'Question',
      \ 'QuickFixLine',
      \ 'Search',
      \ 'SignColumn',
      \ 'Special',
      \ 'SpecialKey',
      \ 'SpellBad',
      \ 'SpellCap',
      \ 'SpellLocal',
      \ 'SpellRare',
      \ 'Statement',
      \ 'StatusLine',
      \ 'StatusLineNC',
      \ 'StatusLineTerm',
      \ 'StatusLineTermNC',
      \ 'TabLine',
      \ 'TabLineFill',
      \ 'TabLineSel',
      \ 'Title',
      \ 'Todo',
      \ 'ToolbarButton',
      \ 'ToolbarLine',
      \ 'Type',
      \ 'Underlined',
      \ 'VertSplit',
      \ 'Visual',
      \ 'VisualNOS',
      \ 'WarningMsg',
      \ 'WildMenu',
      \ ]

fun! s:new_hi_group(name)
  return {
        \ 'name': a:name,
        \ 'fg': '',
        \ 'bg': '',
        \ 'sp': 'none',
        \ 'term': [],
        \ 'term_italic': 0,
        \ 'gui_italic': 0,
        \ 'gui': [],
        \ 'start': '',
        \ 'stop': '',
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

fun! s:term_attr_list(hg)
  return a:hg['term']
endf

fun! s:gui_attr_list(hg)
  return a:hg['gui']
endf

fun! s:fg16(hg)
  return s:col16(a:hg['fg'])
endf

fun! s:bg16(hg)
  return s:col16(a:hg['bg'])
endf

fun! s:fg256(hg)
  return s:col256(a:hg['fg'])
endf

fun! s:bg256(hg)
  return s:col256(a:hg['bg'])
endf

fun! s:guifg(hg)
  return s:guicol(a:hg['fg'])
endf

fun! s:guibg(hg)
  return s:guicol(a:hg['bg'])
endf

fun! s:guisp(hg)
  return s:guicol(a:hg['sp'])
endf

fun! s:term_attr(hg)
  return empty(a:hg['term']) ? 'NONE' : join(a:hg['term'], ',')
endf

fun! s:gui_attr(hg)
  return empty(a:hg['gui']) ? 'NONE' : join(a:hg['gui'], ',')
endf

fun! s:set_fg(hg, colorname)
  let a:hg['fg'] = a:colorname
endf

fun! s:set_bg(hg, colorname)
  let a:hg['bg'] = a:colorname
endf

fun! s:set_sp(hg, colorname)
  let a:hg['sp'] = a:colorname
endf

fun! s:has_term_attr(hg)
  return !empty(a:hg['term'])
endf

fun! s:has_term_italic(hg)
  return a:hg['term_italic']
endf

fun! s:has_gui_italic(hg)
  return a:hg['gui_italic']
endf

fun! s:has_gui_attr(hg)
  return !empty(a:hg['gui'])
endf

fun! s:add_term_attr(hg, attrlist)
  for l:a in a:attrlist
    if l:a ==? 'italic'
      let a:hg['term_italic'] = 1
    else
      call add(a:hg['term'], l:a)
    endif
  endfor
  call uniq(sort(a:hg['term']))
endf

fun! s:add_gui_attr(hg, attrlist)
  for l:a in a:attrlist
    if l:a ==? 'italic'
      let a:hg['gui_italic'] = 1
    else
      call add(a:hg['gui'], l:a)
    endif
  endfor
  call uniq(sort(a:hg['gui']))
endf
" }}}
" Colorscheme metadata {{{
fun! s:init_metadata()
  let s:supports_dark = 0
  let s:supports_light = 0
  let s:info = {
        \ 'fullname': '',
        \ 'shortname': '',
        \ 'author': '',
        \ 'maintainer': '',
        \ 'website': '',
        \ 'description': '',
        \ 'license': '',
        \ 'optionprefix': ''
        \ }
endf

fun! s:supports_dark_and_light()
  return s:supports_dark && s:supports_light
endf

fun! s:set_supports_dark()
  let s:supports_dark = 1
endf

fun! s:set_supports_light()
  let s:supports_light = 1
endf

fun! s:get_info(key)
  return s:info[a:key]
endf

fun! s:set_info(key, value)
  if !has_key(s:info, a:key)
    throw 'Unknown key: ' . a:key
  endif
  if type(a:value) != type('')
    throw "FATAL: key value must be a String (set_info)" " Should never happen
  endif
  let s:info[a:key] = a:value
  if a:key ==# 'shortname'
    if empty(a:value)
      throw 'Missing value for short name key'
    elseif len(a:value) > 24
      throw 'The short name must be at most 24 characters long'
    elseif a:value !~? '\m^\w\+$'
      throw 'The short name may contain only letters, numbers and underscore'
    endif
    if empty(s:info['optionprefix'])
      let s:info['optionprefix'] = s:info['shortname']
    endif
  elseif a:key ==# 'optionprefix'
    if empty(a:value)
      throw 'Missing value for option prefix key'
    elseif len(a:value) > 24
      throw 'The option prefix must be at most 24 characters long'
    elseif a:value !~? '\m\w\+$'
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
" }}}
" Colorscheme definition {{{
let s:GUI = '65536' " GUI or termguicolors

fun! s:init_colorscheme_definition()
  let s:data = {
        \ 'global': { 'any': [] },
        \ s:GUI: { 'dark': [], 'light': [], 'any': [] },
        \ '256': { 'dark': [], 'light': [], 'any': [] },
        \ }
  let s:italics = {
        \ 'global' : { 'any': [] },
        \ s:GUI: { 'dark': [], 'light': [], 'any': [] },
        \ '256': { 'dark': [], 'light': [], 'any': [] },
        \ }
  let s:uses_italics = 0
  let s:variants = ['global']
  let s:has_dark = 0
  let s:has_light = 0
  let s:t_Co = ['256']
endf

fun! s:is_preamble()
  return s:variants[0] ==# 'global'
endf

fun! s:has_dark_and_light()
  return s:has_dark && s:has_light
endf

fun! s:has_dark()
  return s:has_dark
endf

fun! s:has_light()
  return s:has_light
endf

fun! s:set_has_dark()
  let s:has_dark = 1
endf

fun! s:set_has_light()
  let s:has_light = 1
endf

fun! s:variants()
  return s:variants
endf

fun! s:set_default_variants()
  let s:variants = [s:GUI, '256']
endf

fun! s:uses_italics()
  return s:uses_italics
endf

fun! s:set_variants(defs)
  let s:variants = []
  for l:d in a:defs
    if l:d ==# 'gui' || str2nr(l:d) > 256
      let l:d = s:GUI
    elseif str2nr(l:d) < 1
      throw "Expected number or the keyword 'gui'"
    endif
    call add(s:variants, l:d)
    if !has_key(s:data, l:d)
      let s:data[l:d] = { 'dark': [], 'light': [], 'any': [] }
      let s:italics[l:d] = { 'dark': [], 'light': [], 'any': [] }
      if l:d !=# s:GUI
        call add(s:t_Co, l:d)
      endif
    endif
  endfor
endf

fun! s:global_preamble()
  return s:data['global']['any']
endf

fun! s:gui_preamble()
  return s:data[s:GUI]['any']
endf

fun! s:preamble(col)
  return s:data[a:col]['any']
endf

fun! s:colorscheme_definition(col, background)
  return s:data[a:col][a:background]
endf

fun! s:supported_t_Co()
  return reverse(sort(s:t_Co, 'N'))
endf

fun! s:min_t_Co()
  return min(s:t_Co)
endf

fun! s:add_verbatim(line)
  for l:d in s:variants()
    call add(s:data[l:d][s:current_bg()], ['verb', a:line])
  endfor
endf

fun! s:add_linked_group(source, target)
  for l:d in s:variants()
    call add(s:data[l:d][s:current_bg()], ['link', [a:source, a:target]])
  endfor
endf

fun! s:add_highlight_group(hg)
  if s:hi_name(a:hg) ==? 'Normal' " Normal group needs special treatment
    call s:assert_valid_normal_hi_group_def(a:hg)
  endif
  if s:is_preamble()
    throw "Cannot define highlight group before Variant or Background is set"
  endif
  for l:d in s:variants()
    call add(s:data[l:d][s:current_bg()], ['group', a:hg])
  endfor
  if s:has_term_italic(a:hg)
    let s:uses_italics = 1
    for l:d in s:supported_t_Co()
      call add(s:italics[l:d][s:current_bg()], ['it', s:hi_name(a:hg)])
    endfor
  endif
  if s:has_gui_italic(a:hg)
    let s:uses_italics = 1
    call add(s:italics[s:GUI][s:current_bg()], ['it', s:hi_name(a:hg)])
  endif
endf

" Add italics definitions accumulated so far to the colorscheme at the current point
fun! s:flush_italics()
  for l:d in s:variants()
    let l:bg = s:current_bg()
    if empty(s:italics[l:d][l:bg])
      continue
    endif
    call add(s:data[l:d][l:bg], ['verb', 'if s:italics'])
    call extend(s:data[l:d][l:bg], s:italics[l:d][l:bg])
    call add(s:data[l:d][l:bg], ['verb', 'endif'])
    let s:italics[l:d][l:bg] = []
  endfor
endf
  " }}}
  " Aux files {{{
  fun! s:init_aux_files()
    let s:auxfiles = {}    " Mappings from paths to list of lines
    let s:help_path = ''
  endf

  " path: path of the aux file as specified in the template
  fun! s:register_aux_file(path)
    if !has_key(s:auxfiles, a:path)
      let s:auxfiles[a:path] = []
    endif
    return a:path
  endf

  fun! s:register_help_file()
    if empty(s:help_path)
      if empty(s:shortname())
        throw "The colorscheme's short name must be defined before the first documentation block"
      endif
      let s:help_path = 'doc' . s:slash() . s:shortname() . '.txt'
    endif
    if !has_key(s:auxfiles, s:help_path)
      let s:auxfiles[s:help_path] = []
    endif
    return s:help_path
  endf

  fun! s:help_path()
    return s:help_path
  endf

  fun! s:add_line_to_aux_file(line, path)
    call add(s:auxfiles[a:path], a:line)
  endf

  fun! s:auxfile_paths()
    return keys(s:auxfiles)
  endf

  fun! s:auxfile(path)
    return s:auxfiles[a:path]
  endf
  " }}}
  " Init data structures {{{
  fun! s:init_data_structures()
    call s:init_source_code()
    call s:init_color_palette()
    call s:init_term_colors()
    call s:init_highlight_groups()
    call s:init_metadata()
    call s:init_colorscheme_definition()
    call s:init_aux_files()
  endf
  " }}}
  " }}}
  " Interpolation {{{
  fun! s:interpolate(line)
    let l:t_Co = s:min_t_Co()
    let l:line = substitute(a:line, '@term16\(\w\+\)',                '\=s:col16(submatch(1))',                          'g')
    let l:line = substitute(l:line, '@term256\(\w\+\)',               '\=s:col256(submatch(1))',                         'g')
    let l:line = substitute(l:line, '@term\(\w\+\)',                  '\=s:termcol(submatch(1),'.l:t_Co.')',             'g')
    let l:line = substitute(l:line, '@gui\(\w\+\)',                   '\=s:guicol(submatch(1))',                         'g')
    let l:line = substitute(l:line, '\(term[bf]g=\)@\(\w\+\)',        '\=submatch(1).s:termcol(submatch(2),'.l:t_Co.')', 'g')
    let l:line = substitute(l:line, '\(gui[bf]g=\|guisp=\)@\(\w\+\)', '\=submatch(1).s:guicol(submatch(2))',             'g')
    let l:line = substitute(l:line, '@\(\a\+\)',                      '\=s:get_info(submatch(1))',                       'g')
    return l:line
  endf
  " }}}
  " Parsing {{{
  " Tokenizer {{{
  " Current token in the currently parsed line
  fun! s:init_tokenizer()
    return 1
  endf

  let s:token = { 'spos' :  0, 'pos'  :  0, 'value': '', 'kind' : '' }

  fun! s:token.reset() dict
    let self.spos  = 0
    let self.pos   = 0
    let self.value = ''
    let self.kind  = ''
  endf

  fun! s:token.next() dict
    let [l:char, self.spos, self.pos] = matchstrpos(s:getl(), '\s*\zs\S', self.pos) " Get first non-white character starting at pos
    if empty(l:char)
      let self.kind = 'EOL'
      let self.spos = len(s:getl()) - 1 " For correct error location
    elseif l:char =~? '\m\a'
      let [self.value, self.spos, self.pos] = matchstrpos(s:getl(), '\w\+', self.pos - 1)
      let self.kind = 'WORD'
    elseif l:char =~# '\m[0-9]'
      let [self.value, self.spos, self.pos] = matchstrpos(s:getl(), '\d\+', self.pos - 1)
      let self.kind = 'NUM'
    elseif l:char ==# '#'
      if match(s:getl(), '^[0-9a-f]\{6}', self.pos) > -1
        let [self.value, self.spos, self.pos] = matchstrpos(s:getl(), '#[0-9a-f]\{6}', self.pos - 1)
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
  " Included files {{{
  fun! s:init_includes()
    let s:input_stack = []
    let s:includes_stack = []
    let s:path = ''
    let s:linenr = 0
    let s:numlines = 0
    let s:currline = ''
    let s:cache = {}
  endf

  fun! s:include(path)
    " Save current position in the stack
    call s:push(s:includes_stack, { 'path': s:path, 'linenr': s:linenr, 'numlines': s:numlines })
    let s:path = s:full_path(a:path, { 'dir': s:getwd() })
    let s:linenr = 0
    if !has_key(s:cache, s:path)
      let s:cache[s:path] = { 'data': reverse(readfile(fnameescape((s:path)))) }
    endif
    let s:numlines = len(s:cache[s:path]['data'])
    call extend(s:input_stack, s:cache[s:path]['data'])
  endf

  fun! s:currfile()
    return s:path
  endf

  fun! s:getl()
    return s:currline
  endf

  fun! s:linenr()
    return s:linenr
  endf

  " Move to the next line. Returns 0 if at eof, 1 otherwise.
  fun! s:next_line()
    if empty(s:input_stack)
      return 0
    endif
    let s:linenr += 1
    while s:linenr > s:numlines
      " Restore position from the stack
      let l:tt = s:pop(s:includes_stack)
      let s:path = l:tt.path
      let s:linenr = l:tt.linenr + 1
      let s:numlines = l:tt.numlines
    endwhile
    let s:currline = s:pop(s:input_stack)
    call s:token.reset()
    return 1
  endf
  " }}}
  " Verbatim {{{
  fun! s:init_verbatim()
    let s:verb_block = 0
  endf

  fun! s:start_verbatim()
    let s:verb_block = 1
  endf

  fun! s:stop_verbatim()
    let s:verb_block = 0
  endf

  fun! s:is_verbatim()
    return s:verb_block
  endf
  " }}}
  " Aux files {{{
  fun! s:init_auxfiles_parsing()
    let s:is_aux = 0
    let s:is_help = 0
    let s:current_auxfile = ''
  endf

  " path: path of the aux file as specified in the template
  fun! s:start_aux_file(path)
    let s:current_auxfile = s:register_aux_file(a:path)
    let s:is_aux = 1
  endf

  fun! s:stop_aux_file()
    let s:is_aux = 0
    let s:current_auxfile = ''
  endf

  fun! s:is_aux_file()
    return s:is_aux
  endf

  fun! s:start_help_file()
    let s:current_auxfile = s:register_help_file()
    let s:is_help = 1
  endf

  fun! s:is_help_file()
    return s:is_help
  endf

  fun! s:stop_help_file()
    let s:is_help = 0
    let s:current_auxfile = ''
  endf

  fun! s:add_to_aux_file(line)
    call s:add_line_to_aux_file(a:line, s:current_auxfile)
  endf
  " }}}
  " Parser {{{
  fun! s:parse_verbatim_line()
    if s:getl() =~? '\m^\s*endverbatim'
      call s:stop_verbatim()
      if s:getl() !~? '\m^\s*endverbatim\s*$'
        throw "Extra characters after 'endverbatim'"
      endif
    else
      call s:add_verbatim(s:getl())
    endif
  endf

  fun! s:parse_help_line()
    if s:getl() =~? '\m^\s*enddocumentation'
      call s:stop_help_file()
      if s:getl() !~? '\m^\s*enddocumentation\s*$'
        throw "Extra characters after 'enddocumentation'"
      endif
    else
      call s:add_to_aux_file(s:getl())
    endif
  endf

  fun! s:parse_auxfile_line()
    if s:getl() =~? '\m^\s*endauxfile'
      call s:stop_aux_file()
      if s:getl() !~? '\m^\s*endauxfile\s*$'
        throw "Extra characters after 'endauxfile'"
      endif
    else
      call s:add_to_aux_file(s:getl())
    endif
  endf

  fun! s:parse_line()
    if s:token.next().kind ==# 'EOL' " Empty line
      return
    elseif s:token.kind ==# 'COMMENT'
      return s:parse_comment()
    elseif s:token.kind ==# 'WORD'
      if s:token.value ==? 'verbatim'
        call s:flush_italics()
        call s:start_verbatim()
        if s:token.next().kind !=# 'EOL'
          throw "Extra characters after 'verbatim'"
        endif
      elseif s:token.value ==? 'auxfile'
        let l:path = matchstr(s:getl(), '^\s*auxfile\s\+\zs.*')
        if empty(l:path)
          throw 'Missing path'
        endif
        call s:start_aux_file(s:interpolate(l:path))
      elseif s:token.value ==? 'documentation'
        call s:start_help_file()
      elseif s:getl() =~? '\m:' " Look ahead
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
      call s:add_source_line(s:getl())
      call s:parse_color_def()
    else " Generic key-value pair
      let l:key_tokens = [s:token.value]
      while s:token.next().kind !=# ':'
        if s:token.kind !=# 'WORD' || s:token.value !~? '\m^\h\+$'
          throw 'Only letters from a to z and underscores are allowed in keys'
        endif
        call add(l:key_tokens, s:token.value)
      endwhile
      let l:key = tolower(join(l:key_tokens, ''))
      let l:val = matchstr(s:getl(), '\s*\zs.*$', s:token.pos)
      if l:key ==# 'background'
        call s:add_source_line(s:getl())
        if s:is_preamble()
          call s:set_default_variants()
        endif
        if l:val =~? '\m^dark\s*$'
          call s:set_active_bg('dark')
          call s:set_has_dark()
        elseif l:val =~? '\m^light\s*$'
          call s:set_active_bg('light')
          call s:set_has_light()
        elseif l:val =~? '\m^any\s*$'
          call s:reset_backgrounds()
        else
          throw "Background can only be 'dark', 'light' or 'any'"
        endif
      elseif l:key ==# 'variant'
        call s:add_source_line(s:getl())
        let l:defs = split(tolower(l:val))
        call s:set_variants(l:defs)
      elseif l:key ==# 'terminalcolors'
        call s:add_warning(s:currfile(), s:linenr(), s:token.pos,
              \ "The 'Terminal colors' key has been deprecated and is a no-op now")
      elseif l:key ==# 'termcolors'
        call s:add_source_line(s:getl())
        call s:parse_term_colors(l:val)
      elseif l:key ==# 'include'
        call s:include(l:val)
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
    let l:col_256   = s:parse_base_256_value()
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
      return colortemplate#colorspace#rgbname2hex(tolower(l:rgb_name))
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

  fun! s:parse_base_256_value()
    if s:token.next().kind ==# '~'
      return -1
    elseif s:token.kind ==# 'NUM'
      let l:val = str2nr(s:token.value)
      if l:val < 16
        throw 'Base-256 color value must be >=16'
      endif
      let l:t_Co = str2nr(s:min_t_Co())
      if l:t_Co > 16 && l:val + 1 > l:t_Co
        throw 'Color value is out of range [16,'.string(l:t_Co - 1).']'
      endif
      return l:val
    endif
    throw 'Expected number or tilde'
  endf

  fun! s:parse_base_16_value()
    if s:token.next().kind ==# 'EOL' || s:token.kind ==# 'COMMENT'
      return 'Black' " Just a placeholder: we assume that base-16 colors are not used
    elseif s:token.kind ==# 'NUM'
      let l:val = str2nr(s:token.value)
      let l:b = min([16, str2nr(s:min_t_Co())])
      if l:val + 1 > l:b || l:val < 0
        throw 'Color value is out of range [0,'.string(l:b - 1).']'
      endif
      return l:val
    elseif s:token.kind ==# 'WORD'
      if index(g:colortemplate#colorspace#ansi_colors, tolower(s:token.value)) == -1
        throw "Invalid color name: " . s:token.value
      endif
      return s:token.value
    else
      throw 'Expected number or color name'
    endif
  endf

  fun! s:parse_term_colors(colors)
    let l:colors = split(a:colors)
    for l:color in l:colors
      if !s:is_color_defined(l:color)
        throw 'Undefined color name: ' . l:color
      endif
      call s:add_term_ansi_color(s:guicol(l:color))
    endfor
  endf

  fun! s:parse_hi_group_def()
    call s:add_source_line(s:getl())

    if s:getl() =~# '\m->' " Look ahead
      return s:parse_linked_group_def()
    endif

    " Base highlight group definition
    let l:hg = s:new_hi_group(s:token.value)
    " Foreground color
    if s:token.next().kind !=# 'WORD'
      throw 'Foreground color name missing'
    endif
    let l:colorname = s:parse_color_value()
    if l:colorname ==# 'bg'
      call s:add_warning(s:currfile(), s:linenr(), s:token.pos,
            \ "Using 'bg' may cause an error with transparent backgrounds")
    endif
    call s:set_fg(l:hg, l:colorname)
    " Background color
    if s:token.next().kind !=# 'WORD'
      throw 'Background color name missing'
    endif
    let l:colorname = s:parse_color_value()
    if l:colorname ==# 'bg'
      call s:add_warning(s:currfile(), s:linenr(), s:token.pos,
            \ "Using 'bg' may cause an error with transparent backgrounds")
    endif
    call s:set_bg(l:hg, l:colorname)
    let l:hg = s:parse_attributes(l:hg)
    call s:add_highlight_group(l:hg)
  endf

  fun! s:parse_color_value()
    let l:color = s:token.value
    if !s:is_color_defined(l:color) && l:color !~# '^\(fg\|bg\|none\)$'
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
      elseif s:token.value ==? 'start' || s:token.value ==? 'stop'
        " TODO: parse value
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
    " call s:add_linked_group_def(l:source_group, s:token.value)
    call s:add_linked_group(l:source_group, s:token.value)
  endf
  " }}} Parser
  " Init parser {{{
  fun! s:init_parser()
    call s:init_tokenizer()
    call s:init_includes()
    call s:init_verbatim()
    call s:init_auxfiles_parsing()
  endf
  " }}}
  " }}}
  " Initialize state {{{
  fun! s:init(work_dir)
    let g:colortemplate_exit_status = 0
    call setloclist(0, [], 'r') " Reset location list
    call s:setwd(a:work_dir)
    call s:init_data_structures()
    call s:init_parser()
  endf
  " }}}
  " OLD Internal state {{{
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

  " name:    A color name
  " gui:     GUI hex value (e.g., #c4fed6)
  " base256: Base-256 color number or -1
  " base16:  Base-16 color number or color name
  "
  " If base256 is -1, its value is inferred.
  " fun! s:add_color(name, gui, base256, base16)
  " Find an approximation and/or a distance from the GUI value if none was provided
  " if a:base256 < 0
  "   let l:approx_color = colortemplate#colorspace#approx(a:gui)
  "   let l:base256 = l:approx_color['index']
  "   let l:delta = l:approx_color['delta']
  " else
  "   let l:base256 = a:base256
  "   let l:delta = (l:base256 >= 16 && l:base256 <= 255
  "         \ ? colortemplate#colorspace#hex_delta_e(a:gui, g:colortemplate#colorspace#xterm256_hexvalue(l:base256))
  "         \ : 0.0 / 0.0)
  " endif
  " if s:background_undefined()
  "   " Assume color definitions common to both backgrounds
  "   let s:palette['dark' ][a:name] = [a:gui, l:base256, a:base16, l:delta]
  "   let s:palette['light'][a:name] = [a:gui, l:base256, a:base16, l:delta]
  " else
  "   " Assume color definition for the current background
  "   let s:palette[s:current_background()][a:name] = [a:gui, l:base256, a:base16, l:delta]
  " endif
  " endf


  " }}}
  " {{{ Color pairs
  " We keep track of pairs of colors used as a fg/bg combination.
  " Used for highlighting critical pairs in the various debugging matrices.
  fun! s:init_color_pairs()
    let s:fg_bg_pairs = { }
  endf

  fun! s:add_color_pair(fg, bg)
    let l:key = (a:fg < a:bg) ? a:fg.'/'.a:bg : a:bg.'/'.a:fg
    let s:fg_bg_pairs[l:key] = 1
  endf

  fun! s:has_color_pair(fg, bg)
    let l:key = (a:fg < a:bg) ? a:fg.'/'.a:bg : a:bg.'/'.a:fg
    return has_key(s:fg_bg_pairs, l:key)
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
    let s:normal_colors = { 'dark': { 'fg': [], 'bg': [] }, 'light': { 'fg': [], 'bg': [] } }
  endf

  fun! s:has_normal_group(background)
    return s:colorscheme['has_normal'][a:background]
  endf

  fun! s:add_linked_group_def(src, tgt)
    for l:numcol in s:terminalcolors()
      call add(s:colorscheme[l:numcol][s:current_background()],
            \ 'hi! link ' . a:src . ' ' . a:tgt)
    endfor
  endf

  " Adds the current highlight group to the colorscheme
  " This function must be called only after the background is defined
  " fun! s:add_highlight_group(hg)
  "   let l:bg = s:current_background()
  "   if s:hi_name(a:hg) ==# 'Normal' " Normal group needs special treatment
  "     if s:fg(a:hg) =~# '\m^\%(fg\|bg\)$' || (a:hg) =~# '\m^\%(fg\|bg\)$'
  "       throw "The colors for Normal cannot be 'fg' or 'bg'"
  "     endif
  "     if match(s:term_attr(a:hg), '\%(inv\|rev\)erse') > -1 || match(s:gui_attr(a:hg), '\%(inv\|rev\)erse') > -1
  "       throw "Do not use reverse mode for the Normal group"
  "     endif
  "     call add(s:normal_colors[l:bg]['fg'], s:fg(a:hg))
  "     call add(s:normal_colors[l:bg]['bg'], (a:hg))
  "     let s:colorscheme['has_normal'][l:bg] = 1
  "   endif
  "   call s:add_color_pair(s:fg(a:hg), (a:hg))
  "   for l:numcol in s:terminalcolors()
  "     let l:use16colors = (l:numcol == '16')
  "     call add(s:colorscheme[l:numcol][l:bg],
  "           \ join(['hi', s:hi_name(a:hg),
  "           \       'ctermfg='  . s:term_fg(a:hg, l:use16colors),
  "           \       'ctermbg='  . s:term_bg(a:hg, l:use16colors),
  "           \       'guifg='    . s:gui_fg(a:hg),
  "           \       'guibg='    . s:gui_bg(a:hg),
  "           \       'guisp='    . s:gui_sp(a:hg),
  "           \       'cterm=NONE'. (s:has_term_attr(a:hg) ? ',' . join(s:term_attr(a:hg), ',') : ''),
  "           \       'gui=NONE'  . (s:has_gui_attr(a:hg)  ? ',' . join(s:gui_attr(a:hg), ',')  : '')
  "           \ ])
  "           \ )
  "   endfor
  " endf

  " fun! s:print_colorscheme_preamble(use16colors)
  "   if !empty(s:colorscheme[a:use16colors ? '16' : '256']['preamble'])
  "     call append('$', s:colorscheme[a:use16colors ? '16' : '256']['preamble'])
  "     call s:put('')
  "   endif
  " endf

  " fun! s:print_colorscheme(background, use16colors)
  "   call append('$', s:colorscheme[a:use16colors ? '16' : '256'][a:background])
  " endf
  " }}}
  " }}} Internal state
  " Checks {{{
  fun! s:assert_valid_normal_hi_group_def(hg)
    if s:fg(a:hg) =~# '\m^\%(fg\|bg\)$' || s:bg(a:hg) =~# '\m^\%(fg\|bg\)$'
      throw "The colors for Normal cannot be 'fg' or 'bg'"
    endif
    if match(s:term_attr(a:hg), '\%(inv\|rev\)erse') > -1 || match(s:gui_attr(a:hg), '\%(inv\|rev\)erse') > -1
      throw "Do not use reverse mode for Normal"
    endif
    " FIXME: reinstante these
    " call add(s:normal_colors[l:bg]['fg'], s:fg(a:hg))
    " call add(s:normal_colors[l:bg]['bg'], (a:hg))
    " let s:colorscheme['has_normal'][l:bg] = 1
  endf

  fun! s:assert_valid_color_name(name)
    if a:name ==? 'none' || a:name ==? 'fg' || a:name ==? 'bg'
      throw "Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden"
    endif
    if s:is_color_defined(a:name)
      throw "Color already defined for " . s:default_bg() . " background"
    endif
    " TODO: check that color name starts with alphabetic char?
    return 1
  endf

  fun! s:assert_requirements()
    if empty(s:fullname())
      call s:add_generic_error('Please specify the full name of your color scheme')
    endif
    if empty(s:shortname())
      call s:add_generic_error('Please specify the short name of your color scheme')
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
  endf

  " Checks to be performed on the generated colorscheme code
  fun! s:postcheck()
    if get(g:, 'colortemplate_no_warnings', 0)
      return
    endif
    call cursor(1,1)
    " Check for missing highlight groups
    for l:hg in s:default_hi_groups
      if !search('\%(hi\|hi! link\) \<'.l:hg.'\>', 'nW')
        call s:add_generic_warning('No definition for ' . l:hg . ' highlight group')
      endif
    endfor
    " Were debugPC and debugBreakpoint defined? (They shouldn't: see :h colortemplate-best-practices)
    for l:hg in ['debugPC', 'debugBreakpoint']
      if search('\%(hi\|hi! link\) \<'.l:hg.'\>', 'nW')
        call s:add_generic_warning('A colorscheme should not define plugin-specific highlight groups: ' . l:hg )
      endif
    endfor
    " Is g:terminal_ansi_colors defined?
    if !search('g:terminal_ansi_colors','nW')
      call s:add_generic_warning('g:terminal_ansi_colors is not defined (see :help g:terminal_ansi_colors)')
    endif
    if !empty(getloclist(0))
      lopen
    endif
  endf
  " }}}
  " Colorscheme generation {{{
  fun! s:generate_aux_files(outdir, overwrite)
    if get (g:, 'colortemplate_no_aux_files', 0)
      return
    endif
    for l:path in keys(s:auxfiles)
      if match(l:path, '^doc' . s:slash()) > -1 " Help file
        if get(g:, 'colortemplate_no_doc', 0)
          continue
        endif
        silent bot new +setlocal\ tw=78\ noet\ ts=8\ sw=8\ ft=help\ norl
        call append(0, s:auxfiles[l:path])
        " TODO: interpolate
        " try " to interpolate variables
        "   let l:line = s:interpolate(a:line, s:prefer16colors())
        " catch /.*/
        "   throw 'Undefined keyword'
        " endtry
      else                                      " Other aux files
        if fnamemodify(l:path, ":e") ==# 'vim'
          silent bot new +setlocal\ ft=vim\ et\ ts=2\ sw=2\ norl\ nowrap
        else
          silent bot new +setlocal\ et\ ts=2\ sw=2\ norl\ nowrap
        endif
        call append(0, s:auxfiles[l:path])
      endif
      if !empty(a:outdir)
        call s:write_buffer(l:path, { 'dir': a:outdir }, a:overwrite)
      endif
    endfor
  endf

  fun! s:eval(item, col)
    if a:item[0] ==# 'verb'
      return s:interpolate(a:item[1])
    elseif a:item[0] ==# 'link'
      return 'hi! link ' . a:item[1][0] . ' ' . a:item[1][1]
    elseif a:item[0] ==# 'group'
      let l:hg = a:item[1]
      if a:col > 256
        return 'hi ' . s:hi_name(l:hg)
              \ . ' guifg='.s:guifg(l:hg)
              \ . ' guibg='.s:guibg(l:hg)
              \ . ' guisp='.s:guisp(l:hg)
              \ . ' gui='.s:gui_attr(l:hg)
              \ . ' cterm='.s:term_attr(l:hg) " See https://github.com/vim/vim/issues/1740
      elseif a:col > 16
        return 'hi ' . s:hi_name(l:hg)
              \ . ' ctermfg='.s:fg256(l:hg)
              \ . ' ctermbg='.s:bg256(l:hg)
              \ . ' cterm='.s:term_attr(l:hg) " Need to set even for termguicolors (see https://github.com/vim/vim/issues/1740)
              \ . (empty(l:hg['start']) ? '' : ' start='.l:hg['start'])
              \ . (empty(l:hg['stop']) ? '' : ' stop='.l:hg['start'])
      elseif a:col > 2
        return 'hi ' . s:hi_name(l:hg)
              \ . ' ctermfg='.s:fg16(l:hg)
              \ . ' ctermbg='.s:bg16(l:hg)
              \ . ' cterm='.s:term_attr(l:hg)
              \ . (empty(l:hg['start']) ? '' : ' start='.l:hg['start'])
              \ . (empty(l:hg['stop']) ? '' : ' stop='.l:hg['start'])
      elseif a:col > 0
        return 'hi ' . s:hi_name(l:hg)
              \ . ' term='.s:term_attr(l:hg)
              \ . (empty(l:hg['start']) ? '' : ' start='.l:hg['start'])
              \ . (empty(l:hg['stop']) ? '' : ' stop='.l:hg['start'])
      endif
    elseif a:item[0] ==# 'it'
      if a:col > 256
        return 'hi ' . a:item[1] . ' gui=italic'
      else
        return 'hi ' . a:item[1] . (a:col > 2 ? ' c' : ' ') . 'term=italic'
      endif
    else
      throw 'FATAL: unknown item type' " This should never happen!
    endif
  endf

  " Append a String to the end of the current buffer.
  fun! s:put(bufnr, line)
    call appendbufline(a:bufnr, '$', a:line)
  endf

  fun! s:print_header(bufnr)
    call setbufline(a:bufnr, 1, '" Name:         ' . s:fullname()                )
    if !empty(s:description()                                                    )
      call s:put(a:bufnr,       '" Description:  ' . s:description()             )
    endif
    call s:put  (a:bufnr,       '" Author:       ' . s:author()                  )
    call s:put  (a:bufnr,       '" Maintainer:   ' . s:maintainer()              )
    if !empty(s:website()                                                        )
      call s:put(a:bufnr,       '" Website:      ' . s:website()                 )
    endif
    call s:put  (a:bufnr,       '" License:      ' . s:license()                 )
    call s:put  (a:bufnr,       '" Last Updated: ' . strftime("%c")              )
    call s:put  (a:bufnr,       ''                                               )
    call s:put  (a:bufnr,       '" Generated by Colortemplate v' . s:VERSION     )
    call s:put  (a:bufnr,       ''                                               )
    if !s:has_light()
      call s:put(a:bufnr, 'set background=dark')
      call s:put(a:bufnr, ''                                                     )
    elseif !s:has_dark()
      call s:put(a:bufnr, 'set background=light')
      call s:put(a:bufnr, ''                                                     )
    endif
    call s:put  (a:bufnr, 'hi clear'                                             )
    call s:put  (a:bufnr, "if exists('syntax_on')"                               )
    call s:put  (a:bufnr, '  syntax reset'                                       )
    call s:put  (a:bufnr, 'endif'                                                )
    call s:put  (a:bufnr, ''                                                     )
    call s:put  (a:bufnr, "let g:colors_name = '" . s:shortname() . "'"          )
    call s:put  (a:bufnr, ''                                                     )
    call s:put  (a:bufnr, "let s:t_Co = exists('&t_Co') && !empty(&t_Co) ? &t_Co : 1")
    call s:put  (a:bufnr, "let s:term_256_colors = exists('&t_Co') && &t_Co == 256")
    if s:uses_italics()
      " FIXME: make nvim conditional
      call s:put(a:bufnr, "let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || (has('gui_running') && !has('iOS')) || has('nvim')")
    endif
  endf

  fun! s:print_terminal_colors(bufnr)
    let l:tc = s:term_colors()
    if empty(l:tc)
      call s:add_generic_warning("'Term Colors' key missing for " . s:default_bg() . ' background')
      return
    endif
    if len(l:tc) < 16
      throw 'Too few terminal ANSI colors (' . s:default_bg() . ' background)'
    endif
    if len(l:tc) > 16
      throw 'Too many terminal ANSI colors (' . s:default_bg() . ' background)'
    endif
    let l:col0_6 = join(map(copy(l:tc[0:6]), { _,c -> "'".c."'" }), ', ')
    let l:col7_15 = join(map(copy(l:tc[7:15]), { _,c -> "'".c."'" }), ', ')
    call s:put(a:bufnr, 'let g:terminal_ansi_colors = [' . l:col0_6)
    call s:put(a:bufnr, '\ ' . l:col7_15 . ']')
    " TODO: make NVIM support conditional
    call s:put(a:bufnr, "if has('nvim')")
    let l:n = 0
    for l:color in l:tc
      call s:put(a:bufnr, "let g:terminal_color_".string(l:n)." = '".l:color."'")
      let l:n += 1
    endfor
    call s:put(a:bufnr, 'endif')
  endf

  fun! s:finish_endif(bufnr)
    call s:put(a:bufnr, 'unlet s:t_Co s:term_256_colors' . (s:uses_italics() ? ' s:italics' : ''))
    call s:put(a:bufnr, 'finish')
    call s:put(a:bufnr, 'endif')
  endf

  fun! s:generate_colorscheme(outdir, overwrite)
    1new +setlocal\ ft=vim\ et\ ts=2\ sw=2\ norl\ nowrap
    let l:bufnr = bufnr("%")
    wincmd c
    call s:set_active_bg(s:has_dark() ? 'dark' : 'light')
    call s:print_header(l:bufnr)

    " Preamble
    if !empty(s:global_preamble())
      call s:put(l:bufnr, '')
      for l:item in s:global_preamble()
        call s:put(l:bufnr, s:eval(l:item, 0))
      endfor
    endif

    " GUI colors
    call s:put(l:bufnr, '')
    call s:put(l:bufnr, "if (has('termguicolors') && &termguicolors) || has('gui_running')")
    for l:item in s:gui_preamble()
      call s:put(l:bufnr, s:eval(l:item, str2nr(s:GUI)))
    endfor
    if s:has_dark_and_light()
      call s:set_active_bg('dark')
      call s:put(l:bufnr, "if &background ==# 'dark'")
      call s:print_terminal_colors(l:bufnr)
      for l:item in s:colorscheme_definition(s:GUI, 'dark')
        call s:put(l:bufnr, s:eval(l:item, str2nr(s:GUI)))
      endfor
      call s:finish_endif(l:bufnr)
      call s:set_active_bg('light')
    endif
    call s:print_terminal_colors(l:bufnr)
    for l:item in s:colorscheme_definition(s:GUI, s:default_bg())
      call s:put(l:bufnr, s:eval(l:item, str2nr(s:GUI)))
    endfor
    call s:finish_endif(l:bufnr)

    " Terminal colors
    call s:set_active_bg(s:has_dark() ? 'dark' : 'light')
    for l:t_Co in s:supported_t_Co()
      let l:ncols = str2nr(l:t_Co)
      call s:put(l:bufnr, '')
      call s:put(l:bufnr, 'if s:t_Co >= ' . l:t_Co)
      for l:item in s:preamble(l:t_Co)
        call s:put(l:bufnr, s:eval(l:item, l:ncols))
      endfor
      if s:has_dark_and_light()
        call s:set_active_bg('dark')
        call s:put(l:bufnr, "if &background ==# 'dark'")
        for l:item in s:colorscheme_definition(l:t_Co, 'dark')
          call s:put(l:bufnr, s:eval(l:item, l:ncols))
        endfor
        call s:finish_endif(l:bufnr)
        call s:set_active_bg('light')
      endif
      for l:item in s:colorscheme_definition(l:t_Co, s:default_bg())
        call s:put(l:bufnr, s:eval(l:item, l:ncols))
      endfor
      call s:finish_endif(l:bufnr)
    endfor
    call s:put(l:bufnr, '')

    " Print source as comment, for provenance
    for l:line in s:source_lines()
      call s:put(l:bufnr, '" '.l:line)
    endfor
    " Reindent
    execute l:bufnr 'bufdo norm gg=G'
    " Save
    if !empty(a:outdir)
      let l:outpath = a:outdir . s:slash() . 'colors' . s:slash() . s:shortname() . '.vim'
      call s:write_buffer(l:bufnr, l:outpath, { 'dir': a:outdir }, a:overwrite)
      redraw
      echo "\r"
      echomsg "[Colotemplate] File written to" l:outpath
      " echomsg '[Colortemplate] Colorscheme created!'
      " execute l:bufnr 'bwipe!'
    endif
    " call s:postcheck() " TODO: move to a 'validate' function that also calls VIm's own check script
  endf
  " }}}
  " Stats {{{
  " Print details about the color palette for the specified background as comments
  fun! s:print_similarity_table(bg)
    call s:put('{{{ Color Similarity Table (' . a:bg . ' background)')
    let l:palette = s:palette(a:bg)
    " Find maximum length of color names (used for formatting)
    let l:len = max(map(copy(l:palette), { k,_ -> len(k)}))
    " Sort colors by increasing delta
    let l:color_names = keys(l:palette)
    call sort(l:color_names, { c1,c2 ->
          \ s:isnan(l:palette[c1][3])
          \      ? (s:isnan(l:palette[c2][3]) ? 0 : 1)
    : (s:isnan(l:palette[c2][3]) ? -1 : (l:palette[c1][3] < l:palette[c2][3] ? -1 : (l:palette[c1][3] > l:palette[c2][3] ? 1 : 0)))
          \ })
    for l:color in l:color_names
      if l:color =~? '\m^\%(fg\|bg\|none\)$'
        continue
      endif
      let l:colgui = l:palette[l:color][0]
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
      let l:fmt = '%'.l:len.'s: GUI=%s/rgb(%3d,%3d,%3d)  Term=%3d %s  [delta=%f]'
      call s:put(printf(l:fmt, l:color, l:colgui, l:rgbgui[0], l:rgbgui[1], l:rgbgui[2], l:col256, l:def256, l:delta))
    endfor
    call s:put('}}} Color Similarity Table')
  endf

  " Adds the contrast matrix for the specified background to the current buffer.
  fun! s:print_contrast_matrix(bg)
    let [l:colors, l:labels] = [{'gui': [], 'term': []}, []]
    for l:key in sort(keys(s:palette(a:bg)))
      if l:key != 'fg' && l:key != 'bg' && l:key != 'none'
        let l:val = s:palette(a:bg)[l:key]
        call add(l:labels, l:key)
        call add(l:colors['gui'], l:val[0])
        call add(l:colors['term'], colortemplate#colorspace#xterm256_hexvalue(l:val[1]))
      endif
    endfor
    call s:put('{{{ Contrast Ratio Matrix (' . a:bg . ' background)')
    call s:put('')
    call s:put('Pairs of colors with contrast ≥4.5 can be safely used as a fg/bg combo')
    call s:put('')
    call s:put("█ Not W3C conforming   █ Not ISO-9241-3 conforming")
    call s:put('')
    for l:type in ['gui', 'term']
      let l:M = colortemplate#colorspace#contrast_matrix(l:colors[l:type])
      call s:put('{{{ '.(l:type ==# 'gui' ? 'GUI (exact)' : 'Terminal (approximate)'))
      call s:put("\t".join(l:labels, "\t"))
      for l:i in range(len(l:M))
        call s:put(l:labels[l:i]."\t".join(map(l:M[l:i], { j,v -> j ==# l:i ? '' : printf("%5.02f", v) }), "\t")."\t".l:labels[l:i])
      endfor
      call s:put("\t".join(l:labels, "\t"))
      call s:put('}}}')
    endfor
    call s:put('}}} Contrast Ratio Matrix')
  endf

  fun! s:print_color_difference_matrix(bg)
    let [l:colors, l:labels] = [{'gui': [], 'term': []}, []]
    for l:key in sort(keys(s:palette(a:bg)))
      if l:key != 'fg' && l:key != 'bg' && l:key != 'none'
        let l:val = s:palette(a:bg)[l:key]
        call add(l:labels, l:key)
        call add(l:colors['gui'], l:val[0])
        call add(l:colors['term'], colortemplate#colorspace#xterm256_hexvalue(l:val[1]))
      endif
    endfor
    call s:put('{{{ Color Difference Matrix (' . a:bg . ' background)')
    call s:put('')
    call s:put('Pairs of colors whose color difference is ≥500 can be safely used as a fg/bg combo')
    call s:put('')
    for l:type in ['gui', 'term']
      let l:M = colortemplate#colorspace#coldiff_matrix(l:colors[l:type])
      call s:put('{{{ '.(l:type ==# 'gui' ? 'GUI (exact)' : 'Terminal (approximate)'))
      call s:put("\t".join(l:labels, "\t"))
      for l:i in range(len(l:M))
        call s:put(l:labels[l:i]."\t".join(map(l:M[l:i], { j,v -> j ==# l:i ? '' : printf("%5.01f", v) }), "\t")."\t".l:labels[l:i])
      endfor
      call s:put("\t".join(l:labels, "\t"))
      call s:put('}}}')
    endfor
    call s:put('}}} Color Difference Matrix')
  endf

  fun! s:print_brightness_difference_matrix(bg)
    let [l:colors, l:labels] = [{'gui': [], 'term': []}, []]
    for l:key in sort(keys(s:palette(a:bg)))
      if l:key != 'fg' && l:key != 'bg' && l:key != 'none'
        let l:val = s:palette(a:bg)[l:key]
        call add(l:labels, l:key)
        call add(l:colors['gui'], l:val[0])
        call add(l:colors['term'], colortemplate#colorspace#xterm256_hexvalue(l:val[1]))
      endif
    endfor
    call s:put('{{{ Brightness Difference Matrix (' . a:bg . ' background)')
    call s:put('')
    call s:put('Pairs of colors whose brightness difference is ≥125 can be safely used as a fg/bg combo')
    call s:put('')
    for l:type in ['gui', 'term']
      let l:M = colortemplate#colorspace#brightness_diff_matrix(l:colors[l:type])
      call s:put('{{{ '.(l:type ==# 'gui' ? 'GUI (exact)' : 'Terminal (approximate)'))
      call s:put("\t".join(l:labels, "\t"))
      for l:i in range(len(l:M))
        call s:put(l:labels[l:i]."\t".join(map(l:M[l:i], { j,v -> j ==# l:i ? '' : printf("%5.01f", v) }), "\t")."\t".l:labels[l:i])
      endfor
      call s:put("\t".join(l:labels, "\t"))
      call s:put('}}}')
    endfor
    call s:put('}}} Brightness Difference Matrix')
  endf

  fun! s:print_color_info()
    silent tabnew +setlocal\ buftype=nofile\ foldmethod=marker\ noet\ norl\ noswf\ nowrap
    set ft=colortemplate-info
    " Find maximum length of color names (used for formatting)
    let l:labels = keys(s:palette('dark')) + keys(s:palette('light'))
    let l:tw = 2 + max(map(l:labels, { _,v -> len(v)}))
    execute 'setlocal tabstop='.l:tw 'shiftwidth='.l:tw

    call append(0, 'Color information about ' . s:fullname())
    let l:backgrounds = s:has_dark_and_light() ? ['dark', 'light'] : [s:current_background()]
    for l:bg in l:backgrounds
      if s:has_dark_and_light()
        call s:put('{{{ '.l:bg.' background')
        call s:put('')
      endif
      call s:print_similarity_table(l:bg)
      call s:put('')
      call s:print_contrast_matrix(l:bg)
      call s:put('')
      call s:print_brightness_difference_matrix(l:bg)
      call s:put('')
      call s:print_color_difference_matrix(l:bg)
      call s:put('')
      if s:has_dark_and_light()
        call s:put('}}}')
      endif
    endfor
  endf
  " }}}
  " Public interface {{{
  fun! colortemplate#parse(filename) abort
    call s:init(fnamemodify(a:filename, ":h"))
    call s:include(a:filename)
    while s:next_line()
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
        call s:add_error(s:currfile(), s:linenr(), s:token.spos + 1, v:exception)
        throw 'Parse error'
      catch /.*/
        call s:add_error(s:currfile(), s:linenr(), s:token.spos + 1, v:exception)
      endtry
    endwhile

    " call s:assert_requirements()

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
    let l:outdir = (a:0 > 0 && !empty(a:1) ? simplify(fnamemodify(a:1, ':p')) : getcwd())
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
      return
    catch /.*/
      echoerr '[Colortemplate] Unexpected error: ' v:exception
      let g:colortemplate_exit_status = 1
      return
    endtry

    try
      call s:generate_colorscheme(l:outdir, l:overwrite)
      " call s:generate_aux_files(l:outdir, l:overwrite)
    catch /.*/
      call s:print_error_msg(v:exception, 0)
      return
    endtry

    " Stats tab
    " if !get(g:, 'colortemplate_no_stat', 0)
    "   call s:print_color_info()
    " endif
  endf

  " Format a dictionary of color name/value pairs in Colortemplate format
  fun! colortemplate#format_palette(colors)
    let l:template = []
    for [l:name, l:value] in items(a:colors)
      call add(l:template, printf('Color: %s %s ~', l:name, l:value))
    endfor
    return l:template
  endf
  " }}} Public interface
  " TODO {{{
  " - Alias for color names
  " - Toolbar menu
  " - Fix aux files
  " - Fix stats
  " - ga for color information
  " - mapping for replacing ~ on the fly
  " - NeoVim keyword
  " - Validation using Vim script
  " - Fix for Vim background bug
  " - Fix for https://github.com/lifepillar/vim-colortemplate/issues/13
