" Name:         Test 63
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test63'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

call foo()

if s:t_Co >= 256
  call bar()
  hi Normal ctermfg=16 ctermbg=16 cterm=NONE
  call foobar()
  unlet s:t_Co
  finish
endif

" vim: et sw=2 sts=2
