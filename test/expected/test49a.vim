" Name:         Test 49a
" Author:       y
" Maintainer:   w

set background=dark

hi clear
let g:colors_name = 'test49a'

let s:t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
let s:tgc = has('termguicolors') && &termguicolors

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=231 ctermbg=16 cterm=NONE

if s:tgc || s:t_Co >= 256
  finish
endif

if s:t_Co >= 8
  hi Normal ctermfg=White ctermbg=Black cterm=NONE
  finish
endif

" vim: et ts=8 sw=2 sts=2
