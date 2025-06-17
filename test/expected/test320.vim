vim9script

# Name:         Test 320
# Author:       y

set background=dark

hi clear
g:colors_name = 'test320'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)

const bold = get(g:, 'bold', false)

hi Normal guifg=#5fd7ff guibg=#000000 guisp=NONE gui=NONE ctermfg=blue ctermbg=black cterm=NONE term=NONE

if t_Co >= 8
  finish
endif

if t_Co >= 0
  if bold == true
    hi Normal term=bold
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
