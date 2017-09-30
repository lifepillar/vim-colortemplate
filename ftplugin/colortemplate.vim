" Name:        Colorscheme template
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" Initialization {{{
fun! s:init()
  let s:template = []
  let s:full_name = ''
  let s:short_name = ''
  let s:author = ''
  let s:maintainer = ''
  let s:website = ''
  let s:description = ''
  let s:background = ''
  let s:palette = {
        \ 'none': ['NONE', 'NONE', 'NONE'],
        \ 'fg':   ['fg',   'fg',   'fg'  ],
        \ 'bg':   ['bg',   'bg',   'bg'  ]
        \ }
  let s:transp_hi_group = [] " hi group definitions for transparent background
  let s:opaque_hi_group = [] " hi group definitions for opaque background
  let s:hi_group        = [] " hi group definitions that do not depend on transparency
  let s:use16colors     = get(g:, 'base16template', 0)
  call setloclist(0, [], 'r') " Used for errors
endf
" }}}

" Helper functions {{{

" Convert a hexadecimal color string into a three-elements list of RGB values.
fun! s:hex2rgb(col)
  return map(matchlist(a:col, '^#\?\(..\)\(..\)\(..\)$')[1:3], 'str2nr(v:val,16)')
endf

" Convert an RGB color into the equivalent hexadecimal String.
"
" Example: call s:rgb2hex(255,255,255) -> '#ffffff'
fun! s:rgb2hex(r,g,b)
  return '#' . printf('%02x', a:r) . printf('%02x', a:g) . printf('%02x', a:b)
endf

fun! s:add_warning(msg, ...)
  call setloclist(0, [{'bufnr': bufnr('%'), 'lnum': (a:0 > 0 ? a:1 + 1, 1), 'text': a:msg, 'type': 'W'}], 'a')
endf

fun! s:add_error(msg, ...)
  call setloclist(0, [{'bufnr': bufnr('%'), 'lnum': a:0 > 0 ? a:1+1 : 1, 'text': a:msg, 'type': 'E'}], 'a')
endf

" Append a String to the end of the current buffer.
fun! s:put(line)
  call append(line('$'), a:line)
endf

" Return a string specifying cterm/gui attributes for a highlight group.
"
" dict: a Dictionary whose values are Strings of attributes (e.g., 'bold,reverse')
" key: one among 'cterm' or 'gui'
fun! s:attr(dict, key)
  return a:key.'=NONE'.(empty(get(a:dict, a:key, '')) ? '' : ','.a:dict[a:key])
endf

" Return a highlight group definition as a String.
"
" group: the name of the highlight group
" fg: the name of the foreground color for the group
" bg: the name of the background color for the group
" attrs: a Dictionary of additional attributes
"
" Color names are as specified in the color palette of the template.
fun! s:hlstring(group, fg, bg, attrs)
  return join([
        \ 'hi', a:group,
        \ 'ctermfg=' . s:palette[a:fg][s:use16colors ? 2 : 1],
        \ 'ctermbg=' . s:palette[a:bg][s:use16colors ? 2 : 1],
        \ 'guifg='   . s:palette[a:fg][0],
        \ 'guibg='   . s:palette[a:bg][0],
        \ 'guisp='   . get(s:palette, get(a:attrs, 'guisp', ''), ['NONE'])[0],
        \ s:attr(a:attrs, 'cterm'),
        \ s:attr(a:attrs, 'gui')
        \ ])
endf

fun! s:new_buffer()
  silent tabnew +setlocal\ ft=vim
  " execute 'file' s:short_name.(s:use16colors ? '_16' : '').'.vim'
endf

fun! s:print_header()
  call setline(1, '" Name:         ' . s:full_name                                                    )
  if !empty(s:description)
    call s:put(   '" Description:  ' . s:description                                                  )
  endif
  call s:put  (   '" Author:       ' . s:author                                                       )
  call s:put  (   '" Maintainer:   ' . s:maintainer                                                   )
  if !empty(s:website)
    call s:put(   '" Website:      ' . s:website                                                      )
  endif
  call s:put  (   '" License:      Vim License  (see `:help license`)'                                )
  call s:put  (   ''                                                                                  )
  call s:put  (   "if !exists('&t_Co')"                                                               )
  call s:put  (   '" FIXME: Do something?'                                                            )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  if !empty(s:background)
    call s:put(   'set background=' . s:background                                                    )
  endif
  call s:put  (   ''                                                                                  )
  call s:put  (   'hi clear'                                                                          )
  call s:put  (   "if exists('syntax_on')"                                                            )
  call s:put  (   '  syntax reset'                                                                    )
  call s:put  (   'endif'                                                                             )
  call s:put  (   ''                                                                                  )
  call s:put  (   "let g:colors_name = '" . s:short_name . (s:use16colors ? '_16' : '') . "'"         )
