vim9script

# Name:         Test 307
# Author:       tester

set background=dark

hi clear
g:colors_name = 'test307'


hi Normal guifg=#df0000 guibg=#df0000 guisp=NONE gui=NONE ctermfg=160 ctermbg=160 ctermul=NONE cterm=NONE term=NONE
hi SpellBad guifg=#df0000 guibg=NONE guisp=#df0000 gui=undercurl ctermfg=160 ctermbg=NONE ctermul=160 cterm=underline term=underline

if empty(&t_Co)
  finish
endif

if str2nr(&t_Co) >= 256
  finish
endif

if str2nr(&t_Co) >= 16
  hi SpellBad cterm=underline
  finish
endif

if str2nr(&t_Co) >= 8
  hi SpellBad cterm=underline
  finish
endif

# vim: et ts=8 sw=2 sts=2
