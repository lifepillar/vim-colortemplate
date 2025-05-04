" Name:         Test 79
" Author:       z
" Maintainer:   z
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test79'

let s:t_Co = has('gui_running') ? -1 : (&t_Co ?? 0)

if s:t_Co >= 256
  hi Normal ctermfg=0 ctermbg=0 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
