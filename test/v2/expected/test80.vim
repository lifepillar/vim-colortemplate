" Name:         Test 80
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test80'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

silent! call foo()

if s:t_Co >= 256
  silent! call bar()
  hi Normal ctermfg=16 ctermbg=16 cterm=NONE
  silent! call foobar()
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
