vim9script

# Name:         Test 313
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test313'


hi! link StatusLineTerm StatusLine
hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 ctermul=NONE cterm=NONE term=NONE

if empty(&t_Co)
  finish
endif

if str2nr(&t_Co) >= 256
  hi StatusLineTerm ctermfg=255 ctermbg=16 ctermul=NONE cterm=bold,reverse
  finish
endif

if str2nr(&t_Co) >= 16
  hi Normal ctermfg=White ctermbg=Black ctermul=NONE cterm=NONE
  hi StatusLineTerm ctermfg=White ctermbg=Black ctermul=NONE cterm=bold,reverse
  finish
endif

if str2nr(&t_Co) >= 8
  hi! link StatusLineTerm Foobar
  hi Normal ctermfg=White ctermbg=Black ctermul=NONE cterm=NONE
  finish
endif

if str2nr(&t_Co) >= 0
  hi StatusLineTerm term=bold,reverse
  finish
endif

# vim: et ts=8 sw=2 sts=2
