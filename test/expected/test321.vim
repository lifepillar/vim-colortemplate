vim9script

# Name:         Test 321
# Author:       y

hi clear
g:colors_name = 'test321'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

if &background == 'dark'
  const flag = get(g:, 'flag', true)

  hi Normal guifg=#000000 guibg=#ffffff guisp=NONE gui=NONE ctermfg=16 ctermbg=231 cterm=NONE
  hi Comment guifg=#000000 guibg=#ffffff guisp=NONE gui=NONE ctermfg=16 ctermbg=231 cterm=NONE

  if tgc || t_Co >= 256
    if !flag
      hi Comment cterm=bold
    endif
    finish
  endif

  finish
endif

if &background == 'light'
  hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=231 ctermbg=16 cterm=NONE
  hi Comment guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=231 ctermbg=16 cterm=NONE

endif

# vim: et ts=8 sw=2 sts=2
