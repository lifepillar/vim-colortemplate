" Name:         Test 85
" Author:       y

hi clear
let g:colors_name = 'test85'

if &background == 'dark'
  hi Normal guifg=#000000 guibg=#ffffff guisp=NONE gui=NONE ctermfg=16 ctermbg=255 cterm=NONE

  finish
endif

if &background == 'light'
  hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE

endif

" vim: et ts=8 sw=2 sts=2
