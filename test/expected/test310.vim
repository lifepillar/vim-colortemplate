vim9script

# Name:         Test 310
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test310'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

const visibility = get(g:, 'visibility', 'normal')

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 cterm=NONE term=NONE
hi SpellCap guifg=#6c71c4 guibg=NONE guisp=#6c71c4 gui=undercurl ctermfg=61 ctermbg=NONE cterm=underline term=bold,underline

if has('gui_running') || tgc
  if visibility == "high"
    hi SpellCap guifg=#6c71c4 guibg=#eee8d5 guisp=#dc322f gui=reverse,undercurl cterm=reverse,undercurl
  endif
endif

if tgc || t_Co >= 256
  if visibility == "high"
    hi SpellCap ctermfg=61 ctermbg=254 cterm=reverse,underline
  elseif visibility == "low"
    hi SpellCap ctermfg=242 ctermbg=NONE cterm=bold
  endif
  finish
endif

if t_Co >= 16
  hi Normal ctermfg=White ctermbg=Black cterm=NONE
  hi SpellCap ctermfg=13 ctermbg=NONE cterm=underline
  if visibility == "high"
    hi SpellCap ctermfg=13 ctermbg=7 cterm=reverse,underline
  elseif visibility == "low"
    hi SpellCap ctermfg=10 ctermbg=NONE cterm=bold
  endif
  finish
endif

if t_Co >= 8
  hi Normal ctermfg=White ctermbg=Black cterm=NONE
  hi SpellCap ctermfg=13 ctermbg=NONE cterm=undercurl ctermul=13
  finish
endif

# vim: et ts=8 sw=2 sts=2
