" Name:         Test 89
" Author:       y
" Maintainer:   w

set background=dark

hi clear
let g:colors_name = 'test89'

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE

if !has('patch-8.0.0616') && !has('gui_running') " Fix for Vim bug
  set background=dark
endif

" vim: et ts=8 sw=2 sts=2
