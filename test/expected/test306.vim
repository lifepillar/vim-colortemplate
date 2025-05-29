vim9script

# Name:         Test 306
# Author:       tester

set background=dark

hi clear
g:colors_name = 'test306'


hi Normal guifg=#df0000 guibg=#df0000 guisp=NONE gui=NONE ctermfg=160 ctermbg=160 ctermul=NONE cterm=NONE term=NONE
hi SpellBad guifg=#df0000 guibg=NONE guisp=#df0000 gui=underline ctermfg=160 ctermbg=NONE ctermul=160 cterm=undercurl term=undercurl

if empty(&t_Co)
  finish
endif

if str2nr(&t_Co) >= 256
  finish
endif

if str2nr(&t_Co) >= 16
  hi Normal ctermfg=Red ctermbg=Red ctermul=NONE cterm=NONE
  hi SpellBad ctermfg=Red ctermbg=NONE ctermul=Red cterm=undercurl
  finish
endif

if str2nr(&t_Co) >= 8
  hi Normal ctermfg=Red ctermbg=Red ctermul=NONE cterm=NONE
  hi SpellBad ctermfg=Red ctermbg=NONE ctermul=Red cterm=undercurl
  finish
endif

# vim: et ts=8 sw=2 sts=2
