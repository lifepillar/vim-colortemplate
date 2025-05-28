vim9script

# Name:         Test 311
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test311'


hi! link StatusLineTerm StatusLine
hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 ctermul=NONE cterm=NONE term=NONE

if str2nr(&t_Co) >= 8
  finish
endif

if str2nr(&t_Co) >= 0
  hi StatusLineTerm term=bold,reverse
  finish
endif

# vim: et ts=8 sw=2 sts=2
