" Name:         Test 325
" Author:       y

set background=dark

hi clear
let g:colors_name = 'test325'

let s:t_Co = rand() % 2 ? 16 : 16777216
let s:tgc = rand() % 2 ? true : false

hi Normal guifg=#d74f7f guibg=#fcfcfc guisp=NONE gui=NONE ctermfg=61 ctermbg=251 cterm=NONE

if s:tgc || s:t_Co >= 256
  if s:tgc
    hi Normal guifg=#d74f7f guibg=NONE ctermfg=61 ctermbg=NONE cterm=NONE
  endif
  finish
endif

" vim: et ts=8 sw=2 sts=2
