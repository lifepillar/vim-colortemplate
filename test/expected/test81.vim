" Name:         Test 81
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=light

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'test81'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

if s:t_Co >= 256
  hi Normal ctermfg=16 ctermbg=16 cterm=NONE
  let x = 3
  unlet x
  unlet! w
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
