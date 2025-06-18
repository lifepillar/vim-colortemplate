vim9script

# Name:         Test 322
# Author:       y

set background=dark

hi clear
g:colors_name = 'test322'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

const extra = get(g:, 'test322_extra', true)


if has('gui_running') || tgc
  if extra
    hi vimCommentString guifg=#6c71c4 guibg=NONE guisp=NONE gui=NONE cterm=NONE
  endif
endif

if tgc || t_Co >= 256
  if extra
    hi vimCommentString ctermfg=61 ctermbg=NONE cterm=NONE
  endif
  finish
endif

if t_Co >= 16
  if extra
    hi vimCommentString ctermfg=13 ctermbg=NONE cterm=NONE
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