endf
" }}}

" Parser {{{
" Parse a color definition and store it internally.
fun! s:set_color(line, linenr)
  let l:match  = matchlist(a:line,
        \   '^\(\w\+\)\s\+'
        \ . '\(#[a-f0-9]\{6\}\|rgb\s*(\s*\d\{1,3}\s*,\s*\d\{1,3}\s*,\s*\d\{1,3}\s*)\)\s\+'
        \ . '\(\d\{1,3}\)\s*'
        \ . '\(\w*\)$')
  if empty(l:match)
    call s:add_error('Syntax error: ' . a:line, a:linenr)
    return
  endif
  let [l:name, l:gui, l:base256, l:base16] = [l:match[1], l:match[2], l:match[3], l:match[4]]
  if l:name =~ '^fg\|bg\|none$'
    call s:add_error('You cannot use ' . l:name . 'to define a color name', a:linenr)
  endif
  if l:gui =~ 'rgb'
    let [l:r, l:g, l:b] = map(split(matchstr(l:gui, '(\zs.\+\ze)'), ','), 'str2nr(v:val)')
    let l:gui = s:rgb2hex(l:r, l:g, l:b)
  endif
  let s:palette[l:name] = [l:gui, l:base256, empty(l:base16) ? 'Black' : l:base16]
endf

fun! s:check_valid_color(col, linenr)
  if !empty(a:col) && !has_key(s:palette, a:col)
    call s:add_error('Invalid color name: ' . a:col, a:linenr)
    return 0
  endif
  return 1
endf

" Parse a hi group definition and store it internally.
fun! s:set_highlight_group(line, linenr)
  if a:line =~ '->' " Linked group
    let l:match = matchlist(a:line, '^\s*\(\w\+\)\s*->\s*\(\w\+\)\s*\%(#.*\)\?$')
    if empty(l:match)
      call s:add_error('Syntax error: '.a:line, a:linenr)
    endif
    let [l:src, l:tgt] = l:match[1:2]
    call add(s:hi_group, 'hi! link ' . l:src . ' ' . l:tgt)
    return
  endif
  " Regular highlight group definition
  let l:match = matchlist(a:line,
        \   '^\s*\(\w\+\)\s\+'
        \ . '\(\w\+\)/\?\(\w*\)\s\+'
        \ . '\(\w\+\)/\?\(\w*\)\s*'
        \ . '\(.*\)$')
  if empty(l:match)
    call s:add_error('Syntax error: '.a:line, a:linenr)
    return
  endif
  let [l:group, l:fg, l:tfg, l:bg, l:tbg, l:attrs] = l:match[1:6]
  if !(s:check_valid_color(l:fg, a:linenr) && s:check_valid_color(l:tfg, a:linenr)
        \ && s:check_valid_color(l:bg, a:linenr) && s:check_valid_color(l:tbg, a:linenr))
    return
  endif
  let l:term = ''
  let l:gui = ''
  let l:sp = ''
  let l:tsp = ''
  for l:attr in split(l:attrs, '\s\+')
    if l:attr =~ '='
      let [l:key, l:value] = split(l:attr, '=')
      if l:key =~ '^te\?r\?m\?'
        let l:term = l:value
      elseif l:key =~ '^gu\?i\?'
        let l:gui = l:value
      elseif l:key =~ '^guisp\|^sp\?'
        let l:sp = l:value
        if l:sp =~ '/'
          let [l:sp, l:tsp] = split(l:sp, '/')
          if !(s:check_valid_color(l:sp, a:linenr) && s:check_valid_color(l:tsp, a:linenr))
            return
          endif
        endif
      else
        call s:add_error('Syntax error: '.l:attr, a:linenr)
      endif
    else
      let l:term = l:attr
      let l:gui = l:attr
    endif
  endfor
  if !(empty(l:tfg) && empty(l:tbg) && empty(l:tsp)) " Different definitions according to transparency
    call add(s:opaque_hi_group,
          \ s:hlstring(l:group, l:fg, l:bg, {'cterm': l:term, 'gui': l:gui, 'guisp': l:sp})
          \ )
    call add(s:transp_hi_group,
          \ s:hlstring(l:group,
          \            empty(l:tfg) ? l:fg : l:tfg,
          \            empty(l:tbg) ? l:bg : l:tbg,
          \            {'cterm': l:term, 'gui': l:gui, 'guisp': empty(l:tsp) ? l:sp : l:tsp }
          \           )
          \ )
  else
    call add(s:hi_group,
          \ s:hlstring(l:group, l:fg, l:bg, {'cterm': l:term, 'gui': l:gui, 'guisp': l:sp})
          \ )
  endif
