let g:colortemplate#import#adjectives = [
      \ 'bald',
      \ 'bold',
      \ 'busy',
      \ 'calm',
      \ 'cool',
      \ 'cute',
      \ 'dead',
      \ 'drab',
      \ 'dull',
      \ 'dumb',
      \ 'easy',
      \ 'evil',
      \ 'fair',
      \ 'fine',
      \ 'free',
      \ 'glad',
      \ 'glum',
      \ 'good',
      \ 'hurt',
      \ 'kind',
      \ 'lazy',
      \ 'long',
      \ 'nice',
      \ 'open',
      \ 'pale',
      \ 'poor',
      \ 'real',
      \ 'rich',
      \ 'sore',
      \ 'sour',
      \ 'tame',
      \ 'ugly',
      \ 'vast',
      \ 'warm',
      \ 'weak',
      \ 'wild',
      \ 'zany',
      \ ]

let g:colortemplate#import#names = [
      \ 'Akita',
      \ 'Bison',
      \ 'Bongo',
      \ 'Booby',
      \ 'Camel',
      \ 'Coati',
      \ 'Coral',
      \ 'Crane',
      \ 'Dhole',
      \ 'Dingo',
      \ 'Eagle',
      \ 'Fossa',
      \ 'Gecko',
      \ 'Goose',
      \ 'Guppy',
      \ 'Heron',
      \ 'Horse',
      \ 'Human',
      \ 'Hyena',
      \ 'Indri',
      \ 'Koala',
      \ 'Lemur',
      \ 'Liger',
      \ 'Llama',
      \ 'Macaw',
      \ 'Molly',
      \ 'Moose',
      \ 'Mouse',
      \ 'Okapi',
      \ 'Otter',
      \ 'Prawn',
      \ 'Quail',
      \ 'Quoll',
      \ 'Robin',
      \ 'Saola',
      \ 'Sheep',
      \ 'Skunk',
      \ 'Sloth',
      \ 'Snail',
      \ 'Snake',
      \ 'Squid',
      \ 'Stoat',
      \ 'Tapir',
      \ 'Tetra',
      \ 'Tiger',
      \ 'Xerus',
      \ 'Zebra',
      \ 'Zorse',
      \ ]

fun! s:shuffle(x)
  for l:i in reverse(range(0, len(a:x) - 1))
    let l:j = rand() % (l:i + 1)
    let l:tmp = a:x[l:i]
    let a:x[l:i] = a:x[l:j]
    let a:x[l:j] = l:tmp
  endfor
  return a:x
endf

