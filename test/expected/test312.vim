vim9script

# Name:         Test 312
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test312'


hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 ctermul=NONE cterm=NONE term=NONE
hi StatusLineTermNC guifg=#ffffff guibg=#000000 guisp=NONE gui=reverse ctermfg=255 ctermbg=16 ctermul=NONE cterm=reverse term=reverse

if empty(&t_Co)
  finish
endif

if str2nr(&t_Co) >= 256
  finish
endif

if str2nr(&t_Co) >= 16
  hi Normal ctermfg=White ctermbg=Black ctermul=NONE cterm=NONE
  hi StatusLineTermNC ctermfg=White ctermbg=Black ctermul=NONE cterm=reverse
  finish
endif

if str2nr(&t_Co) >= 8
  hi Normal ctermfg=White ctermbg=Black ctermul=NONE cterm=NONE
  hi StatusLineTermNC ctermfg=White ctermbg=Black ctermul=NONE cterm=reverse
  finish
endif

if str2nr(&t_Co) >= 0
  hi! link StatusLineTermNC StatusLineNC
  finish
endif

# vim: et ts=8 sw=2 sts=2
