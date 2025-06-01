" Name:         Test 94
" Author:       y

hi clear
let g:colors_name = 'test94'

if &background == 'dark'
  hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE
  hi Bold guifg=#ffffff guibg=#000000 guisp=NONE gui=bold ctermfg=255 ctermbg=16 cterm=bold
  hi Comment guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE
  hi Italic guifg=#ffffff guibg=#000000 guisp=NONE gui=italic ctermfg=255 ctermbg=16 cterm=italic

  finish
endif

if &background == 'light'
  hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE
  hi Bold guifg=#ffffff guibg=#000000 guisp=NONE gui=bold ctermfg=255 ctermbg=16 cterm=bold
  hi Comment guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE

endif

" vim: et ts=8 sw=2 sts=2
