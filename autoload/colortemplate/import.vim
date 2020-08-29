" Configurable values for the 16 terminal ANSI colors
let g:colortemplate#import#ansi_colors = [
      \ '#000000',
      \ '#990000',
      \ '#00a600',
      \ '#999900',
      \ '#0000b2',
      \ '#b200b2',
      \ '#00a6b2',
      \ '#bfbfbf',
      \ '#888888',
      \ '#e50000',
      \ '#00d900',
      \ '#e5e500',
      \ '#0000ff',
      \ '#e500e5',
      \ '#00e5e5',
      \ '#ffffff',
      \ ]

fun! s:init()
  let s:colmap        = {} " Color name => GUI value
  let s:invmap        = {} " GUI value => Color name
  let s:higroups      = {} " Highlight group definitions
  let s:linked_groups = {} " Linked groups (source => target)
  let s:name_maxlen   = 6  " Maximum length of a highlight group name
endf

fun! s:cleanup()
  unlet s:colmap
  unlet s:invmap
  unlet s:higroups
  unlet s:linked_groups
  unlet s:name_maxlen
endf

fun! s:higroup_name(synid)
  let l:name = synIDattr(a:synid, 'name')
  let s:name_maxlen = max([s:name_maxlen, len(l:name)])
  return l:name
endf

" Returns the list of the names of the currently defined highlight groups.
"
" Note: sometimes, a highlight group definition is split on two lines, e.g.:
"
" StatusLineTerm xxx term=bold,reverse cterm=bold ctermfg=0 ...
"                   links to StatusLine
"
" The second line would result in an empty name: that's why we use filter().
fun! colortemplate#import#names()
  let l:names = split(execute('hi'), '\n')
  return filter(map(l:names, 'matchstr(v:val, "^\\S\\+")'), '!empty(v:val)')
endf

