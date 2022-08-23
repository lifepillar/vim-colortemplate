" Name:         Test 28
" Author:       aa
" Maintainer:   mm
" License:      Vim License (see `:help license`)

hi clear
let g:colors_name = 'test28'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

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
else
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
endif

if s:t_Co >= 256
  if &background ==# 'dark'
    hi Normal ctermfg=255 ctermbg=231 cterm=NONE
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
  else
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
  endif
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
