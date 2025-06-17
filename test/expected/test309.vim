vim9script

# Name:         Test 309
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test309'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE

if tgc || t_Co >= 256
  finish
endif

if t_Co >= 8
  hi Normal ctermfg=White ctermbg=Brown cterm=NONE
  finish
endif

# vim: et ts=8 sw=2 sts=2
