" Name:         Test 82
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'test84'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2
let s:italics = (&t_ZH != '' && &t_ZH != '[7m') || has('gui_running')

if (has('termguicolors') && &termguicolors) || has('gui_running')
  hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
  hi StatusLine guifg=#000000 guibg=#ffffff gui=bold,italic cterm=italic
  if !s:italics
    hi StatusLine gui=bold cterm=NONE
  endif
  unlet s:t_Co s:italics
  finish
endif

if s:t_Co >= 256
  hi Normal ctermfg=255 ctermbg=16 cterm=NONE
  if !has('patch-8.0.0616') " Fix for Vim bug
    set background=dark
  endif
  hi StatusLine ctermfg=16 ctermbg=255 cterm=italic
  if !s:italics
    hi StatusLine cterm=NONE
  endif
  unlet s:t_Co s:italics
  finish
endif

" vim: et ts=2 sw=2
