" Name:         Test 27
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test27'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

hi Normal guifg=#000000 guibg=#000000 gui=NONE cterm=NONE

if s:t_Co >= 256
  hi Normal ctermfg=16 ctermbg=16 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
