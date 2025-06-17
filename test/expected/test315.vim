vim9script

# Name:         Test 315
# Author:       me

set background=dark

hi clear
g:colors_name = 'test315'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)

hi Comment guifg=#ff8ad8 guibg=#ffffff guisp=NONE gui=italic ctermfg=238 ctermbg=231 cterm=bold term=bold,italic

if t_Co >= 256
  finish
endif

if t_Co >= 8
  hi Comment ctermfg=Grey ctermbg=White cterm=bold,italic
  finish
endif

# vim: et ts=8 sw=2 sts=2
