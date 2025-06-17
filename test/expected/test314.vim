vim9script

# Name:         Test 314
# Author:       me

set background=dark

hi clear
g:colors_name = 'test314'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

hi CursorLineNr guifg=#ffd700 guibg=#005faf guisp=NONE gui=bold ctermfg=220 ctermbg=25 cterm=NONE term=bold

if tgc || t_Co >= 256
  hi! link CursorLineNr CursorLine
  finish
endif

if t_Co >= 16
  hi! link CursorLineNr CursorLine
  finish
endif

if t_Co >= 8
  hi! link CursorLineNr CursorLine
  finish
endif

# vim: et ts=8 sw=2 sts=2