fun! s:init()
  let s:colmap        = {} " Color name => GUI value
  let s:invmap        = {} " GUI value => Color name
  let s:higroups      = {} " Highlight group definitions
  let s:linked_groups = {} " Linked groups (source => target)
  let s:name_maxlen   = 6  " Maximum length of a highlight group name
  if get(g:, 'colortemplate_fancy_import', 1)
    let s:pairs = []
    for l:i in range(0, len(g:colortemplate#import#adjectives) - 1)
      for l:j in range(0, len(g:colortemplate#import#names) - 1)
        call add(s:pairs, [l:i, l:j])
      endfor
    endfor
    let s:pairs = s:shuffle(s:pairs)
  else
  endif
  let s:n = 0
endf

fun! s:cleanup()
  unlet s:colmap
  unlet s:invmap
  unlet s:higroups
  unlet s:linked_groups
  unlet s:name_maxlen
  unlet s:n
  unlet! s:pairs
endf

fun! s:warn(t)
  echohl WarningMsg
  echomsg '[Colortemplate]' t . '.'
  echohl None
endf

fun! s:fatal(t)
  echohl Error
  echomsg '[Colortemplate]' t . '.'
  echohl None
  call interrupt()
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

fun! s:next_color_name()
  let s:n += 1
  if get(g:, 'colortemplate_fancy_import', 1)
    if s:n > len(s:pairs)
      call fatal('Too many colors. Try setting g:colortemplate_fancy_import = 0')
    endif
    return g:colortemplate#import#adjectives[s:pairs[s:n][0]] . g:colortemplate#import#names[s:pairs[s:n][1]]
  else
    return 'Color' .. repeat('0', float2nr(4 - log10(s:n + 1))) . s:n
  endif
endf

" Returns a generated color name for the color of the specified type
" (fg, bg, sp) in the given highlight group. Different colors are assigned
" different names.
fun! s:assignColor(synid, type)
  let l:col = colortemplate#syn#higroup2hex(synIDattr(a:synid, 'name'), a:type)
  if has_key(s:invmap, l:col.hex) " Color already defined: return its name
    return s:invmap[l:col.hex]
  endif
  " New color: generate new name
  let l:name = s:next_color_name()
  let s:colmap[l:name] = l:col.hex
  let s:invmap[l:col.hex] = l:name
  return l:name
endf

fun! s:synIDattrs(synid, mode)
  return {
        \ 'fg':           synIDattr(a:synid, 'fg',          a:mode),
        \ 'bg':           synIDattr(a:synid, 'bg',          a:mode),
        \ 'sp':           synIDattr(a:synid, 'sp',          a:mode),
        \ 'bold':        (synIDattr(a:synid, 'bold',        a:mode) ==# '1' ? 1 : 0),
        \ 'italic':      (synIDattr(a:synid, 'italic',      a:mode) ==# '1' ? 1 : 0),
        \ 'reverse':     (synIDattr(a:synid, 'reverse',     a:mode) ==# '1' ? 1 : 0),
        \ 'standout':    (synIDattr(a:synid, 'standout',    a:mode) ==# '1' ? 1 : 0),
        \ 'underline':   (synIDattr(a:synid, 'underline',   a:mode) ==# '1' ? 1 : 0),
        \ 'undercurl':   (synIDattr(a:synid, 'undercurl',   a:mode) ==# '1' ? 1 : 0),
        \ 'underdouble': (synIDattr(a:synid, 'underdouble', a:mode) ==# '1' ? 1 : 0),
        \ 'underdotted': (synIDattr(a:synid, 'underdotted', a:mode) ==# '1' ? 1 : 0),
        \ 'underdashed': (synIDattr(a:synid, 'underdashed', a:mode) ==# '1' ? 1 : 0),
        \ 'strike':      (synIDattr(a:synid, 'strike',      a:mode) ==# '1' ? 1 : 0),
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
  " Get Normal colors first
  call extend(s:higroups, s:higroup_info(hlID('Normal')))
  " Get info about the remaining highlight groups
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

fun! s:attr_text(higroup, term)
  let l:common_attr = []
  let l:term_attr = []
  let l:gui_attr = []
  for l:attr in ['bold', 'italic', 'reverse', 'standout', 'underline', 'undercurl', 'underdouble', 'underdotted', 'underdashed', 'strike']
    if a:term ==# 'cterm'
      if a:higroup['gui'][l:attr] == 1 && a:higroup['cterm'][l:attr] == 1
        call add(l:common_attr, l:attr)
      elseif a:higroup['gui'][l:attr] == 1 && a:higroup['cterm'][l:attr] == 0
        call add(l:gui_attr, l:attr)
      elseif a:higroup['gui'][l:attr] == 0 && a:higroup['cterm'][l:attr] == 1
        call add(l:term_attr, l:attr)
      endif
    else
      if a:higroup['term'][l:attr] == 1
        call add(l:common_attr, l:attr)
      endif
    endif
  endfor
  let l:s = ''
  if !empty(l:common_attr)
    let l:s .= ' ' . join(l:common_attr, ',')
  endif
  if a:term ==# 'cterm'
    if a:higroup['spname'] != 'none' && a:higroup['synid'] != hlID('Normal') && a:higroup['spname'] != a:higroup['fgname']
      let l:s .= ' guisp=' . a:higroup['spname']
    endif
    if !empty(l:gui_attr)
      let l:s .= ' gui=' . join(l:gui_attr, ',')
    endif
    if !empty(l:term_attr)
      let l:s .= ' term=' . join(l:term_attr, ',')
    endif
  endif
  return l:s
endf

fun! s:print_higroup(g, term)
  if a:term ==# 'cterm'
    let l:fg = s:higroups[a:g]['fgname']
    let l:bg = s:higroups[a:g]['bgname']
  else
    let l:fg = 'omit'
    let l:bg = 'omit'
  endif
  let l:at = s:attr_text(s:higroups[a:g], a:term)
  call s:put(a:g . ' ' . repeat(' ', s:name_maxlen - len(a:g))
        \ . l:fg . ' ' . repeat(' ', 10 - len(l:fg))
        \ . l:bg . (empty(l:at) ? '' : ' ' . repeat(' ', 10 - len(l:bg)))
        \ . l:at)
endf

fun! s:generate_template()
  let l:name = (exists('g:colors_name') && !empty(g:colors_name) ? g:colors_name : 'My Theme')
  call setline(1, 'Full name: ' . l:name)
  call s:put('Short name: template_' . substitute(tolower(l:name), '\%(\s\|-\)', '_', 'g'))
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
    call s:put('Term colors: ' . join(map(copy(g:terminal_ansi_colors), 's:invmap[v:val]'), ' '))
  endif
  call s:put('; }}}')
  call s:put('')
  " Highlight group definitions
  call s:put('')
  call s:put('Variant: gui 256')
  call s:put('')
  call s:put('; Highlight groups {{{')
  " Print Normal group first
  if has_key(s:higroups, 'Normal')
    call s:print_higroup('Normal', 'cterm')
  else " This should never happen
    call s:warn('Normal group is not defined')
  endif
  for l:g in filter(sort(keys(s:higroups)), { i,v -> v != 'Normal' })
    call s:print_higroup(l:g, 'cterm')
  endfor
  call s:put('; }}}')
  call s:put('')
  call s:put('Variant: 0')
  call s:put('')
  call s:put('; Highlight groups {{{')
  " Print Normal group first
  if has_key(s:higroups, 'Normal')
    call s:print_higroup('Normal', 'term')
  else " This should never happen
    call s:warn('Normal group is not defined')
  endif
  for l:g in filter(sort(keys(s:higroups)), { i,v -> v != 'Normal' })
    call s:print_higroup(l:g, 'term')
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

