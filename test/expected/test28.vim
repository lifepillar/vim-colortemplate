" Name:         Test 28
" Author:       aa
" Maintainer:   mm
" License:      Vim License (see `:help license`)

hi clear
let g:colors_name = 'test28'

let s:t_Co = exists('&t_Co') && !empty(&t_Co) && &t_Co > 1 ? &t_Co : 2

if (has('termguicolors') && &termguicolors) || has('gui_running')
  if &background ==# 'dark'
    hi Normal guifg=#ffffff guibg=#000000 gui=NONE cterm=NONE
    let fullname = 'Test 28'
    let shortname = 'test28'
    let author = 'aa'
    let maintainer = 'mm'
    let background = 'dark'
    let g:foo = [
          \ White
          \ 231
          \ #ffffff]
    " xxxx yyyy
    hi Foobar ctermfg=255 ctermbg=231 guibg=#000000 guifg=#ffffff guisp=#ffffff
    unlet s:t_Co
    finish
  endif
  " Light background
  hi Normal guifg=#fafafa guibg=#333333 gui=NONE cterm=NONE
  let fullname = 'Test 28'
  let shortname = 'test28'
  let author = 'aa'
  let maintainer = 'mm'
  let background = 'light'
  let g:foo = [
        \ Gray
        \ 236
        \ #fafafa]
  " xxxx yyyy
  hi Foobar ctermfg=231 ctermbg=236 guibg=#333333 guifg=#fafafa guisp=#fafafa
  unlet s:t_Co
  finish
endif

if s:t_Co >= 256
  if &background ==# 'dark'
    hi Normal ctermfg=255 ctermbg=231 cterm=NONE
    if !has('patch-8.0.0616') " Fix for Vim bug
      set background=dark
    endif
    let fullname = 'Test 28'
    let shortname = 'test28'
    let author = 'aa'
    let maintainer = 'mm'
    let background = 'dark'
    let g:foo = [
          \ White
          \ 231
          \ #ffffff]
    " xxxx yyyy
    hi Foobar ctermfg=255 ctermbg=231 guibg=#000000 guifg=#ffffff guisp=#ffffff
    unlet s:t_Co
    finish
  endif
  " Light background
  hi Normal ctermfg=231 ctermbg=236 cterm=NONE
  let fullname = 'Test 28'
  let shortname = 'test28'
  let author = 'aa'
  let maintainer = 'mm'
  let background = 'light'
  let g:foo = [
        \ Gray
        \ 236
        \ #fafafa]
  " xxxx yyyy
  hi Foobar ctermfg=231 ctermbg=236 guibg=#333333 guifg=#fafafa guisp=#fafafa
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
