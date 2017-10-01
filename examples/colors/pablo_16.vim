" Name:         Pablo
" Author:       Ron Aaron <ron@ronware.org>
" Maintainer:   Ron Aaron <ron@ronware.org>
" License:      Vim License (see `:help license`)
" Last Updated: Sun Oct  1 12:12:24 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < 16)
  echohl Error
  echomsg 'Pablo: There are not enough colors.'
  echohl None
  finish
endif

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'pablo_16'

if !has('gui_running') && get(g:, 'pablo_transp_bg', 0)
hi Normal ctermfg=White ctermbg=NONE guifg=#ffffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
hi Normal ctermfg=White ctermbg=Black guifg=#ffffff guibg=#000000 guisp=NONE cterm=NONE gui=NONE
endif
hi Directory ctermfg=DarkGreen ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Search ctermfg=NONE ctermbg=DarkYellow guifg=NONE guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE
hi StatusLine ctermfg=LightYellow ctermbg=LightBlue guifg=#ffff00 guibg=#0000ff guisp=NONE cterm=NONE gui=NONE
hi Comment ctermfg=DarkGrey ctermbg=NONE guifg=#808080 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Constant ctermfg=LightCyan ctermbg=NONE guifg=#00ffff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=NONE ctermbg=LightRed guifg=NONE guibg=#ff0000 guisp=NONE cterm=NONE gui=NONE
hi Identifier ctermfg=DarkCyan ctermbg=NONE guifg=#00c0c0 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi PreProc ctermfg=LightGreen ctermbg=NONE guifg=#00ff00 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Special ctermfg=LightBlue ctermbg=NONE guifg=#0000ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Statement ctermfg=DarkYellow ctermbg=NONE guifg=#c0c000 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Todo ctermfg=DarkBlue ctermbg=DarkYellow guifg=#000080 guibg=#c0c000 guisp=NONE cterm=NONE gui=NONE
hi Type ctermfg=DarkGreen ctermbg=NONE guifg=#00c000 guibg=NONE guisp=NONE cterm=NONE gui=NONE

" Color: black                #000000                0        Black
" Color: green                #00c000               44        DarkGreen
" Color: yellow               #c0c000              184        DarkYellow
" Color: blue                 #000080               19        DarkBlue
" Color: cyan                 #00c0c0               51        DarkCyan
" Color: brightblack          #808080              244        DarkGrey
" Color: brightred            #ff0000              196        LightRed
" Color: brightgreen          #00ff00               46        LightGreen
" Color: brightyellow         #ffff00              226        LightYellow
" Color: brightblue           #0000ff               21        LightBlue
" Color: brightcyan           #00ffff               51        LightCyan
" Color: brightwhite          #ffffff              255        White
" Background: dark
" Normal               brightwhite       black
" Directory            green             none
" Search               none              yellow
" StatusLine           brightyellow      brightblue
" Comment              brightblack       none
" Constant             brightcyan        none
" Error                none              brightred
" Identifier           cyan              none
" PreProc              brightgreen       none
" Special              brightblue        none
" Statement            yellow            none                 bold
" Todo                 blue              yellow
" Type                 green             none
