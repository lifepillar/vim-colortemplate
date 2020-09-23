" Name:         Test 60
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test60'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if s:t_Co >= 256
  let black = '#000000'
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
