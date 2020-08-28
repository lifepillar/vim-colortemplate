" Returns 1 if synID corresponds to a linked highlight groups;
" returns 0 otherwise.
fun! s:is_linked(synID)
  return a:synID != synIDtrans(a:synID)
endf

" Returns the list of names of the currently defined highlight groups.
fun! colortemplate#templatize#names()
  let l:names = split(execute('hi'), '\n')
  return map(l:names, 'matchstr(v:val, "^\\S\\+")')
endf

" Returns the list of names of the currently defined highlight groups.
fun! colortemplate#templatize#ids()
  let l:names = split(execute('hi'), '\n')
  return map(l:names, 'hlID(matchstr(v:val, "^\\S\\+"))')
endf

fun! s:init()
  let s:colmap        = {} " Color name => values
  let s:invmap        = {} " Color hexvalue => name pairs
  let s:higroups      = {} " Highlight group definitions
  let s:linked_groups = {} " Linked groups (source => target)
endf

fun! s:cleanup()
  unlet s:colmap
  unlet s:invmap
  unlet s:higroups
endf

fun! s:higroup_name(synid)
  return synIDattr(a:synid, 'name')
endf

fun! s:synIDattrs(synid, mode)
  return {
        \ 'name':       synIDattr(a:synid, 'name',      a:mode),
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
        \ #{ gui   : s:synIDattrs(a:synid, 'gui'),
        \    cterm : s:synIDattrs(a:synid, 'cterm'),
        \    term  : s:synIDattrs(a:synid, 'term') }
        \ }
endf

fun! s:hash(guicol, termcol)
  return a:guicol .. string(a:termcol)
endf

fun! s:collect()
  let l:allids = colortemplate#templatize#ids()
  let l:ids = []
  for l:id in l:allids
    let l:trid = synIDtrans(l:id)
    if l:id == l:trid
      let l:info = s:higroup_info(l:id)
      call extend(s:higroups, l:info)
    else
      let s:linked_groups[s:higroup_name(l:id)] = s:higroup_name(l:trid)
    endif
  endfor
endf

fun! colortemplate#templatize#import()
  call s:init()
  call s:collect()
  " Create new buffer
  " Format template
  call s:cleanup()
endf

