vim9script

# Name:         Test 303
# Author:       me

set background=dark

hi clear
g:colors_name = 'test303'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

const transp_bg = get(g:, 'test303_transp_bg', 0)

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=231 ctermbg=16 cterm=NONE

if tgc || t_Co >= 256
  if transp_bg == 1
    hi Normal ctermfg=248 ctermbg=NONE cterm=NONE
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
