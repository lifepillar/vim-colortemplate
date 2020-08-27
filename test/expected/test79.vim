" Name:         Test 79
" Author:       z
" Maintainer:   z
" License:      Vim License (see `:help license`)

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'test79'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if s:t_Co >= 256
  hi Normal ctermfg=0 ctermbg=0 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