endf

fun! s:check_requirements()
  if empty(s:full_name)
    call s:add_error('Please specify the full name of your color scheme')
  endif
  if empty(s:author)
    call s:add_error('Please specify an author and the corresponding email')
  endif
  if empty(s:maintainer)
    call s:add_error('Please specify a maintainer and the corresponding email')
  endif
endf

fun! s:parse_template(filename)
  let s:template = readfile(fnameescape(a:filename))
  for l:i in range(len(s:template))
    let l:line = s:template[l:i]
    if l:line =~ '^\s*#' " Skip comment
      continue
    endif
    if l:line =~ '^\s*$' " Skip empty line
      continue
    endif
    let l:match = matchlist(l:line, '^\s*\(\w[^:]*\):\s*\(.*\)') " Split on colon
    if empty(l:match)
      call s:set_highlight_group(l:line, l:i)
    else
      let [l:key, l:val] = [l:match[1], l:match[2]]
      if l:key =~ '^\s*color'
        call s:set_color(l:val, l:i)
      elseif l:key =~ '^\s*full\s*name'
        let s:full_name = l:val
      elseif l:key =~ '^\s*short\s*name'
        let s:short_name = l:val
      elseif l:key =~ '^\s*author'
        let s:author = l:val
      elseif l:key =~ '^\s*maintainer'
        let s:maintainer = l:val
      elseif l:key =~ '^\s*website'
        let s:website = l:val
      elseif l:key =~ '^\s*description'
        let s:description = l:val
      elseif l:key =~ '^\s*background'
        let s:background = l:val
      else
        call s:add_warning('Unknown field: ' . l:key)
      endif
    endif
  endfor
  call s:check_requirements()
  if !empty(getloclist(0))
    throw 'Parse error'
  endif
  lclose
endf
" }}}

" Colorscheme builder {{{
fun! s:make_colorscheme(...)
  call s:init()
  try
    call s:parse_template(empty(get(a:000, 0, '')) ? expand('%') : a:1)
  catch /Parse error/
    lopen
    return
  catch /.*/
    echomsg 'Unexpected error: ' v:exception
    return
  endtry
  call s:new_buffer()
  call s:print_header()
  call s:put('')
  if !empty(s:transp_hi_group)
    call s:put("if !has('gui_running') && get(g:, '".s:short_name."_transp_bg', 0)")
    call append('$', s:transp_hi_group)
    call s:put("else")
    call append('$', s:opaque_hi_group)
    call s:put("endif")
  endif
  call append('$', s:hi_group)
  call s:put('')
  " Add template as a comment (only colors and hi group definitions)
  " to make the color scheme reproducible.
  call append('$', map(
        \              filter(s:template,
        \                     { _,l -> l =~ '^\s*color\s*:' ||
        \                            !(l =~ '^\s*$'         ||
        \                              l =~ '^\s*#'         ||
        \                              l =~ '^\s*\%(\w[^:]*\):'
        \                             )
        \                     }
        \                    ),
        \              { _,l -> '" ' . l }
        \    ))
endf

command! -buffer -nargs=? -complete=file Colortemplate call <sid>make_colorscheme(<q-args>)
" }}}

" vim: foldmethod=marker nowrap
