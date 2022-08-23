" Name:         Test 60
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
let g:colors_name = 'test60'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

if s:t_Co >= 256
  let black = '#000000'
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
