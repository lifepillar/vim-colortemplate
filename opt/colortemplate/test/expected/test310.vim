vim9script

# Name:         Test 310
# Author:       y
# Maintainer:   w

set background=dark

hi clear
g:colors_name = 'test310'

const visibility = get(g:, 'visibility', 'normal')

hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE ctermfg=255 ctermbg=16 ctermul=NONE cterm=NONE term=NONE
hi SpellCap guifg=#6c71c4 guibg=NONE guisp=#6c71c4 gui=undercurl ctermfg=61 ctermbg=NONE ctermul=NONE cterm=underline term=bold,underline

if has('gui_running') || (has('termguicolors') && &termguicolors)
  if visibility == "high"
    hi SpellCap guifg=#6c71c4 guibg=#eee8d5 guisp=#dc322f gui=reverse,undercurl cterm=reverse,undercurl
  endif

  if empty(&t_Co)
    finish
  endif
endif

if str2nr(&t_Co) >= 256
  if visibility == "high"
    hi SpellCap ctermfg=61 ctermbg=254 ctermul=NONE cterm=reverse,underline
  elseif visibility == "low"
    hi SpellCap ctermfg=242 ctermbg=NONE ctermul=NONE cterm=bold
  endif
  finish
endif

if str2nr(&t_Co) >= 16
  hi Normal ctermfg=White ctermbg=Black ctermul=NONE cterm=NONE
  hi SpellCap ctermfg=13 ctermbg=NONE ctermul=NONE cterm=underline
  if visibility == "high"
    hi SpellCap ctermfg=13 ctermbg=7 ctermul=NONE cterm=reverse,underline
  elseif visibility == "low"
    hi SpellCap ctermfg=10 ctermbg=NONE ctermul=NONE cterm=bold
  endif
  finish
endif

if str2nr(&t_Co) >= 8
  hi Normal ctermfg=White ctermbg=Black ctermul=NONE cterm=NONE
  hi SpellCap ctermfg=13 ctermbg=NONE ctermul=13 cterm=undercurl
  finish
endif

# vim: et ts=8 sw=2 sts=2