" Returns the list of the synIDs of the currently defined highlight groups.
fun! colortemplate#import#ids()
  return map(colortemplate#import#names(), 'hlID(matchstr(v:val, "^\\S\\+"))')
endf

let s:n = 0
fun! s:next_color_name()
  let s:n += 1
  return 'Color' .. repeat('0', float2nr(4 - log10(s:n + 1))) . s:n
endf

" Returns a generated color name for the color of the specified type
" (fg, bg, sp) in the given highlight group. Different colors are assigned
" different names.
fun! s:assignColor(synid, type)
  let l:gui  = synIDattr(a:synid, a:type , 'gui')
  if empty(l:gui) " Try deriving it from cterm color
    let l:term = synIDattr(a:synid, a:type, 'cterm')
    if empty(l:term) " No info
      return 'none'
    endif
    if l:term !~ '\m^\d\+$'
      try " to convert name to number
        let l:term = string(colortemplate#colorspace#ctermcolor(tolower(l:term), 16))
      catch " What?!
        echohl WarningMsg
        echomsg  '[Colortemplate] Unknown color name:' l:term 'in' s:higroup_name(a:synid)
        echohl None
        return 'none'
      endtry
    endif
    try
      let l:gui = colortemplate#colorspace#xterm256_hexvalue(str2nr(l:term))
    catch " Term number is in [0,15]
      let l:gui = g:colortemplate#import#ansi_colors[str2nr(l:term)]
    endtry
  endif

  if has_key(s:invmap, l:gui) " Color already defined: return its name
    return s:invmap[l:gui]
  endif
  " New color: generate new name
  let l:name = s:next_color_name()
  let s:colmap[l:name] = l:gui
  let s:invmap[l:gui] = l:name
  return l:name
endf

fun! s:synIDattrs(synid, mode)
  return {
        \ 'fg':         synIDattr(a:synid, 'fg',        a:mode),
        \ 'bg':         synIDattr(a:synid, 'bg',        a:mode),
        \ 'sp':         synIDattr(a:synid, 'sp',        a:mode),
        \ 'bold':      (synIDattr(a:synid, 'bold',      a:mode) ==# '1' ? 1 : 0),
        \ 'italic':    (synIDattr(a:synid, 'italic',    a:mode) ==# '1' ? 1 : 0),
        \ 'reverse':   (synIDattr(a:synid, 'reverse',   a:mode) ==# '1' ? 1 : 0),
        \ 'standout':  (synIDattr(a:synid, 'standout',  a:mode) ==# '1' ? 1 : 0),
        \ 'underline': (synIDattr(a:synid, 'underline', a:mode) ==# '1' ? 1 : 0),
        \ 'undercurl': (synIDattr(a:synid, 'undercurl', a:mode) ==# '1' ? 1 : 0),
        \ 'strike':    (synIDattr(a:synid, 'strike',    a:mode) ==# '1' ? 1 : 0),
        \ }
endf

" Get info about the specified highlight group and put it into a Dictionary.
fun! s:higroup_info(synid)
  return { s:higroup_name(a:synid) :
        \ #{
        \    synid : a:synid,
        \    gui   : s:synIDattrs(a:synid, 'gui'),
        \    cterm : s:synIDattrs(a:synid, 'cterm'),
        \    term  : s:synIDattrs(a:synid, 'term'),
        \    fgname: s:assignColor(a:synid, 'fg'),
        \    bgname: s:assignColor(a:synid, 'bg'),
        \    spname: s:assignColor(a:synid, 'sp'),
        \  }
        \ }
endf

" Collect information about the currently active highlight groups
" The information is stored in the s:higroups dictionary.
" Linked groups are collected into s:linked_groups.
fun! s:collect()
  let l:allids = colortemplate#import#ids()
  for l:id in l:allids
    let l:trid = synIDtrans(l:id)
    if l:id == l:trid
      call extend(s:higroups, s:higroup_info(l:id))
    else
      let s:linked_groups[s:higroup_name(l:id)] = s:higroup_name(l:trid)
    endif
  endfor
  " Retrieve terminal ANSI colors
  if (exists('g:terminal_ansi_colors'))
    for l:c in g:terminal_ansi_colors
      if !has_key(s:invmap, l:c)
        let l:name = s:next_color_name()
        let s:colmap[l:name] = l:c
        let s:invmap[l:c] = l:name
      endif
    endfor
  endif
endf


"""
" Generates a template from the currently active highlight groups.
"""

fun! s:put(line)
  call append('$', a:line)
endf

fun! s:attr_text(higroup)
  let l:common_attr = []
  let l:term_attr = []
  let l:gui_attr = []
  for l:attr in ['bold', 'italic', 'reverse', 'standout', 'underline', 'undercurl', 'strike']
    if a:higroup['gui'][l:attr] == 1 && a:higroup['cterm'][l:attr] == 1
      call add(l:common_attr, l:attr)
    elseif a:higroup['gui'][l:attr] == 1 && a:higroup['cterm'][l:attr] == 0
      call add(l:gui_attr, l:attr)
    elseif a:higroup['gui'][l:attr] == 0 && a:higroup['cterm'][l:attr] == 1
      call add(l:term_attr, l:attr)
    endif
  endfor
  let l:s = ''
  if a:higroup['spname'] != 'none'
    let l:s .= ' guisp=' . a:higroup['spname']
  endif
  if !empty(l:common_attr)
    let l:s .= ' ' . join(l:common_attr, ',')
  endif
  if !empty(l:gui_attr)
    let l:s .= ' gui=' . join(l:gui_attr, ',')
  endif
  if !empty(l:term_attr)
    let l:s .= ' term=' . join(l:term_attr, ',')
  endif
  return l:s
endf

fun! s:generate_template()
  let l:name = (exists('g:colors_name') && !empty(g:colors_name) ? g:colors_name : 'My Theme')
  call setline(1, 'Full name: Template ' . l:name)
  call s:put('Short name: template_' . l:name)
  call s:put('Author: Me <me@somewhere.org>')
  call s:put('')
  " Linked groups
  call s:put('; Common linked groups {{{')
  for l:g in sort(keys(s:linked_groups))
    call s:put(l:g . repeat(' ', s:name_maxlen - len(l:g)) .' -> ' . s:linked_groups[l:g])
  endfor
  call s:put('; }}}')
  call s:put('')
  call s:put('Background: ' . &background)
  " Color definitions
  call s:put('')
  call s:put('; Color palette {{{')
  for l:name in sort(keys(s:colmap))
    call s:put('Color: ' . l:name . ' ' . s:colmap[l:name] . ' ~')
  endfor
  call s:put('')
  if exists('g:terminal_ansi_colors')
    call s:put('Term colors: ' . join(map(g:terminal_ansi_colors, 's:invmap[v:val]'), ' '))
  endif
  call s:put('; }}}')
  call s:put('')
  " Highlight group definitions
  call s:put('')
  call s:put('Variant: gui 256')
  call s:put('')
  call s:put('; Highlight groups {{{')
  for l:g in sort(keys(s:higroups))
    let l:fg = s:higroups[l:g]['fgname']
    let l:bg = s:higroups[l:g]['bgname']
    call s:put(l:g . ' ' . repeat(' ', s:name_maxlen - len(l:g))
          \ . l:fg . ' ' . repeat(' ', 10 - len(l:fg))
          \ . l:bg . ' ' . repeat(' ', 10 - len(l:bg))
          \ . s:attr_text(s:higroups[l:g]))
  endfor
  call s:put('; }}}')
endf

fun! colortemplate#import#run()
  call s:init()
  call s:collect()
  new
  setlocal ft=colortemplate
  call s:generate_template()
  call s:cleanup()
endf

