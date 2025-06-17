vim9script

# Name:         Test 306
# Author:       tester

set background=dark

hi clear
g:colors_name = 'test306'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

hi Normal guifg=#df0000 guibg=#df0000 guisp=NONE gui=NONE ctermfg=160 ctermbg=160 cterm=NONE term=NONE
hi SpellBad guifg=#df0000 guibg=NONE guisp=#df0000 gui=underline ctermfg=160 ctermbg=NONE cterm=undercurl term=undercurl ctermul=160

if tgc || t_Co >= 256
  finish
endif

if t_Co >= 16
  hi Normal ctermfg=Red ctermbg=Red cterm=NONE
  hi SpellBad ctermfg=Red ctermbg=NONE cterm=undercurl ctermul=Red
  finish
endif

if t_Co >= 8
  hi Normal ctermfg=Red ctermbg=Red cterm=NONE
  hi SpellBad ctermfg=Red ctermbg=NONE cterm=undercurl ctermul=Red
  finish
endif

# vim: et ts=8 sw=2 sts=2
