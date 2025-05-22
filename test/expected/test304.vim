vim9script

# Name:         Test 304
# Author:       me

set background=dark

hi clear
g:colors_name = 'test304'

const transp_bg = get(g:, 'foo_transp_bg', 0)

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=248 ctermbg=21 ctermul=NONE cterm=NONE

if has('gui_running') || (has('termguicolors') && &termguicolors)
  if transp_bg == 1
    hi Normal guifg=#ffffff guibg=NONE guisp=NONE gui=NONE
  endif
endif

if str2nr(&t_Co) >= 256
  if transp_bg == 1
    hi Normal ctermfg=231 ctermbg=NONE ctermul=NONE cterm=NONE
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
