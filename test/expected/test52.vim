" Name:         Test 52
" Author:       y
" Maintainer:   w

set background=dark

hi clear
let g:colors_name = 'test52'

let s:t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=15 ctermbg=0 cterm=NONE

if s:t_Co >= 256
  finish
endif

if s:t_Co >= 8
  hi Normal ctermfg=White ctermbg=Black cterm=NONE
  finish
endif

" vim: et ts=8 sw=2 sts=2
