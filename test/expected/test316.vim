vim9script

# Name:         Test 316
# Author:       y

set background=dark

hi clear
g:colors_name = 'test316'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

hi Visual guifg=NONE guibg=#003f5f guisp=NONE gui=NONE ctermfg=81 ctermbg=16 cterm=reverse

if tgc || t_Co >= 256
  if tgc
    hi Visual cterm=NONE
  endif
  finish
endif

if t_Co >= 8
  hi Visual ctermfg=blue ctermbg=black cterm=reverse
  finish
endif

# vim: et ts=8 sw=2 sts=2
