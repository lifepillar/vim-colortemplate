" Name:         Test 67
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'test67'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if (has('termguicolors') && &termguicolors) || has('gui_running')
  let x = 1
  hi! link CursorLineNr LineNr
  call foobar()
  if &background ==# 'dark'
    hi Normal guifg=#ffffff guibg=#000000 guisp=NONE gui=NONE cterm=NONE
    unlet x
    unlet s:t_Co
    finish
  endif
  " Light background
  hi Normal guifg=#000000 guibg=#ffffff guisp=NONE gui=NONE cterm=NONE
  unlet x
  unlet s:t_Co
  finish
endif

if s:t_Co >= 256
  let x = 1
  hi! link CursorLineNr LineNr
  call foobar()
  if &background ==# 'dark'
    hi Normal ctermfg=255 ctermbg=16 cterm=NONE
    if !has('patch-8.0.0616') " Fix for Vim bug
      set background=dark
    endif
    unlet x
    unlet s:t_Co
    finish
  endif
  " Light background
  hi Normal ctermfg=16 ctermbg=255 cterm=NONE
  unlet x
  unlet s:t_Co
  finish
endif

