vim9script

# Name:         Test 319
# Author:       y

set background=dark

hi clear
g:colors_name = 'test319'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

const bold = get(g:, 'bold', false)

hi Normal guifg=#5fd7ff guibg=#000000 guisp=NONE gui=NONE ctermfg=81 ctermbg=16 cterm=NONE term=NONE

if tgc || t_Co >= 256
  finish
endif

if t_Co >= 0
  if bold
    hi Normal term=bold
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
