" vim: foldmethod=marker nowrap et ts=2 sw=2
let s:VERSION = '2.0.0'
" Informal grammar {{{
" <Template>                  ::= <Line>*
" <Line>                      ::= <EmptyLine> | <Comment> | <KeyValuePair> | <HiGroupDef> |
"                                 <VerbatimText>  | <Command> | <AuxFile> | <Documentation>
" <Command>                   ::= #if <Anything> | #elseif <Anything> | #else | #endif
" <VerbatimText>              ::= verbatim <Anything> endverbatim
" <AuxFile>                   ::= auxfile <Path> <Anything> endauxfile
" <Path>                      ::= .+
" <Documentation>             ::= documentation <Anything> enddocumentation
" <Anything>                  ::= .*
" <Comment>                   ::= # .*
" <KeyValuePair>              ::=  <ColorDef> | <Key> : <Value>
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
" File and Path manipulation {{{
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
" }}}
" Buffer and file manipulation {{{
fun! s:do_make_buffer()
    botright 1new +setlocal\ ft=vim\ norl\ nowrap\ bh=hide
    if s:getopt('use_tabs')
      setlocal noet
    else
      setlocal et ts=2 sw=2
    endif
endf

if exists('*appendbufline')

  fun! s:getbufline(bufnr, start, stop)
    return getbufline(a:bufnr, a:start, a:stop)
  endf

  fun! s:setbufline(bufnr, linenr, line)
    call setbufline(a:bufnr, a:linenr, a:line)
  endf

  fun! s:appendbufline(bufnr, linenr, line)
    call appendbufline(a:bufnr, a:linenr, a:line)
  endf

  fun! s:new_work_buffer()
    call s:do_make_buffer()
    let l:bufnr = bufnr("%")
    wincmd p
    execute winnr('#') 'wincmd c'
    return l:bufnr
  endf

  fun! s:reindent_buffer(bufnr)
    execute '1split +'.a:bufnr.'buffer'
    normal gg=G
    wincmd c
  endf

else

  fun! s:getbufline(bufnr, start, stop)
    return getline(a:start, a:stop)
  endf

  fun! s:setbufline(bufnr, linenr, line)
    call setline(a:linenr, a:line)
  endf

  fun! s:appendbufline(bufnr, linenr, line)
    call append(a:linenr, a:line)
  endf

  fun! s:new_work_buffer()
    call s:do_make_buffer()
    return bufnr("%")
  endf

  fun! s:reindent_buffer(bufnr)
    silent execute a:bufnr "bufdo norm gg=G"
  endf

endif

fun! s:destroy_buffer(bufnr)
  execute a:bufnr 'bwipe!'
endf

" Write the specified buffer into path. The path must be inside env['dir'].
fun! s:write_buffer(bufnr, path, env, overwrite)
  let l:path = s:full_path(a:path, a:env)
  call s:make_dir(fnamemodify(l:path, ":h"))
  if bufloaded(l:path)
    if a:overwrite
      execute "bdelete!" bufname(a:path)
    else
      throw "Buffer " . l:path . " exists. Use ! to overwrite."
    endif
  endif
  if a:overwrite || !filereadable(l:path)
    if writefile(s:getbufline(a:bufnr, 1, "$"), l:path) < 0
      throw 'Could not write ' . l:path . ': ' . v:exception
    endif
  else
    throw 'File exists: ' . l:path . '. Use ! to overwrite it.'
  endif
endf

" Ditto, but writes a List
fun! s:write_list(lines, path, env, overwrite)
  let l:path = s:full_path(a:path, a:env)
  call s:make_dir(fnamemodify(l:path, ":h"))
  if a:overwrite || !filereadable(l:path)
    if writefile(a:lines, l:path) < 0
      throw 'Could not write ' . l:path . ': ' . v:exception
    endif
  else
    throw 'File exists: ' . l:path . '. Use ! to overwrite it.'
  endif
endf
" }}}
" Errors and warnings {{{
fun! s:add_error(path, line, col, msg)
  call setqflist([{'filename': a:path, 'lnum' : a:line, 'col': a:col, 'text' : a:msg, 'type' : 'E'}], 'a')
endf

fun! s:add_warning(path, line, col, msg)
  if s:getopt('warnings')
    call setqflist([{'filename': a:path, 'lnum' : a:line, 'col': a:col, 'text' : a:msg, 'type' : 'W'}], 'a')
  endif
endf

fun! s:add_generic_error(msg)
  call s:add_error(bufname('%'), 1, 1, a:msg)
endf

fun! s:add_generic_warning(msg)
  call s:add_warning(bufname('%'), 1, 1, a:msg)
endf

fun! s:print_error_msg(msg, rethrow)
  call s:clearscreen()
  if a:rethrow
    unsilent echoerr '[Colortemplate]' a:msg
  else
    echohl Error
    unsilent echomsg '[Colortemplate]' a:msg
    echohl None
  endif
endf

fun! s:print_notice(msg)
  call s:clearscreen()
  unsilent echomsg '[Colortemplate]' a:msg
endf

fun! s:clearscreen()
  redraw
  echo "\r"
endf

