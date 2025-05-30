vim9script

# Name:         Test 309
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test309'


hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 ctermul=NONE cterm=NONE

if empty(&t_Co)
  finish
endif

if str2nr(&t_Co) >= 256
  finish
endif

if str2nr(&t_Co) >= 8
  hi Normal ctermfg=White ctermbg=Brown ctermul=NONE cterm=NONE
  finish
endif

# vim: et ts=8 sw=2 sts=2
