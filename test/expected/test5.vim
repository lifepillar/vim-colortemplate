" Name:         Test 5
" Author:       y
" Maintainer:   w
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test5'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co >= 0 ? &t_Co : -1

hi ColorColumn guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE

if s:t_Co >= 256
  hi ColorColumn ctermfg=255 ctermbg=16 cterm=NONE
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
