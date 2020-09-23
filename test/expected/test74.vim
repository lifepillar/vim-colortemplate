" Name:         Test 74
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test74'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if s:t_Co >= 16
  hi Normal ctermfg=15 ctermbg=NONE cterm=NONE
  hi NonText ctermfg=NONE ctermbg=15 cterm=NONE
  hi Conceal ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Cursor ctermfg=15 ctermbg=15 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
