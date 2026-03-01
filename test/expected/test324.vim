vim9script

# Name:         Test 324
# Author:       y

set background=dark

hi clear
g:colors_name = 'test324'

const t_Co = rand() % 2 ? 16 : 16777216
const tgc = rand() % 2 ? true : false

hi Normal guifg=#d74f7f guibg=#fcfcfc guisp=NONE gui=NONE ctermfg=61 ctermbg=251 cterm=NONE

if tgc || t_Co >= 256
  if tgc
    hi Normal guifg=#d74f7f guibg=NONE ctermfg=61 ctermbg=NONE cterm=NONE
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
