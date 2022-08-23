" Name:         Test 7
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test7'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

hi Normal guifg=#ffffff guibg=#000000 gui=reverse cterm=reverse

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=reverse
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
