vim9script

# Name:         Test 311
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test311'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)

hi! link StatusLineTerm StatusLine

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE term=NONE

if t_Co >= 256
  finish
endif

if t_Co >= 16
  hi Normal ctermfg=White ctermbg=Black cterm=NONE
  finish
endif

if t_Co >= 0
  hi StatusLineTerm term=bold,reverse
  finish
endif

# vim: et ts=8 sw=2 sts=2
