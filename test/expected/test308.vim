vim9script

# Name:         Test 308
# Author:       tester

set background=dark

hi clear
g:colors_name = 'test308'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)

const foo = get(g:, 'foo', 0)

hi Normal guifg=#888888 guibg=#f0f0f0 guisp=NONE gui=NONE ctermfg=102 ctermbg=255 cterm=NONE term=NONE
hi Folded guifg=#888888 guibg=#f0f0f0 guisp=NONE gui=italic ctermfg=102 ctermbg=255 cterm=italic term=italic

if t_Co >= 256
  if foo == 0
    hi Folded ctermfg=102 ctermbg=255 cterm=NONE
  elseif foo == 1
    hi Folded ctermfg=102 ctermbg=NONE cterm=NONE
  elseif foo == 2
    hi Folded ctermfg=102 ctermbg=NONE cterm=italic
  elseif foo == 3
    hi Folded ctermfg=NONE ctermbg=102 cterm=reverse
  endif
  finish
endif

if t_Co >= 16
  hi Normal ctermfg=DarkGray ctermbg=Gray cterm=NONE
  hi Folded ctermfg=DarkGray ctermbg=Gray cterm=italic
  finish
endif

if t_Co >= 8
  hi Normal ctermfg=DarkGray ctermbg=Gray cterm=NONE
  hi Folded ctermfg=DarkGray ctermbg=Gray cterm=italic
  if foo == 0
    hi Folded ctermfg=DarkGray ctermbg=Gray cterm=NONE
  elseif foo == 1
    hi Folded ctermfg=DarkGray ctermbg=NONE cterm=NONE
  elseif foo == 2
    hi Folded ctermfg=DarkGray ctermbg=NONE cterm=italic
  elseif foo == 3
    hi Folded ctermfg=NONE ctermbg=DarkGray cterm=reverse
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
