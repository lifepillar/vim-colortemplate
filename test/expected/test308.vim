vim9script

# Name:         Test 308
# Author:       tester

set background=dark

hi clear
g:colors_name = 'test308'

const foo = get(g:, 'foo', 0)

hi Normal guifg=#888888 guibg=#f0f0f0 guisp=NONE gui=NONE ctermfg=102 ctermbg=255 ctermul=NONE cterm=NONE term=NONE
hi Folded guifg=#888888 guibg=#f0f0f0 guisp=NONE gui=italic ctermfg=102 ctermbg=255 ctermul=NONE cterm=italic term=italic

if empty(&t_Co)
  finish
endif

if str2nr(&t_Co) >= 256
  if foo == 0
    hi Folded ctermfg=102 ctermbg=255 ctermul=NONE cterm=NONE
  elseif foo == 1
    hi Folded ctermfg=102 ctermbg=NONE ctermul=NONE cterm=NONE
  elseif foo == 2
    hi Folded ctermfg=102 ctermbg=NONE ctermul=NONE cterm=italic
  elseif foo == 3
    hi Folded ctermfg=NONE ctermbg=102 ctermul=NONE cterm=reverse
  endif
  finish
endif

if str2nr(&t_Co) >= 16
  hi Normal ctermfg=DarkGray ctermbg=Gray ctermul=NONE cterm=NONE
  hi Folded ctermfg=DarkGray ctermbg=Gray ctermul=NONE cterm=italic
  finish
endif

if str2nr(&t_Co) >= 8
  hi Normal ctermfg=DarkGray ctermbg=Gray ctermul=NONE cterm=NONE
  hi Folded ctermfg=DarkGray ctermbg=Gray ctermul=NONE cterm=italic
  if foo == 0
    hi Folded ctermfg=DarkGray ctermbg=Gray ctermul=NONE cterm=NONE
  elseif foo == 1
    hi Folded ctermfg=DarkGray ctermbg=NONE ctermul=NONE cterm=NONE
  elseif foo == 2
    hi Folded ctermfg=DarkGray ctermbg=NONE ctermul=NONE cterm=italic
  elseif foo == 3
    hi Folded ctermfg=NONE ctermbg=DarkGray ctermul=NONE cterm=reverse
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