fun! s:is_error_state()
  return !empty(filter(getqflist(), { i,v -> v['type'] !=# 'W' }))
endf

fun! s:show_errors(errmsg)
  botright cwindow
  if getbufvar('', '&ft', '') ==# 'qf'
    wincmd p
  endif
  if !empty(filter(getqflist(), { i,v -> v['type'] !=# 'W' }))
    throw a:errmsg
  endif
endf
" }}}
" Misc {{{
if exists('*isnan')
  fun! s:isnan(x)
    return isnan(a:x)
  endf
else
  fun! s:isnan(x)
    return printf("%f", a:x) ==# 'nan'
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

fun! s:destroy_source_code()
  unlet! s:source
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
  let s:guicol = { 'dark':     {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \          'light':    {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \          'preamble': {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \        }
  let s:col256 = { 'dark':     {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \          'light':    {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \          'preamble': {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \        }
  let s:col16  = { 'dark':     {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \          'light':    {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \          'preamble': {'fg':'fg', 'bg':'bg', 'none': 'NONE', 'omit': 'omit'},
        \        }
  let s:term_colors = { 'dark': [], 'light': [], 'preamble': [] } " 16 ASCII colors
endf

fun! s:destroy_color_palette()
  unlet! g:guicol s:col256 s:col16 s:term_colors
endf

" section: 'preamble, 'dark' or 'light'
" name: color name as defined by the user
" gui: GUI value (either a hex value or a standard name)
" base256: a numeric value between 16 and 255 or -1 (=infer the value)
" base16: a numeric value between 0 and 15
fun! s:add_color(section, name, gui, base256, base16)
  if s:is_color_defined(a:name, a:section)
    throw "Color already defined for " . a:section . " background"
  endif
  let s:guicol[a:section][a:name] = a:gui
  let s:col256[a:section][a:name] = a:base256
  let  s:col16[a:section][a:name] = a:base16
  if a:section ==# 'preamble'
    if s:is_color_defined(a:name, 'dark')
      throw "Color already defined for dark background"
    endif
    let s:guicol['dark'][a:name] = a:gui
    let s:col256['dark'][a:name] = a:base256
    let  s:col16['dark'][a:name] = a:base16
    if s:is_color_defined(a:name, 'light')
      throw "Color already defined for light background"
    endif
    let s:guicol['light'][a:name] = a:gui
    let s:col256['light'][a:name] = a:base256
    let  s:col16['light'][a:name] = a:base16
  endif
endf

fun! s:add_term_ansi_color(name, section)
  call add(s:term_colors[a:section], a:name)
  if a:section ==# 'preamble'
    call add(s:term_colors['dark'], a:name)
    call add(s:term_colors['light'], a:name)
  endif
endf

fun! s:col16(name, section)
  if s:col16[a:section][a:name] == -1
    throw 'Base-16 value undefined for color ' . a:name
  else
    return s:col16[a:section][a:name]
  endif
endf

fun! s:col256(name, section)
  if s:col256[a:section][a:name] == -1 " Infer the value from GUI color
    let s:col256[a:section][a:name] =
          \ colortemplate#colorspace#approx(s:guihex(a:name, a:section))['index']
  endif
  return s:col256[a:section][a:name]
endf

fun! s:termcol(name, section, t_Co)
  return a:t_Co <= 16 ? s:col16(a:name, a:section) : s:col256(a:name, a:section)
endf

" Returns the color as it is given by the user (hex value or name)
fun! s:guicol(name, section)
  return s:guicol[a:section][a:name]
endf

" Always returns the color as a hex value
fun! s:guihex(name, section)
  return s:guicol[a:section][a:name] =~# '\m^#'
        \ ? s:guicol[a:section][a:name]
        \ : colortemplate#colorspace#rgbname2hex(tolower(s:guicol[a:section][a:name]))
endf

fun! s:is_color_defined(name, section)
  return has_key(s:guicol[a:section], a:name)
endf

fun! s:term_colors(section)
  return s:term_colors[a:section]
endf

fun! s:color_names(section)
  return filter(copy(keys(s:guicol[a:section])), { _,v -> v !~# '^\%(fg\|bg\|none\|omit\)$' })
endf
" }}}
" Highlight groups {{{
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
      \ 'PopupSelected',
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

fun! s:init_highlight_groups()
endf

fun! s:destroy_highlight_groups()
endf

fun! s:default_hi_groups()
  return s:default_hi_groups
endf

fun! s:new_hi_group(name)
  return {
        \ 'name': a:name,
        \ 'fg': '',
        \ 'bg': '',
        \ 'sp': 'none',
        \ 'term': [],
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

fun! s:fg16(hg, section)
  return s:col16(a:hg['fg'], a:section)
endf

fun! s:bg16(hg, section)
  return s:col16(a:hg['bg'], a:section)
endf

fun! s:fg256(hg, section)
  return s:col256(a:hg['fg'], a:section)
endf

fun! s:bg256(hg, section)
  return s:col256(a:hg['bg'], a:section)
endf

fun! s:quote_spaces(v)
  return a:v =~# '\m\s' ? "'".a:v."'" : a:v
endf

" If the GUI color is given as a hex value, return it as such.
" Otherwise it is an RGB name: quote it if it contains spaces.
fun! s:guifg(hg, section)
  let l:c = s:guicol(a:hg['fg'], a:section)
  return l:c ==# '\m^#' ? l:c : s:quote_spaces(l:c)
endf

fun! s:guibg(hg, section)
  let l:c = s:guicol(a:hg['bg'], a:section)
  return l:c ==# '\m^#' ? l:c : s:quote_spaces(l:c)
endf

fun! s:guisp(hg, section)
  let l:c = s:guicol(a:hg['sp'], a:section)
  return l:c ==# '\m^#' ? l:c : s:quote_spaces(l:c)
endf

fun! s:term_attr(hg)
  return empty(a:hg['term']) ? 'NONE' : join(a:hg['term'], ',')
endf

fun! s:gui_attr(hg)
  return empty(a:hg['gui']) ? 'NONE' : join(a:hg['gui'], ',')
endf

fun! s:term_attr_no_italics(hg)
  let l:attr = filter(copy(a:hg['term']), { _,v -> v !=# 'italic' })
  return empty(l:attr) ? 'NONE' : join(l:attr, ',')
endf

fun! s:gui_attr_no_italics(hg)
  let l:attr = filter(copy(a:hg['gui']), { _,v -> v !=# 'italic' })
  return empty(l:attr) ? 'NONE' : join(l:attr, ',')
endf

" type may be only 'start' or 'stop'
fun! s:terminal_code(hg, type)
  return empty(a:hg[a:type]) ? 'omit' : a:hg[a:type]
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

" type can be only 'start' or 'stop'
fun! s:set_terminal_code(hg, type, value)
  let a:hg[a:type] = a:value
endf

fun! s:has_term_attr(hg)
  return !empty(a:hg['term'])
endf

fun! s:has_term_italics(hg)
  return index(a:hg['term'], 'italic') > -1
endf

fun! s:has_gui_attr(hg)
  return !empty(a:hg['gui'])
endf

fun! s:has_gui_italics(hg)
  return index(a:hg['gui'], 'italic') > -1
endf

fun! s:is_neovim_group(name)
  return a:name =~? '^TermCursor\%[NC]$'
endf

fun! s:add_term_attr(hg, attrlist)
  call extend(a:hg['term'], a:attrlist)
  call uniq(sort(a:hg['term']))
endf

fun! s:add_gui_attr(hg, attrlist)
  call extend(a:hg['gui'], a:attrlist)
  call uniq(sort(a:hg['gui']))
endf

" Vacuous highlight groups have `omit` in all parts
fun! s:is_hi_group_vacuous(hg)
  return a:hg['fg'] ==# 'omit' && a:hg['bg'] ==# 'omit' &&
        \ ((a:hg['sp'] ==# 'omit' && a:hg['gui'] ==# 'omit')
        \ || (a:hg['term'] ==# 'omit'))
endf
" }}}
" Color pairs {{{
fun! s:init_color_pairs()
  let s:color_pairs = { 'dark': {}, 'light': {} }
endf

fun! s:destroy_color_pairs()
  unlet! s:color_pairs
endf

fun! s:add_color_pair(section, hg)
  let l:sections = (a:section ==# 'preamble' ? ['dark','light'] : [a:section])
  for l:s in l:sections
    let l:key = s:fg(a:hg).'/'.s:bg(a:hg)
    if l:key =~# '\<\%(fg\|bg\|none\|omit\|unused\)\>'
      continue
    endif
    let l:val = s:hi_name(a:hg)
    if !has_key(s:color_pairs[l:s], l:key)
      let s:color_pairs[l:s][l:key] = []
    endif
    call add(s:color_pairs[l:s][l:key], l:val)
  endfor
endf

fun! s:get_color_pairs(bg)
  return s:color_pairs[a:bg]
endf
" }}}
" Colorscheme metadata {{{
fun! s:init_metadata()
  let s:supports_dark = 0
  let s:supports_light = 0
  let s:uses_italics = 0
  let s:supports_neovim = 0
  let s:supported_variants = []
  let s:info = {
        \ 'author': '',
        \ 'description': '',
        \ 'fullauthor': '',
        \ 'fullname': '',
        \ 'license': 'Vim License (see `:help license`)',
        \ 'maintainer': '',
        \ 'optionprefix': '',
        \ 'shortname': '',
        \ 'url': '',
        \ 'version': '',
        \ 'website': '',
        \ }
  let s:info_keys_regex = join(keys(s:info), '\|')
endf

fun! s:destroy_metadata()
  unlet! s:supports_dark s:supports_light s:uses_italics
        \ s:supports_neovim s:supported_variants s:info
        \ s:info_keys_regex
endf

fun! s:info_keys()
  return keys(s:info)
endf

fun! s:info_keys_regex()
  return s:info_keys_regex
endf

fun! s:supports_neovim()
  return s:supports_neovim
endf

fun! s:set_supports_neovim()
  let s:supports_neovim = 1
endf

fun! s:uses_italics()
  return s:uses_italics
endf

fun! s:set_uses_italics()
  let s:uses_italics = 1
endf

fun! s:has_dark_and_light()
  return s:supports_dark && s:supports_light
endf

fun! s:has_dark()
  return s:supports_dark
endf

fun! s:has_light()
  return s:supports_light
endf

fun! s:set_has_dark()
  let s:supports_dark = 1
endf

fun! s:set_has_light()
  let s:supports_light = 1
endf

fun! s:supported_backgrounds()
  return (s:has_dark() ? ['dark'] : []) + (s:has_light() ? ['light'] : [])
endf

fun! s:supported_variants()
  return s:supported_variants
endf

fun! s:has_variant(v)
  return index(s:supported_variants, a:v) > -1
endf

fun! s:add_variant(variant)
  call add(s:supported_variants, a:variant)
  call reverse(uniq(sort(s:supported_variants, 'N')))
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
  if a:key ==# 'author'
    let s:info['fullauthor'] = a:value
    let s:info['author'] = matchstr(a:value, '^[^< ]\+')
    return
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

fun! s:fullauthor()
  return s:info['fullauthor']
endf

fun! s:author()
  return s:info['author']
endf

fun! s:maintainer()
  return s:info['maintainer']
endf

fun! s:set_default_maintainer()
  let s:info['maintainer'] = s:info['fullauthor']
endf

fun! s:description()
  return s:info['description']
endf

fun! s:url()
  return s:info['url']
endf

fun! s:version()
  return s:info['version']
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
  let s:data       = { 'global': { 'preamble': [] } }
  let s:italics    = { 'global': {'preamble': [] } } " Global is never used for italics
  let s:nvim       = { 'global': { 'preamble': [] } }
  let s:has_normal = { }
  let s:hi_groups  = { } " Set of defined highlight groups
endf

fun! s:destroy_colorscheme_definition()
  unlet! s:data s:italics s:nvim s:has_normal s:hi_groups
endf

fun! s:add_colorscheme_variant(v)
  call s:add_variant(a:v)
  if !has_key(s:data, a:v)
    let s:data[a:v]       = { 'preamble': [], 'dark': [], 'light': [] }
    let s:italics[a:v]    = { 'preamble': [], 'dark': [], 'light': [] }
    let s:nvim[a:v]       = { 'preamble': [], 'dark': [], 'light': [] }
    let s:has_normal[a:v] = { 'preamble': 0,  'dark': 0,  'light': 0  }
  endif
endf

fun! s:has_normal(variant, section)
  return s:has_normal[a:variant][a:section]
endf

fun! s:set_has_normal(variant, section)
  let s:has_normal[a:variant][a:section] = 1
  if a:section ==# 'preamble'
    let s:has_normal[a:variant]['dark'] = 1
    let s:has_normal[a:variant]['light'] = 1
  endif
endf

fun! s:make_item(item, type)
  return [a:type, a:item]
endf

fun! s:is_raw_type(item)
  return a:item[0] ==# 'raw'
endf

fun! s:is_verb_type(item)
  return a:item[0] ==# 'verb'
endf

fun! s:is_higroup_type(item)
  return a:item[0] ==# 'group'
endf

fun! s:is_linked_type(item)
  return a:item[0] ==# 'link'
endf

fun! s:is_italic_type(item)
  return a:item[0] ==# 'it'
endf

fun! s:item_type(item)
  return a:item[0]
endf

fun! s:item_value(item)
  return a:item[1]
endf

fun! s:add_item(variant, section, item, type)
  call add(s:data[a:variant][a:section], s:make_item(a:item, a:type))
endf

fun! s:add_raw_item(variant, section, item)
  call s:add_item(a:variant, a:section, a:item, 'raw')
endf

fun! s:add_verbatim_item(variant, section, item)
  call s:add_item(a:variant, a:section, a:item, 'verb')
endf

fun! s:add_higroup_item(variant, section, hg)
  let s:hi_groups[s:hi_name(a:hg)] = 1
  if s:is_neovim_group(s:hi_name(a:hg))
    call s:add_neovim_higroup_item(a:variant, a:section, a:hg)
    return
  endif
  call s:add_item(a:variant, a:section, a:hg, 'group')
  if a:variant ==# s:GUI
    if s:has_gui_italics(a:hg)
      call s:set_uses_italics()
      call add(s:italics[a:variant][a:section], s:make_item(a:hg, 'it'))
    endif
  elseif s:has_term_italics(a:hg)
    call s:set_uses_italics()
    call add(s:italics[a:variant][a:section], s:make_item(a:hg, 'it'))
  endif
endf

fun! s:add_neovim_higroup_item(variant, section, item)
  call add(s:nvim[a:variant][a:section], s:make_item(a:item, 'group'))
endf

fun! s:add_linked_item(variant, section, source, target)
  let s:hi_groups[a:source] = 1
  if s:is_neovim_group(a:source)
    call add(s:nvim[a:variant][a:section], s:make_item([a:source, a:target], 'link'))
  else
    call s:add_item(a:variant, a:section, [a:source, a:target], 'link')
  endif
endf

fun! s:hi_group_exists(name)
  return has_key(s:hi_groups, a:name)
endf

fun! s:add_italic_item(variant, section, item)
  call s:add_item(a:variant, a:section, a:item, 'it')
endf

fun! s:global_preamble()
  return s:data['global']['preamble']
        \ + (s:supports_neovim() && !empty(s:nvim['global']['preamble'])
        \   ? [['raw', "if has('nvim')"]] + s:nvim['global']['preamble'] + [['raw', 'endif']]
        \   : []
        \   )
endf

" Add italics definitions accumulated so far to the colorscheme at the current point
fun! s:flush_italics(variant, section)
  if s:is_global_preamble() || empty(s:italics[a:variant][a:section])
    return
  endif
  call s:add_raw_item(a:variant, a:section,  'if !s:italics')
  call extend(s:data[a:variant][a:section], s:italics[a:variant][a:section])
  call s:add_raw_item(a:variant, a:section, 'endif')
  let s:italics[a:variant][a:section] = []
endf

fun! s:flush_neovim(variant, section)
  if !s:supports_neovim() || empty(s:nvim[a:variant][a:section])
    return
  endif
  call s:add_raw_item(a:variant, a:section,  "if has('nvim')")
  call extend(s:data[a:variant][a:section], s:nvim[a:variant][a:section])
  call s:add_raw_item(a:variant, a:section, 'endif')
  let s:nvim[a:variant][a:section] = []
endf

fun! s:is_gui(variant)
  return a:variant ==# s:GUI
endf

fun! s:is_term(variant)
  return a:variant !=# s:GUI
endf

fun! s:flush_definitions(variant, section)
  call s:flush_italics(a:variant, a:section)
  call s:flush_neovim(a:variant, a:section)
endf

fun! s:colorscheme_definitions(variant, section)
  return s:data[a:variant][a:section]
endf

fun! s:has_colorscheme_definitions(variant, section)
  return !empty(s:data[a:variant][a:section])
endf
" }}}
" Aux files {{{
fun! s:init_aux_files()
  let s:auxfiles = {}    " Mappings from paths to list of lines
  let s:help_path = ''
endf

fun! s:destroy_aux_files()
  unlet! s:auxfiles s:help_path
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

fun! s:add_line_to_aux_file(line, linenr, path, sourcefile)
  call add(s:auxfiles[a:path], { 'line': a:line, 'linenr': a:linenr, 'file': a:sourcefile })
endf

fun! s:auxfile_paths()
  return keys(s:auxfiles)
endf

fun! s:auxfile(path)
  return s:auxfiles[a:path]
endf
" }}}
" Colortemplate options {{{
let s:defaultoptvalue = {
      \ 'creator':        1,
      \ 'ignore_missing': 0,
      \ 'quiet':          1,
      \ 'source_comment': 1,
      \ 'timestamp':      1,
      \ 'use_tabs':       0,
      \ 'warnings':       1,
      \ }

fun! s:init_colortemplate_options()
  let s:optvalue = {}
endf

fun! s:destroy_colortemplate_options()
  unlet s:optvalue
endf

fun! s:options()
  return keys(s:defaultoptvalue)
endf

fun! s:setopt(name, value)
  let s:optvalue[a:name] = a:value
endf

fun! s:getopt(name)
  return get(s:optvalue, a:name,
        \ get(g:, 'colortemplate_'.a:name, s:defaultoptvalue[a:name]))
endf
" }}}
" Init/clear data structures {{{
fun! s:init_data_structures()
  let g:colortemplate_exit_status = 0
  call s:init_source_code()
  call s:init_color_palette()
  call s:init_highlight_groups()
  call s:init_color_pairs()
  call s:init_metadata()
  call s:init_colorscheme_definition()
  call s:init_aux_files()
  call s:init_colortemplate_options()
endf

fun! s:destroy_data_structures()
  call s:destroy_source_code()
  call s:destroy_color_palette()
  call s:destroy_highlight_groups()
  call s:destroy_color_pairs()
  call s:destroy_metadata()
  call s:destroy_colorscheme_definition()
  call s:destroy_aux_files()
  call s:destroy_colortemplate_options()
endf
" }}}
" }}}
" Color stats {{{
" Print details about the color palette for the specified background
fun! s:print_similarity_table(bg, bufnr)
  let l:colors = s:color_names(a:bg)
  if empty(l:colors)
    return
  endif
  let l:delta = {}
  let l:colnames = []
  for l:c in l:colors
    " Skip ASCII colors (0-15)
    if s:col256(l:c, a:bg) < 16
      continue
    endif
    call add(l:colnames, l:c)
    let l:delta[l:c] = colortemplate#colorspace#hex_delta_e(
          \ s:guihex(l:c, a:bg),
          \ colortemplate#colorspace#xterm256_hexvalue(s:col256(l:c, a:bg))
          \ )
  endfor
  " Find maximum length of color names (used for formatting)
  let l:len = max(map(copy(l:colnames), { _,v -> len(v)}))
  " Sort colors by increasing delta
  call sort(l:colnames, { c1,c2 -> l:delta[c1] < l:delta[c2] ? -1 : 1 })
  call s:put(a:bufnr, '{{{ Color Similarity Table (' . a:bg . ' background)')
  for l:c in l:colnames
    let l:colgui = s:guihex(l:c, a:bg)
    let l:rgbgui = colortemplate#colorspace#hex2rgb(l:colgui)
    let l:col256 = s:col256(l:c, a:bg)
    let l:d  = l:delta[l:c]
    if l:col256 > 15 && l:col256 < 256
      let l:hex256 = g:colortemplate#colorspace#xterm256[l:col256 - 16]
      let l:rgb256 = colortemplate#colorspace#hex2rgb(l:hex256)
      let l:def256 = l:hex256 . printf('/rgb(%3d,%3d,%3d)', l:rgb256[0], l:rgb256[1], l:rgb256[2])
    else
      let l:def256 = repeat(' ', 24)
    endif
    let l:fmt = '%'.l:len.'s: GUI=%s/rgb(%3d,%3d,%3d)  Term=%3d %s  [delta=%f]'
    call s:put(a:bufnr, printf(l:fmt, l:c, l:colgui, l:rgbgui[0], l:rgbgui[1], l:rgbgui[2], l:col256, l:def256, l:d))
  endfor
  call s:put(a:bufnr, '}}} Color Similarity Table')
endf

fun! s:print_critical_pairs(section, bufnr)
  let l:critical_gui = []
  let l:critical_256 = []
  for [l:key, l:val] in items(s:get_color_pairs(a:section))
    let [l:fg, l:bg] = split(l:key, '/')
    let l:c1 = s:guihex(l:fg, a:section)
    let l:c2 = s:guihex(l:bg, a:section)
    let l:cr = colortemplate#colorspace#contrast_ratio(l:c1, l:c2)
    if l:cr < 3.0
      let l:cb = colortemplate#colorspace#brightness_diff(l:c1, l:c2)
      let l:cd = colortemplate#colorspace#color_difference(l:c1, l:c2)
      call add(l:critical_gui, [l:fg, l:bg, l:cr, l:cb, l:cd, l:val])
    endif
    let l:c1 = s:col256(l:fg, a:section)
    let l:c2 = s:col256(l:bg, a:section)
    if l:c1 < 16 ||  l:c1 > 255 || l:c2 < 16 || l:c2 > 255
      continue
    endif
    let l:c1 = colortemplate#colorspace#xterm256_hexvalue(l:c1)
    let l:c2 = colortemplate#colorspace#xterm256_hexvalue(l:c2)
    let l:cr = colortemplate#colorspace#contrast_ratio(l:c1, l:c2)
    if l:cr < 3.0
      let l:cb = colortemplate#colorspace#brightness_diff(l:c1, l:c2)
      let l:cd = colortemplate#colorspace#color_difference(l:c1, l:c2)
      call add(l:critical_256, [l:fg, l:bg, l:cr, l:cb, l:cd, l:val])
    endif
  endfor
  call sort(l:critical_gui, { i1,i2 -> i1[2] < i2[2] ? -1 : i1[2] > i2[2] ? 1 : 0 })
  call sort(l:critical_256, { i1,i2 -> i1[2] < i2[2] ? -1 : i1[2] > i2[2] ? 1 : 0 })
  call s:put(a:bufnr, '{{{ Critical Pairs (' . a:section . ' background)')
  call s:put(a:bufnr, 'Not ISO-9241-3 conforming pairs of foreground/background colors')
  call s:put(a:bufnr, '{{{ GUI (' . a:section . ')')
  for l:i in l:critical_gui
    call s:put(a:bufnr, printf('%s/%s  CR:%.2f, CB:%.2f, CD:%.2f', l:i[0], l:i[1], l:i[2], l:i[3], l:i[4]))
    call s:put(a:bufnr, printf('  Used by %s', join(uniq(sort(l:i[5])), ', ')))
  endfor
  call s:put(a:bufnr, '}}}')
  call s:put(a:bufnr, '{{{ Terminal (' . a:section . ')')
  for l:i in l:critical_256
    call s:put(a:bufnr, printf('%s/%s  CR:%.2f, CB:%.2f, CD:%.2f', l:i[0], l:i[1], l:i[2], l:i[3], l:i[4]))
    call s:put(a:bufnr, printf('  Used by %s', join(uniq(sort(l:i[5])), ', ')))
  endfor
  call s:put(a:bufnr, '}}}')
  call s:put(a:bufnr, '}}} Critical Pairs')
endf

fun! s:print_matrix(bufnr, matrix, labels, gui, bg)
  call s:put(a:bufnr, '{{{ '.(a:gui ? 'GUI (' : 'Terminal (').a:bg.')')
  call s:put(a:bufnr, "\t".join(a:labels, "\t"))
  for l:i in range(len(a:matrix))
    call s:put(a:bufnr, a:labels[l:i]."\t".join(map(a:matrix[l:i], { j,v -> j ==# l:i ? '' : printf("%5.02f", v) }), "\t")."\t".a:labels[l:i])
  endfor
  call s:put(a:bufnr, "\t".join(a:labels, "\t"))
  call s:put(a:bufnr, '}}}')
endf

fun! s:print_contrast_ratio_matrices(bufnr, colors, colnames, bg)
  let l:M = {}
  let l:M['gui'] = colortemplate#colorspace#contrast_matrix(a:colors['gui'])
  let l:M['term'] = colortemplate#colorspace#contrast_matrix(a:colors['term'])
  call s:put(a:bufnr, '{{{ Contrast Ratio Matrix (' . a:bg . ' background)')
  call s:put(a:bufnr, 'Pairs of colors with contrast ≥4.5 can be safely used as a fg/bg combo')
  call s:put(a:bufnr, "█ Not W3C conforming   █ Not ISO-9241-3 conforming")
  call s:print_matrix(a:bufnr, M['gui'], a:colnames, 1, a:bg)
  call s:print_matrix(a:bufnr, M['term'], a:colnames, 0, a:bg)
  call s:put(a:bufnr, '}}} Contrast Ratio Matrix')
endf

fun! s:print_colordiff_matrix(bufnr, colors, colnames, bg)
  let l:M = {}
  let l:M['gui'] = colortemplate#colorspace#coldiff_matrix(a:colors['gui'])
  let l:M['term'] = colortemplate#colorspace#coldiff_matrix(a:colors['term'])
  call s:put(a:bufnr, '{{{ Color Difference Matrix (' . a:bg . ' background)')
  call s:put(a:bufnr, 'Pairs of colors whose color difference is ≥500 can be safely used as a fg/bg combo')
  call s:print_matrix(a:bufnr, M['gui'], a:colnames, 1, a:bg)
  call s:print_matrix(a:bufnr, M['term'], a:colnames, 0, a:bg)
  call s:put(a:bufnr, '}}} Color Difference Matrix')
endf

fun! s:print_brightness_diff_matrix(bufnr, colors, colnames, bg)
  let l:M = {}
  let l:M['gui'] = colortemplate#colorspace#brightness_diff_matrix(a:colors['gui'])
  let l:M['term'] = colortemplate#colorspace#brightness_diff_matrix(a:colors['term'])
  call s:put(a:bufnr, '{{{ Brightness Difference Matrix (' . a:bg . ' background)')
  call s:put(a:bufnr, 'Pairs of colors whose brightness difference is ≥125 can be safely used as a fg/bg combo')
  call s:print_matrix(a:bufnr, M['gui'], a:colnames, 1, a:bg)
  call s:print_matrix(a:bufnr, M['term'], a:colnames, 0, a:bg)
  call s:put(a:bufnr, '}}} Brightness Difference Matrix')
endf

" Adds the contrast matrix for the specified background to the current buffer.
fun! s:print_color_matrices(bg, bufnr)
  let l:colnames = sort(s:color_names(a:bg))
  if empty(l:colnames)
    return
  endif
  let l:values = { 'gui': [], 'term': [] }
  for l:c in l:colnames
    " Skip colors 0-15
    if s:col256(l:c, a:bg) < 16
      continue
    endif
    call add(l:values['gui'], s:guihex(l:c, a:bg))
    call add(l:values['term'], colortemplate#colorspace#xterm256_hexvalue(s:col256(l:c, a:bg)))
  endfor
  call s:print_contrast_ratio_matrices(a:bufnr, l:values, l:colnames, a:bg)
  call s:print_colordiff_matrix(a:bufnr, l:values, l:colnames, a:bg)
  call s:print_brightness_diff_matrix(a:bufnr, l:values, l:colnames, a:bg)
endf

fun! s:print_color_info()
  silent botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted foldmethod=marker noet norl noswf nowrap
  let l:bufnr = bufnr('%')
  set ft=colortemplate-info
  " Find maximum length of color names (used for formatting)
  let l:labels = s:color_names('dark') + s:color_names('light')
  let l:tw = 2 + max(map(l:labels, { _,v -> len(v)}))
  execute 'setlocal tabstop='.l:tw 'shiftwidth='.l:tw

  call append(0, 'Color statistics for ' . s:fullname())

  for l:bg in s:supported_backgrounds()
    if s:has_dark_and_light()
      call s:put(l:bufnr, '{{{ '.l:bg.' background')
    endif
    call s:print_similarity_table(l:bg, l:bufnr)
    call s:print_critical_pairs(l:bg, l:bufnr)
    call s:print_color_matrices(l:bg, l:bufnr)
    if s:has_dark_and_light()
      call s:put(l:bufnr, '}}}')
    endif
  endfor
endf
" }}}
" Interpolation {{{
fun! s:interpolate(variant, section, line, linenr, file)
  let l:t_Co = (s:is_gui(a:variant) || a:variant ==# 'global') ? 256 : a:variant
  try
    let l:line = substitute(a:line, '@term16\(\w\+\)',                '\=s:col16(submatch(1),"'.a:section.'")',                            'g')
    let l:line = substitute(l:line, '@term256\(\w\+\)',               '\=s:col256(submatch(1),"'.a:section.'")',                           'g')
    let l:line = substitute(l:line, '@gui\(\w\+\)',                   '\=s:guicol(submatch(1),"'.a:section.'")',                           'g')
    let l:line = substitute(l:line, '\(cterm[bf]g=\)@\(\w\+\)',       '\=submatch(1).s:termcol(submatch(2),"'.a:section.'","'.l:t_Co.'")', 'g')
    let l:line = substitute(l:line, '\(gui[bf]g=\|guisp=\)@\(\w\+\)', '\=submatch(1).s:guicol(submatch(2),"'.a:section.'")',               'g')
    let l:line = substitute(l:line, '@date',                          '\=strftime("%Y %b %d")',                                            'g')
    let l:line = substitute(l:line, '@vimversion',                    '\=string(v:version/100).".".string(v:version%100)',                 'g')
    let l:line = substitute(l:line, '@\('.s:info_keys_regex().'\)',   '\=s:get_info(submatch(1))',                                         'g')
    return l:line
  catch /.*/
    call s:add_error(a:file, a:linenr, 1, 'Undefined @ value')
    return a:line
  endtry
endf
" }}}
" Parsing {{{
" Tokenizer {{{
" Current token in the currently parsed line
let s:token = { 'line': '', 'spos':  0, 'pos':  0, 'value': '', 'kind': '' }

fun! s:init_tokenizer()
  call s:token.reset()
endf

fun! s:destroy_tokenizer()
endf

fun! s:token.reset() dict
  let self.line = ''
  let self.spos  = 0
  let self.pos   = 0
  let self.value = ''
  let self.kind  = ''
endf

fun! s:token.getl() dict
  return self.line
endf

fun! s:getl()
  return s:token.getl()
endf

fun! s:token.setline(l) dict
  let self.line = a:l
endf

fun! s:token.next() dict
  let [l:char, self.spos, self.pos] = matchstrpos(s:getl(), '\s*\zs\S', self.pos) " Get first non-white character starting at pos
  if empty(l:char)
    let self.kind = 'EOL'
    let self.spos = len(s:getl()) - 1 " For correct error location
    let self.pos = len(s:getl()) " Makes next() at eol idempotent
  elseif l:char =~? '\m\a'
    let [self.value, self.spos, self.pos] = matchstrpos(s:getl(), '\w\+', self.pos - 1)
    let self.kind = 'WORD'
  elseif l:char =~# '\m[0-9]'
    let [self.value, self.spos, self.pos] = matchstrpos(s:getl(), '\d\+', self.pos - 1)
    let self.kind = 'NUM'
  elseif l:char ==# '#'
    " Commands are recognized only at the start of a line
    if match(s:getl(), '^\s*#\%(if\|else\%[if]\|endif\|\%[un]let\|call\)\>', 0) > -1
      let self.kind = 'CMD'
      let self.value = matchstr(s:getl(), '^\s*#\zs\%(if\|else\%[if]\|endif\)\>', 0)
    elseif match(s:getl(), '^[0-9a-f]\{6}', self.pos) > -1
      let [self.value, self.spos, self.pos] = matchstrpos(s:getl(), '#[0-9a-f]\{6}', self.pos - 1)
      let self.kind = 'HEX'
    else
      let self.value = '#'
      let self.kind = 'COMMENT'
      let self.pos = len(s:getl())
    endif
  elseif l:char ==# ';'
    let self.value = ';'
    let self.kind = 'COMMENT'
    let self.pos = len(s:getl())
  elseif match(l:char, "[*:=.,>~)(-]") > -1
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

fun! s:token.skip(newpos) dict
  let self.pos = a:newpos
endf

fun! s:token.is_edible() dict
  return s:token.kind !=# 'EOL' && s:token.kind !=# 'COMMENT'
endf
" }}}
" Included files {{{
fun! s:init_includes()
  let s:input_stack = []
  let s:includes_stack = []
  let s:path = ''
  let s:linenr = 0
  let s:numlines = 0
  let s:cache = {}
endf

fun! s:destroy_includes()
  unlet! s:input_stack s:includes_stack s:path s:linenr s:numlines s:cache
endf

fun! s:include(path)
  " Save current position in the stack
  call s:push(s:includes_stack, { 'path': s:path, 'linenr': s:linenr, 'numlines': s:numlines })
  let s:path = s:full_path(a:path =~# '\m\.' ? a:path : a:path.'.colortemplate', { 'dir': s:getwd() })
  if !filereadable(s:path) " Try without adding the suffix
    let s:path = s:full_path(a:path, { 'dir': s:getwd() })
  endif
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
  call s:token.reset()
  let s:token.line = s:pop(s:input_stack)
  return 1
endf
" }}}
" Active section {{{
fun! s:init_active_section()
  let s:active_section = 'preamble'
endf

fun! s:destroy_active_section()
  unlet! s:active_section
endf

fun! s:active_section()
  return s:active_section
endf

fun! s:set_active_section(v)
  let s:active_section = a:v
endf
" }}}
" Active variants {{{
fun! s:init_variants()
  let s:active_variants = ['global']
endf

fun! s:destroy_variants()
  unlet! s:active_variants
endf

fun! s:active_variants()
  return s:active_variants
endf

fun! s:has_active_term_variant()
  return len(s:active_variants) > 1 || s:active_variants[0] != s:GUI
endf

fun! s:set_active_variants(variants)
  let s:active_variants = []
  for l:v in a:variants
    if l:v ==# 'gui' || str2nr(l:v) > 256
      let l:v = s:GUI
    endif
    if !s:has_variant(l:v)
      call s:add_colorscheme_variant(l:v)
    endif
    call add(s:active_variants, l:v)
  endfor
  call uniq(sort(s:active_variants))
endf

fun! s:is_global_preamble()
  return s:active_variants ==# ['global']
endf

" Here we use the fact that str2nr() applied to a String returns 0 and not an
" error. So stuff like s:fg16('Black', bg) does not cause out of range errors.
" Ugly, but it works.
fun! s:check_color_range(variant, section, hg)
  if a:variant ==# s:GUI
    return
  endif
  let l:t_co = str2nr(a:variant)
  if l:t_co > 0 && (
        \ (l:t_co <= 16 && (s:fg16(a:hg, a:section) >= l:t_co || s:bg16(a:hg, a:section) >= l:t_co))
        \ || (l:t_co > 16 && (s:fg256(a:hg, a:section) >= l:t_co || s:bg256(a:hg, a:section) >= l:t_co))
        \ )
    throw printf('Color out of range for %d-color variant used in: %s', l:t_co, s:hi_name(a:hg))
  endif
endf

fun! s:add_highlight_group(hg)
  if s:is_global_preamble()
    throw "Cannot define highlight group before Variant or Background is set"
  endif
  if s:hi_name(a:hg) ==? 'Normal' " Normal group needs special treatment
    for l:v in s:active_variants()
      call s:set_has_normal(l:v, s:active_section())
    endfor
  endif
  for l:v in s:active_variants()
    call s:check_color_range(l:v, s:active_section(), a:hg)
    call s:add_higroup_item(l:v, s:active_section(), a:hg)
  endfor
endf
" }}}
" Verbatim {{{
fun! s:init_verbatim()
  let s:verb_block = 0
  let s:if_stack =  {}
endf

fun! s:destroy_verbatim()
  unlet! s:verb_block
  unlet! s:if_stack
endf

fun! s:start_verbatim()
  " Verbatim blocks act like optimization fences: since we don't know what the
  " code in a verbatim block does, we need to flush definitions collected so
  " far.
  for l:v in s:active_variants()
    call s:flush_italics(l:v, s:active_section())
    call s:flush_neovim(l:v, s:active_section())
  endfor
  let s:verb_block = 1
endf

fun! s:stop_verbatim()
  let s:verb_block = 0
endf

fun! s:is_verbatim()
  return s:verb_block
endf

fun! s:start_if()
  let l:s = s:active_section()
  for l:v in s:active_variants()
    if !has_key(s:if_stack, l:v)
      let s:if_stack[l:v] = { l:s: 0 }
    elseif !has_key(s:if_stack[l:v], l:s)
      let s:if_stack[l:v][l:s] = 0
    endif
    let s:if_stack[l:v][l:s] += 1
  endfor
endf

fun! s:stop_if()
  let l:s = s:active_section()
  for l:v in s:active_variants()
    if get(get(s:if_stack, l:v, {}), l:s, 0) == 0
      throw 'endif without if'
    endif
    let s:if_stack[l:v][l:s] -= 1
  endfor
endf

fun! s:is_if()
  let l:s = s:active_section()
  for l:v in s:active_variants()
    if get(get(s:if_stack, l:v, {}), l:s, 0) == 0
      return 0
    endif
  endfor
  return 1
endf

fun! s:ifs_are_balanced()
  for l:v in keys(s:if_stack)
    for l:s in keys(s:if_stack[l:v])
      if s:if_stack[l:v][l:s] != 0
        return 0
      endif
    endfor
  endfor
  return 1
endf
" }}}
" Aux files {{{
fun! s:init_auxfiles_parsing()
  let s:is_aux = 0
  let s:is_help = 0
  let s:current_auxfile = ''
endf

fun! s:destroy_auxfiles_parsing()
  unlet! s:is_aux s:is_help s:current_auxfile
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

fun! s:add_to_aux_file(line, linenr, sourcefile)
  call s:add_line_to_aux_file(a:line, a:linenr, s:current_auxfile, a:sourcefile)
endf
" }}}
" Parser {{{
fun! s:quickly_parse_color_line()
  call s:init_color_palette()
  call s:init_tokenizer()
  call s:init_active_section()
  call s:init_variants()
  call s:token.setline(getline('.'))
  if s:token.next().kind != 'WORD' || s:token.value !=? 'color' " Not a Color line
    ascii
    return ''
  endif
  try
    call s:parse_color_def()
  catch /.*/
    call s:print_error_msg(v:exception, 0)
    return ''
  endtry
  return s:color_names('dark')[0]
endf

fun! s:parse_verbatim_line()
  call s:add_source_line(s:getl())
  if s:getl() =~? '\m^\s*endverbatim'
    call s:stop_verbatim()
    if s:getl() !~? '\m^\s*endverbatim\s*$'
      throw "Extra characters after 'endverbatim'"
    endif
  else
    for l:v in s:active_variants()
      call s:add_verbatim_item(l:v, s:active_section(),
            \ { 'line': s:getl(), 'linenr': s:linenr(), 'file': s:currfile() })
    endfor
  endif
endf

fun! s:parse_help_line()
  if s:getl() =~? '\m^\s*enddocumentation'
    call s:stop_help_file()
    if s:getl() !~? '\m^\s*enddocumentation\s*$'
      throw "Extra characters after 'enddocumentation'"
    endif
  else
    call s:add_to_aux_file(s:getl(), s:linenr(), s:currfile())
  endif
endf

fun! s:parse_auxfile_line()
  if s:getl() =~? '\m^\s*endauxfile'
    call s:stop_aux_file()
    if s:getl() !~? '\m^\s*endauxfile\s*$'
      throw "Extra characters after 'endauxfile'"
    endif
  else
    call s:add_to_aux_file(s:getl(), s:linenr(), s:currfile())
  endif
endf

fun! s:parse_line()
  if !s:token.next().is_edible() " Empty line or comment
    return
  endif
  if s:token.kind ==# 'WORD'
    if s:token.value ==? 'verbatim'
      call s:add_source_line(s:getl())
      call s:start_verbatim()
      if s:token.next().kind !=# 'EOL'
        throw "Extra characters after 'verbatim'"
      endif
    elseif s:token.value ==? 'auxfile'
      let l:path = matchstr(s:getl(), '^\s*auxfile\s\+\zs.*')
      if empty(l:path)
        throw 'Missing path'
      endif
      call s:start_aux_file(s:interpolate(min(s:active_variants()), s:active_section(), l:path, s:linenr(), s:currfile()))
    elseif s:token.value ==? 'documentation'
      if s:token.next().is_edible()
        throw "Extra characters after 'documentation'"
      endif
      call s:start_help_file()
    elseif s:getl() =~# '\m^[^#]*:' " Look ahead
      call s:parse_key_value_pair()
    else
      call s:add_source_line(s:getl())
      call s:parse_hi_group_def()
    endif
  elseif s:token.kind ==# 'CMD'
    call s:add_source_line(s:getl())
    call s:parse_command(s:token.value)
  else
    throw 'Unexpected token at start of line'
  endif
endf

fun! s:parse_key_value_pair()
  if s:token.value ==? 'color'
    call s:add_source_line(s:getl())
    call s:parse_color_def()
    return
  endif
  " Generic key-value pair
  let l:key_tokens = [s:token.value]
  while s:token.next().is_edible() && s:token.kind !=# ':'
    if s:token.kind !=# 'WORD' || s:token.value !~? '\m^\h\+$'
      throw 'Only letters from a to z and underscores are allowed in keys'
    endif
    call add(l:key_tokens, s:token.value)
  endwhile
  if s:token.kind !=# ':'
    throw 'Missing colon'
  endif
  let l:key = tolower(join(l:key_tokens, ''))
  if l:key ==# 'background'
    call s:parse_background_directive()
  elseif l:key ==# 'variant'
    call s:parse_variant_directive()
  elseif l:key ==# 'terminalcolors'
    call s:add_warning(s:currfile(), s:linenr(), s:token.pos,
          \ "The 'Terminal colors' key has been deprecated and is a no-op now")
  elseif l:key ==# 'termcolors'
    call s:parse_term_colors()
  elseif l:key ==# 'neovim'
    if s:token.next().value !~# '\m^y\%[es]\|n\%[o]\|1\|0$'
      throw "Neovim key can only be 'yes' or 'no'"
    endif
    call s:set_supports_neovim()
  elseif l:key ==# 'colortemplateoptions'
    call s:parse_colortemplate_options()
  else " Assume that the value is a path and may contain any characters
    let l:val = matchstr(s:getl(), '\s*\zs.\{-}\s*$', s:token.pos)
    if empty(l:val)
      throw 'Metadata value cannot be empty'
    endif
    if l:key ==# 'include'
      call s:include(l:val)
    else
      call s:set_info(l:key, l:val)
    endif
  endif
endf

fun! s:parse_background_directive()
  call s:add_source_line(s:getl())
  if s:token.next().kind !=# 'WORD' || s:token.value !~# '\m^\%(dark\|light\|any\)$'
    throw "Background can only be 'dark', 'light' or 'any'"
  endif
  if s:is_global_preamble() " Background in preamble implies Variant: gui 256
    call s:set_active_variants([s:GUI, '256'])
  endif
  if s:token.value ==# 'dark'
    call s:set_active_section('dark')
    call s:set_has_dark()
  elseif s:token.value ==# 'light'
    call s:set_active_section('light')
    call s:set_has_light()
  else " any
    call s:set_active_section('preamble')
    call s:set_has_dark()
    call s:set_has_light()
  endif
endf

fun! s:parse_variant_directive()
  call s:add_source_line(s:getl())
  let l:variants = []
  while s:token.next().is_edible()
    if (s:token.kind ==# 'WORD' && s:token.value ==# 'gui') || (s:token.kind ==# 'NUM')
      call add(l:variants, s:token.value)
    else
      throw "Expected number or the keyword 'gui'"
    endif
  endwhile
  call s:set_active_variants(l:variants)
endf

fun! s:parse_color_def()
  if s:token.next().kind !=# ':'
    throw 'Expected colon after Color keyword'
  endif
  let l:colorname = s:parse_color_name()
  let l:col_gui   = s:parse_gui_value()
  let l:col_256   = s:parse_base_256_value()
  let l:col_16    = s:parse_base_16_value()
  call s:add_color(s:active_section(), l:colorname, l:col_gui, l:col_256, l:col_16)
  if s:token.next().is_edible()
    throw 'Extra characters at end of line'
  endif
endf

fun! s:parse_color_name()
  if s:token.next().kind !=# 'WORD'
    throw 'Invalid color name'
  endif
  let l:name = s:token.value
  if l:name ==? 'none' || l:name ==? 'fg' || l:name ==? 'bg' || l:name ==? 'omit'
    throw "'".l:name."' is a reserved name and cannot be overridden"
  endif
  return l:name
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
    return l:rgb_name
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
    if l:val > 255 || l:val < 0
      throw 'Color value is out of range [0,255]'
    endif
    return l:val
  endif
  throw 'Expected number or tilde'
endf

fun! s:parse_base_16_value()
  if !s:token.next().is_edible()
    return '-1' " Return a value that will cause an error if used
  elseif s:token.kind ==# 'NUM'
    let l:val = s:token.value
    if str2nr(l:val) > 15 || str2nr(l:val) < 0
      throw 'Color value is out of range [0,15]'
    endif
    if s:token.next().kind ==# '*'
      if str2nr(l:val) > 7
        throw 'Color value is out of range [0,7]'
      endif
      return l:val.'*'
    endif
    return l:val
  elseif s:token.kind ==# 'WORD'
    if s:token.value ==# 'none'
      return 'NONE'
    elseif index(g:colortemplate#colorspace#ansi_colors, tolower(s:token.value)) == -1
      throw "Invalid color name: " . s:token.value
    endif
    return s:token.value
  else
    throw 'Expected number or color name'
  endif
endf

fun! s:parse_term_colors()
  call s:add_source_line(s:getl())
  while s:token.next().is_edible()
    if !s:is_color_defined(s:token.value, s:active_section())
      throw 'Undefined color name: ' . s:token.value
    endif
    call s:add_term_ansi_color(s:token.value, s:active_section())
  endwhile
endf

fun! s:parse_hi_group_def()
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
  if l:colorname ==# 'bg' && s:has_active_term_variant()
    call s:add_warning(s:currfile(), s:linenr(), s:token.pos,
          \ "Using 'bg' may cause an error with transparent backgrounds")
  endif
  call s:set_fg(l:hg, l:colorname)
  " Background color
  if s:token.next().kind !=# 'WORD'
    throw 'Background color name missing'
  endif
  let l:colorname = s:parse_color_value()
  if l:colorname ==# 'bg' && s:has_active_term_variant()
    call s:add_warning(s:currfile(), s:linenr(), s:token.pos,
          \ "Using 'bg' may cause an error with transparent backgrounds")
  endif
  call s:set_bg(l:hg, l:colorname)
  let l:hg = s:parse_attributes(l:hg)
  call s:add_highlight_group(l:hg)
  call s:add_color_pair(s:active_section(), l:hg)
endf

fun! s:parse_color_value()
  let l:color = s:token.value
  if !s:is_color_defined(l:color, s:active_section()) && l:color !~# '^\(fg\|bg\|none\|omit\)$'
    throw 'Undefined color name: ' . l:color
  endif
  return l:color
endf

fun! s:parse_attributes(hg)
  while s:token.next().is_edible()
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
    elseif s:token.value ==? 'start' || s:token.value ==? 'stop'
      call s:add_terminal_code(a:hg, s:token.value)
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

fun! s:valid_attribute(name)
  return (a:name =~# '\m^\%(bold\|italic\|under\%(line\|curl\)\|\%(rev\|inv\)erse\|standout\|strikethrough\|nocombine\|omit\)$')
endf

fun! s:parse_attr_list()
  if s:token.kind !=# 'WORD' || !s:valid_attribute(s:token.value)
    throw 'Invalid attribute'
  endif
  let l:attrlist = [s:token.value]
  while s:token.peek().kind ==# ','
    if s:token.next().next().kind !=# 'WORD' || !s:valid_attribute(s:token.value)
      throw 'Invalid attribute list'
    endif
    call add(l:attrlist, s:token.value)
  endwhile
  return l:attrlist
endf

fun! s:add_terminal_code(hg, type)
  if s:token.next().kind !=# '='
    throw "Expected = symbol after '".a:type."'"
  endif
  let [l:val, _, l:end] = matchstrpos(s:getl(), '\zs\S*', s:token.pos)
  call s:token.skip(l:end)
  if empty(l:val)
    throw 'Missing value after ='
  endif
  call s:set_terminal_code(a:hg, a:type, l:val)
endf

fun! s:parse_linked_group_def()
  let l:source_group = s:token.value
  if s:token.next().kind !=# '-' || s:token.next().kind !=# '>'
    throw 'Expected ->'
  endif
  if s:token.next().kind !=# 'WORD'
    throw 'Expected highlight group name'
  endif
  for l:v in s:active_variants()
    call s:add_linked_item(l:v, s:active_section(), l:source_group, s:token.value)
  endfor
  if s:token.next().is_edible()
    throw 'Extra token in linked group definition'
  endif
endf

fun! s:parse_command(cmd)
  call s:start_verbatim()
  if a:cmd =~# '\m^if$'
    call s:start_if()
  elseif a:cmd =~# '\m^endif$'
    call s:stop_if()
  elseif a:cmd =~# '\m^else' && !s:is_if()
    throw a:cmd.' without if'
  endif
  let l:text = matchstr(s:getl(), '^\s*#\zs.\{-}\s*$')
  for l:v in s:active_variants()
    call s:add_verbatim_item(l:v, s:active_section(),
          \ { 'line': l:text, 'linenr': s:linenr(), 'file': s:currfile() })
  endfor
  call s:stop_verbatim()
endf

fun! s:parse_colortemplate_options()
  while s:token.next().is_edible()
    if s:token.kind !=# 'WORD'
      throw 'Expected option name'
    endif
    let l:opt = s:token.value
    if l:opt !~# '\m^\%('.join(s:options(), '\|').'\)$'
      throw 'Invalid option name: '.l:opt
    endif
    if s:token.next().kind !=# '='
      throw "Expected = symbol after option name"
    endif
    if s:token.next().kind !=# 'NUM'
      throw 'Option value must be a number'
    endif
    call s:setopt(l:opt, s:token.value)
  endwhile
endf
" }}} Parser
" Init/clear parser {{{
fun! s:init_parser()
  let g:colortemplate_exit_status = 0
  call s:init_tokenizer()
  call s:init_includes()
  call s:init_active_section()
  call s:init_variants()
  call s:init_verbatim()
  call s:init_auxfiles_parsing()
endf

fun! s:destroy_parser()
  call s:destroy_tokenizer()
  call s:destroy_includes()
  call s:destroy_active_section()
  call s:destroy_variants()
  call s:destroy_verbatim()
  call s:destroy_auxfiles_parsing()
endf
" }}}
" }}}
" Checks {{{
fun! s:assert_requirements()
  if empty(s:fullname())
    call s:add_generic_error('Please specify the full name of your color scheme')
  endif
  if empty(s:shortname())
    call s:add_generic_error('Please specify the short name of your color scheme')
  endif
  if empty(s:author())
    call s:add_generic_error("Please add 'Author: name <email>'")
  endif
  if empty(s:maintainer())
    call s:set_default_maintainer()
  endif
  for l:v in s:supported_variants()
    if (s:has_dark() && !s:has_normal(l:v, 'dark')) || (s:has_light() && !s:has_normal(l:v, 'light'))
      call s:add_generic_error('Please define the Normal highlight group for '
            \ .(s:is_gui(l:v) ? 'true' : l:v).'-color variant')
    endif
  endfor
  for l:section in s:supported_backgrounds()
    let l:tc = s:term_colors(l:section)
    if empty(l:tc)
      call s:add_generic_warning("'Term Colors' key missing for " . l:section . ' background')
    elseif len(l:tc) < 16
      call s:add_generic_error('Too few terminal ANSI colors (' . l:section . ' background)')
    elseif len(l:tc) > 16
      call s:add_generic_error('Too many terminal ANSI colors (' . l:section . ' background)')
    endif
  endfor
  if !s:ifs_are_balanced()
    call s:add_generic_error('#if without #endif')
  endif
endf
" }}}
" Colorscheme generation {{{
fun! s:generate_aux_files(outdir, overwrite)
  if get (g:, 'colortemplate_no_aux_files', 0)
    return
  endif
  for l:path in s:auxfile_paths()
    if match(l:path, '^doc' . s:slash()) > -1 && get(g:, 'colortemplate_no_doc', 0)
      continue
    endif
    let l:lines = map(s:auxfile(l:path), { _,l -> s:interpolate('256', 'dark', l['line'], l['linenr'], l['file']) })
    if !s:is_error_state()
      call s:write_list(l:lines, l:path, { 'dir': a:outdir }, a:overwrite)
    endif
  endfor
endf

fun! s:hi_item(text, value)
  return (a:value ==# 'omit' ? '' : ' '.a:text.'='.a:value)
endf

fun! s:eval(item, col, section)
  let l:v = s:item_value(a:item)
  if s:is_higroup_type(a:item)
    if a:col > 256
      let l:fg = s:guifg(l:v, a:section)
      let l:bg = s:guibg(l:v, a:section)
      let l:sp = s:guisp(l:v, a:section)
      let l:attr = s:gui_attr(l:v)
      " When guifg=NONE and guibg=NONE, Vim uses the values of ctermfg/ctermbg
      " See https://github.com/lifepillar/vim-colortemplate/issues/15.
      " See also https://github.com/vim/vim/issues/1740
      let l:def = s:hi_item('guifg', l:fg)
            \ . s:hi_item('guibg', l:bg)
            \ . s:hi_item('guisp', l:sp)
            \ . (l:attr ==# 'omit'
            \   ? ''
            \   : (' gui='.l:attr
            \   . (l:fg ==# 'NONE' && l:bg ==# 'NONE' ? ' ctermfg=NONE ctermbg=NONE' : '')
            \   . ' cterm='.l:attr)
            \   )
    elseif a:col > 16
      let l:fg = s:fg256(l:v, a:section)
      let l:bg = s:bg256(l:v, a:section)
      let l:attr = s:term_attr(l:v)
      let l:def = s:hi_item('ctermfg', l:fg)
            \ . s:hi_item('ctermbg', l:bg)
            \ . s:hi_item('cterm', l:attr)
            \ . s:hi_item('start', s:terminal_code(l:v, 'start'))
            \ . s:hi_item('stop', s:terminal_code(l:v, 'stop'))
    elseif a:col > 2
      let l:fg = s:fg16(l:v, a:section)
      let l:bg = s:bg16(l:v, a:section)
      let l:attr = s:term_attr(l:v)
      let l:def = s:hi_item('ctermfg', l:fg)
            \ . s:hi_item('ctermbg', l:bg)
            \ . s:hi_item('cterm', l:attr)
            \ . s:hi_item('start', s:terminal_code(l:v, 'start'))
            \ . s:hi_item('stop', s:terminal_code(l:v, 'stop'))
    elseif a:col > 0
      let l:attr = s:term_attr(l:v)
      let l:def = s:hi_item('term', l:attr)
            \ . s:hi_item('start', s:terminal_code(l:v, 'start'))
            \ . s:hi_item('stop', s:terminal_code(l:v, 'stop'))
    endif
    if empty(l:def)
      call s:add_generic_error('Vacuous definition for '.s:hi_name(l:v)
            \ . ' ('.(a:col > 256 ? 'GUI' : a:col.' colors').', '.a:section.' background)')
    endif
    return 'hi ' . s:hi_name(l:v) . l:def
  elseif s:is_linked_type(a:item)
    return 'hi! link ' . l:v[0] . ' ' . l:v[1]
  elseif s:is_verb_type(a:item)
    return s:interpolate(string(a:col), a:section, l:v['line'], l:v['linenr'], l:v['file'])
  elseif s:is_raw_type(a:item)
    return l:v
  elseif s:is_italic_type(a:item)
    if a:col > 256
      let l:attr = s:gui_attr_no_italics(l:v)
      " Need to set cterm even for termguicolors (see https://github.com/vim/vim/issues/1740)
      return 'hi ' . s:hi_name(l:v) . ' gui='.l:attr . ' cterm='.l:attr
    else
      let l:attr = s:term_attr_no_italics(l:v)
      return 'hi ' . s:hi_name(l:v) . (a:col > 2 ? ' c' : ' ') . 'term='.l:attr
    endif
  else
    throw 'FATAL: unknown item type' " This should never happen!
  endif
endf

" Append a String to the end of the current buffer.
fun! s:put(bufnr, line)
  call s:appendbufline(a:bufnr, '$', a:line)
endf

fun! s:print_header(bufnr)
  call s:setbufline(a:bufnr, 1, '" Name:         ' . s:fullname()              )
  if !empty(s:version())
    call s:put  (a:bufnr,       '" Version:      ' . s:version()               )
  endif
  if !empty(s:description()                                                    )
    call s:put(a:bufnr,         '" Description:  ' . s:description()           )
  endif
  call s:put  (a:bufnr,         '" Author:       ' . s:fullauthor()            )
  call s:put  (a:bufnr,         '" Maintainer:   ' . s:maintainer()            )
  if !empty(s:url()                                                            )
    call s:put(a:bufnr,         '" URL:          ' . s:url()                   )
  endif
  if !empty(s:website()                                                        )
    call s:put(a:bufnr,         '" Website:      ' . s:website()               )
  endif
  call s:put  (a:bufnr,         '" License:      ' . s:license()               )
  if s:getopt('timestamp')
    call s:put  (a:bufnr,       '" Last Updated: ' . strftime("%c")            )
  endif
  if s:getopt('creator')
    call s:put  (a:bufnr,     ''                                               )
    call s:put  (a:bufnr,     '" Generated by Colortemplate v' . s:VERSION     )
  endif
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
  call s:put  (a:bufnr,   'syntax reset'                                       )
  call s:put  (a:bufnr, 'endif'                                                )
  call s:put  (a:bufnr, ''                                                     )
  call s:put  (a:bufnr, "let g:colors_name = '" . s:shortname() . "'"          )
  call s:put  (a:bufnr, ''                                                     )
  call s:put  (a:bufnr, "let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2")
  if s:uses_italics()
    let l:itcheck =  "let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || has('gui_running')"
    if s:supports_neovim()
      let l:itcheck .= " || has('nvim')"
    endif
    call s:put(a:bufnr, l:itcheck)
  endif
endf

fun! s:finish_endif(bufnr)
  call s:put(a:bufnr, 'unlet s:t_Co' . (s:uses_italics() ? ' s:italics' : ''))
  call s:put(a:bufnr, 'finish')
  call s:put(a:bufnr, 'endif')
endf

fun! s:print_footer(bufnr)
  call s:put(a:bufnr, s:getopt('use_tabs') ? '" vim: noet' : '" vim: et ts=2 sw=2')
endf

" In Vim < 8.1.0616, `hi Normal ctermbg=...` may change the value of
" 'background'. This function generates code to reset the background if
" needed. The function's name is a reference to the original issue report,
" which had an example using color 234.
" See https://github.com/lifepillar/vim-colortemplate/issues/13.
fun! s:check_bug_bg234(bufnr, bg, item, ncols)
  if s:is_higroup_type(a:item) && s:hi_name(s:item_value(a:item)) ==? 'Normal'
    let l:v = s:item_value(a:item)
    if a:bg ==# 'dark'
      if (a:ncols > 16 && (s:bg256(l:v, a:bg) !=# 'NONE')) ||
            \ s:bg16(l:v, a:bg) =~? '\m^\%(7\*\=\|9\*\=\|\d\d\|Brown\|DarkYellow\|\%(Light\|Dark\)\=\%(Gr[ae]y\)\|\%[Light]\%(Blue\|Green\|Cyan\|Red\|Magenta\|Yellow\)\|White\)$'
        call s:put(a:bufnr, "if !has('patch-8.0.0616')" . (s:supports_neovim() ? " && !has('nvim')" : '') . ' " Fix for Vim bug')
        call s:put(a:bufnr, 'set background=dark')
        call s:put(a:bufnr, 'endif')
      endif
    else " light background
      if (a:ncols > 2 && a:ncols <= 16) &&
            \ (s:bg16(l:v, a:bg) =~# '\m^\%(\%(0\|1\|2\|3\|4\|5\|6\|8\)\*\=\|Black\|Dark\%(Blue\|Green\|Cyan\|Red\|Magenta\)\)$')
        call s:put(a:bufnr, "if !has('patch-8.0.0616')" . (s:supports_neovim() ? " && !has('nvim')" : ''))
        call s:put(a:bufnr, 'set background=light')
        call s:put(a:bufnr, 'endif')
      endif
    endif
  endif
endf

fun! s:print_global_preamble(bufnr)
  if !empty(s:global_preamble())
    call s:put(a:bufnr, '')
    for l:item in s:global_preamble()
      call s:put(a:bufnr, s:eval(l:item, 256, 'preamble'))
    endfor
  endif
  if s:getopt('ignore_missing')
    call s:put(a:bufnr, '')
    for l:g in s:default_hi_groups()
      if !s:hi_group_exists(l:g)
        call s:put(a:bufnr, '" @suppress '.l:g)
      endif
    endfor
  endif
endf

fun! s:print_terminal_colors(bufnr, variant, section)
  if !s:is_gui(a:variant) || len(s:term_colors(a:section)) != 16
    return
  endif
  if a:section !=# 'preamble' && len(s:term_colors('preamble')) == 16
    " Already added in the preamble
    return
  endif
  let l:tc = s:term_colors(a:section)
  let l:col0_3 = join(map(copy(l:tc[0:3]), { _,c -> "'".s:guicol(c, a:section)."'" }), ', ')
  let l:col4_9 = join(map(copy(l:tc[4:9]), { _,c -> "'".s:guicol(c, a:section)."'" }), ', ')
  let l:col10_15 = join(map(copy(l:tc[10:15]), { _,c -> "'".s:guicol(c, a:section)."'" }), ', ')
  call s:put(a:bufnr, 'let g:terminal_ansi_colors = ['.l:col0_3.',')
  call s:put(a:bufnr, '\ '.l:col4_9.',')
  call s:put(a:bufnr, '\ '.l:col10_15.']')
  if s:supports_neovim()
    let l:n = 0
    call s:put(a:bufnr, "if has('nvim')")
    for l:color in l:tc
      call s:put(a:bufnr, "let g:terminal_color_".string(l:n)." = '".s:guicol(l:color, a:section)."'")
      let l:n += 1
    endfor
    call s:put(a:bufnr, 'endif')
  endif
endf

fun! s:print_colorscheme_defs(bufnr, variant, section)
  call s:print_terminal_colors(a:bufnr, a:variant, a:section)
  let l:ncols = str2nr(a:variant)
  for l:item in s:colorscheme_definitions(a:variant, a:section)
    call s:put(a:bufnr, s:eval(l:item, l:ncols, a:section))
    if !s:is_gui(a:variant)
      call s:check_bug_bg234(a:bufnr, a:section, l:item, l:ncols)
    endif
  endfor
endf

" Prints source as comment, for provenance
fun! s:print_source_code(bufnr)
  let l:sc = s:getopt('source_comment')
  if l:sc == 1
    for l:line in s:source_lines()
      if l:line =~? '\m^\s*\%(Background\|Color\|Term\s\+colors\)\s*:'
        call s:put(a:bufnr, '" '.l:line)
      endif
    endfor
  elseif l:sc == 2
    for l:line in s:source_lines()
      call s:put(a:bufnr, '" '.l:line)
    endfor
  endif
endf

fun! s:print_colorscheme(bufnr, variant)
  call s:put(a:bufnr, '')
  if s:is_gui(a:variant)
    call s:put(a:bufnr, "if (has('termguicolors') && &termguicolors) || has('gui_running')")
  else
    call s:put(a:bufnr, 'if s:t_Co >= ' . a:variant)
  endif
  call s:print_colorscheme_defs(a:bufnr, a:variant, 'preamble')
  if s:has_dark_and_light()
    if s:has_colorscheme_definitions(a:variant, 'dark')
      call s:put(a:bufnr, "if &background ==# 'dark'")
      call s:print_colorscheme_defs(a:bufnr, a:variant, 'dark')
      call s:finish_endif(a:bufnr) " endif dark background
    endif
    if s:has_colorscheme_definitions(a:variant, 'light')
      call s:put(a:bufnr, '" Light background')
      call s:print_colorscheme_defs(a:bufnr, a:variant, 'light')
    endif
  else " One background
    let l:background = s:has_dark() ? 'dark' : 'light'
    call s:print_colorscheme_defs(a:bufnr, a:variant, l:background)
  endif
  call s:finish_endif(a:bufnr) " endif termguicolors/t_Co
endf

fun! s:generate_colorscheme(outdir, overwrite)
  let l:bufnr = s:new_work_buffer()
  call s:print_header(l:bufnr)
  call s:print_global_preamble(l:bufnr)
  for l:variant in s:supported_variants()
    call s:print_colorscheme(l:bufnr, l:variant)
  endfor
  call s:put(l:bufnr, '')
  call s:print_source_code(l:bufnr)
  call s:print_footer(l:bufnr)
  call s:reindent_buffer(l:bufnr)
  if s:is_error_state()
    call s:destroy_buffer(l:bufnr)
    return ''
  endif
  if !empty(a:outdir)
    let l:outpath = a:outdir . s:slash() . 'colors' . s:slash() . s:shortname() . '.vim'
    try
      call s:write_buffer(l:bufnr, l:outpath, { 'dir': a:outdir }, a:overwrite)
      call s:clearscreen()
    finally
      call s:destroy_buffer(l:bufnr)
    endtry
    return l:outpath
  endif
endf
" }}}
" Colorscheme switching {{{
let s:enabled_colors = []
let s:prev_colors = get(g:, 'colors_name', 'default')
let s:prev_background = &background

fun! s:view_colorscheme(colors_name)
  let l:current_colors = get(g:, 'colors_name', 'default')
  if index(s:enabled_colors, l:current_colors) < 0
    let s:prev_colors = l:current_colors
    let s:prev_background = &background
  endif
  try
    execute 'colorscheme' a:colors_name
  catch /.*/
    call s:print_error_msg(v:exception, 0)
  endtry
  if index(s:enabled_colors, a:colors_name) < 0
    call add(s:enabled_colors, a:colors_name)
  endif
endf

fun! s:restore_colorscheme()
  let s:enabled_colors = []
  let &background = s:prev_background
  execute 'colorscheme' s:prev_colors
endf
" }}}
" Public interface {{{
fun! colortemplate#outdir()
  return get(b:, 'colortemplate_outdir', getcwd())
endf

fun! colortemplate#setoutdir(newdir)
  let l:newdir = substitute(simplify(fnamemodify(a:newdir, ':p')), "[\\/]$", "", "")
  if !isdirectory(l:newdir)
    call s:print_error_msg('Directory does not exist', 0)
    return
  elseif filewritable(l:newdir) != 2
    call s:print_error_msg('Directory is not writable', 0)
    return
  endif
  let b:colortemplate_outdir = l:newdir
  if get(g:, 'colortemplate_rtp', 1)
    execute 'set runtimepath^='.b:colortemplate_outdir
  endif
endf

fun! colortemplate#askoutdir()
  echo colortemplate#outdir()
  let l:newdir = input('Change to: ', '', 'dir')
  if !has('patch-8.1.1456')
    redraw! " See https://github.com/vim/vim/issues/4473
  endif
  if empty(l:newdir)
    return
  endif
  call colortemplate#setoutdir(l:newdir)
  call colortemplate#toolbar#show()
endf

fun! colortemplate#parse(filename) abort
  call s:init_data_structures()
  call s:init_parser()
  call s:setwd(fnamemodify(a:filename, ":h"))
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
      call s:destroy_parser()
      call s:destroy_data_structures()
      throw 'Parse error'
    catch /.*/
      call s:add_error(s:currfile(), s:linenr(), s:token.spos + 1, v:exception)
    endtry
  endwhile
  for l:v in s:supported_variants()
    for l:s in ['preamble', 'dark', 'light']
      call s:flush_definitions(l:v, l:s)
    endfor
  endfor
  call s:assert_requirements()
  call s:show_errors('Parse error')
  call s:destroy_parser()
endf

" a:1 is the optional path to an output directory
" a:2 is ! when files should be overwritten
" a:3 is 0 when the quickfix should not be cleared
fun! colortemplate#make(...)
  update
  if a:0 > 0 && !empty(a:1)
    call colortemplate#setoutdir(a:1)
  endif
  let l:outdir = colortemplate#outdir()
  let l:overwrite = (a:0 > 1 ? (a:2 == '!') : 0)
  if !empty(l:outdir)
    if !isdirectory(l:outdir)
      call s:print_error_msg("Path is not a directory: " . l:outdir, 0)
      let g:colortemplate_exit_status = 1
      return g:colortemplate_exit_status
    elseif filewritable(l:outdir) != 2
      call s:print_error_msg("Directory is not writable: " . l:outdir, 0)
      let g:colortemplate_exit_status = 1
      return g:colortemplate_exit_status
    endif
  endif

  if !empty(getbufvar('%', '&buftype')) || empty(expand('%:p'))
    call s:print_error_msg("No filename. Please save your document first.", 0)
    return g:colortemplate_exit_status
  endif

  if get(a:000, 2, 1)
    call setqflist([], 'r') " Reset quickfix list
  endif

  let l:start_time = reltime()

  let l:inpath = expand('%:p')
  call s:print_notice('Building '.fnamemodify(l:inpath, ':t:r').'...')
  call s:init_data_structures()
  try
    call colortemplate#parse(l:inpath)
  catch /Parse error/
    call s:print_error_msg('Parse error', 0)
    call s:destroy_data_structures()
    let g:colortemplate_exit_status = 1
    return g:colortemplate_exit_status
  catch /.*/
    call s:print_error_msg('Unexpected error: ' . v:exception, 0)
    call s:destroy_data_structures()
    let g:colortemplate_exit_status = 1
    return g:colortemplate_exit_status
  endtry

  try
    let l:outpath = s:generate_colorscheme(l:outdir, l:overwrite)
    call s:generate_aux_files(l:outdir, l:overwrite)
    call s:show_errors('Build error')
    if !s:getopt('quiet')
      call colortemplate#view_source()
    endif
  catch /.*/
    let g:colortemplate_exit_status = 1
    call s:print_error_msg(v:exception, 0)
    return g:colortemplate_exit_status
  finally
    call s:destroy_data_structures()
  endtry
  let l:elapsed = 1000.0 * reltimefloat(reltime(l:start_time))
  call s:print_notice(printf('Success! [%s created in %.00fms]', fnamemodify(l:outpath, ':t'), l:elapsed))
endf

" a:1 is the optional path to an output directory
" a:2 is ! when files should be overwritten
fun! colortemplate#build_dir(...)
  call setqflist([], 'r') " Reset quickfix list

  let l:wd = expand('%:p:h')

  if !empty(getbufvar('%', '&buftype')) || empty(l:wd)
    call s:print_error_msg("No filename. Please save your document first.", 0)
    return
  endif

  let l:n = 0
  let l:outdir = (a:0 > 0 && !empty(a:1) ? simplify(fnamemodify(a:1, ':p')) : colortemplate#outdir())
  let l:start_time= reltime()
  for l:template in glob(l:wd.s:slash().'[^_]*.colortemplate', 1, 1, 1)
    execute "edit" l:template
    call colortemplate#make(l:outdir, get(a:000, 1, ''), 0)
    let l:n += 1
  endfor
  if g:colortemplate_exit_status
    call s:print_error_msg('Build failed. See :messages', 0)
  else
    let l:elapsed = 1000.0 * reltimefloat(reltime(l:start_time))
    call s:print_notice(printf('Success! [%s color scheme%s created in %.00fms]', string(l:n), (l:n > 1 ? 's' : ''), l:elapsed))
  endif
endf

fun! colortemplate#stats()
  update
  call s:print_notice('Computing color statistics...')
  let l:old_warning_pref = get(g:, 'colortemplate_warnings', -1)
  let g:colortemplate_warnings = 0
  try
    call setqflist([], 'r') " Reset quickfix list
    call colortemplate#parse(expand('%:p'))
  catch /Parse error/
    call s:destroy_data_structures()
    let g:colortemplate_exit_status = 1
    return
  catch /.*/
    call s:print_error_msg('Unexpected error: ' . v:exception)
    call s:destroy_data_structures()
    let g:colortemplate_exit_status = 1
    return
  finally
    if l:old_warning_pref < 0
      unlet! g:colortemplate_warnings
    else
      let g:colortemplate_warnings = l:old_warning_pref
    endif
  endtry
  call s:print_color_info()
  call s:clearscreen()
endf

fun! colortemplate#path()
  let l:bufname = fnamemodify(bufname('%'), ':p:t')
  if getbufvar('%', '&ft', '') ==# 'colortemplate'
    let l:match = matchlist(getbufline('%', 1, "$"), '\m\c^\s*Short\s*name:\s*\(\w\+\)')
    if empty(l:match)
      let l:name = fnamemodify(l:bufname, ':r')
    else
      let l:name = l:match[1]
    endif
  else
    return ''
  endif
  let l:path = colortemplate#outdir() . s:slash() . 'colors' . s:slash() . l:name . '.vim'
  if empty(l:name) || !filereadable(l:path)
    call s:print_error_msg('Please build the colorscheme first', 0)
    return ''
  endif
  return l:path
endf

fun! colortemplate#view_source() abort
  let l:path = colortemplate#path()
  if empty(l:path) | return 0 | endif
  execute "keepalt split" l:path
  call s:clearscreen()
  return 1
endf

fun! colortemplate#validate() abort
  if colortemplate#view_source()
      call s:print_notice('Validating color scheme, please wait...')
    runtime colors/tools/check_colors.vim
    if !has('patch-8.1.1406') " Approximates when colors/tools/check_colors.vim was updated
      echo ('[Colortemplate] Warnings about missing fg may be ignored')
    endif
    call input('[Colortemplate] Press a key to continue')
    wincmd c
  endif
endf

fun! colortemplate#enable_colorscheme() abort
  let l:path = colortemplate#path()
  if empty(l:path) | return | endif
  call s:view_colorscheme(fnamemodify(l:path, ':t:r'))
endf

fun! colortemplate#disable_colorscheme()
  call s:restore_colorscheme()
endf

fun! colortemplate#colortest()
  call colortemplate#enable_colorscheme()
  runtime syntax/colortest.vim
endf

fun! colortemplate#highlighttest()
  call colortemplate#enable_colorscheme()
  runtime syntax/hitest.vim
endf

fun! colortemplate#getinfo(n)
  let l:name = s:quickly_parse_color_line()
  if empty(l:name) | return | endif
  let l:hexc = s:guihex(l:name, 'dark') " 2nd arg doesn't matter
  let l:best = colortemplate#colorspace#approx(l:hexc)
  let l:c256 = s:col256(l:name, 'dark') == -1 ? l:best['index'] : s:col256(l:name, 'dark')
  let [l:r, l:g, l:b] = colortemplate#colorspace#hex2rgb(l:hexc)
  try
    execute "hi!" "ColortemplateInfoFg" "ctermfg=".l:c256 "guifg=".l:hexc "ctermbg=NONE guibg=NONE"
    execute "hi!" "ColortemplateInfoBg" "ctermbg=".l:c256 "guibg=".l:hexc "ctermfg=NONE guifg=NONE"
  catch /^Vim\%((\a\+)\)\=:E254/ " Cannot allocate color
    hi clear ColortemplateInfoFg
    hi clear ColortemplateInfoBg
  endtry
  echon printf('%s: rgb(%d,%d,%d) ', l:name, l:r, l:g, l:b)
  echohl ColortemplateInfoFg | echon 'xxx' | echohl None
  echon printf(' %s ', l:hexc)
  echohl ColortemplateInfoBg | echon '   ' | echohl None
  echon ' Best xterm approx:'
  if a:n == 1
    let l:approx = [l:best]
  else
    let l:approx = colortemplate#colorspace#k_neighbours(l:hexc, a:n)
  endif
  for l:item in l:approx
    let l:x = l:item['index']
    let l:g = colortemplate#colorspace#xterm256_hexvalue(l:x)
    echon printf(' %d', l:x)
    execute "hi!" "ColortemplateInfoBg".l:x "ctermbg=".l:x "guibg=".l:g "ctermfg=NONE guifg=NONE"
    execute 'echohl ColortemplateInfoBg'.l:x | echon '   ' | echohl None
    echon printf('@%.2f', l:item['delta'])
  endfor
endf

fun! colortemplate#approx_color(n)
  let l:name = s:quickly_parse_color_line()
  if empty(l:name) | return | endif
  let l:hexc = s:guihex(l:name, 'dark') " 2nd arg doesn't matter
  let l:col = colortemplate#colorspace#k_neighbours(l:hexc, a:n)[-1]['index']
  call setline('.', substitute(getline('.'), '\~', l:col, ''))
endf

fun! colortemplate#nearby_colors(n)
  let l:name = s:quickly_parse_color_line()
  if empty(l:name) | return | endif
  echo colortemplate#colorspace#colors_within(a:n, s:guihex(l:name, 'dark'))
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
" - Support for font in highlight group definitions?
" }}}
