vim9script

# Name:         Test 317
# Author:       y

set background=dark

hi clear
g:colors_name = 'test317'

const tgc = has('termguicolors') && &termguicolors

hi Visual guifg=NONE guibg=#003f5f guisp=NONE gui=NONE ctermfg=81 ctermbg=16 cterm=reverse

if has('gui_running') || tgc
  if tgc
    hi Visual gui=NONE cterm=NONE
  endif
endif

# vim: et ts=8 sw=2 sts=2
