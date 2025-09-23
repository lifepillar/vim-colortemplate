vim9script

# Name:         Test 323
# Author:       y

set background=dark

hi clear
g:colors_name = 'test323'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

hi SpellBad guifg=NONE guibg=NONE guisp=#d74f7f gui=undercurl ctermfg=61 ctermbg=NONE cterm=underline term=underline

if tgc || t_Co >= 256
  if tgc
    hi SpellBad guifg=#d74f7f guibg=NONE ctermfg=61 ctermbg=NONE cterm=underline
  endif
  finish
endif

if t_Co >= 8
  hi SpellBad ctermfg=darkred ctermbg=NONE cterm=underline
  finish
endif

# vim: et ts=8 sw=2 sts=2
