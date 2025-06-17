vim9script

# Name:         Test 318
# Author:       y

set background=dark

hi clear
g:colors_name = 'test318'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)

hi Normal guifg=#5fd7ff guibg=#000000 guisp=NONE gui=NONE ctermfg=81 ctermbg=16 cterm=NONE

if t_Co >= 256
  finish
endif

if t_Co >= 8
  hi Normal ctermfg=blue ctermbg=black cterm=NONE
  finish
endif

# vim: et ts=8 sw=2 sts=2
