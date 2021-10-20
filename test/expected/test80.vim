" Name:         Test 80
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test80'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 1

silent! call foo()

if s:t_Co >= 256
  silent! call bar()
  hi Normal ctermfg=16 ctermbg=16 cterm=NONE
  silent! call foobar()
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
