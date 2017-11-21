" Name:         Dark and Light
" Description:  Template for a colorscheme with dark and light variants
" Author:       Myself <myself@somewhere.org>
" Maintainer:   Myself <myself@somewhere.org>
" License:      Vim License (see `:help license`)
" Last Updated: Tue Nov 21 19:58:38 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < 256)
  echoerr '[Dark and Light] There are not enough colors.'
  finish
endif

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'dark_and_light'

if &background ==# 'dark'
  " Color similarity table (dark background)
  "         green: GUI=#00ff00/rgb(  0,255,  0)  Term= 46 #00ff00/rgb(  0,255,  0)  [delta=0.000000]
  "        yellow: GUI=#ffff00/rgb(255,255,  0)  Term=226 #ffff00/rgb(255,255,  0)  [delta=0.000000]
  "           red: GUI=#ff0000/rgb(255,  0,  0)  Term=196 #ff0000/rgb(255,  0,  0)  [delta=0.000000]
  "         black: GUI=#000000/rgb(  0,  0,  0)  Term= 16 #000000/rgb(  0,  0,  0)  [delta=0.000000]
  "   brightwhite: GUI=#ffffff/rgb(255,255,255)  Term=231 #ffffff/rgb(255,255,255)  [delta=0.000000]
  "          cyan: GUI=#00ffff/rgb(  0,255,255)  Term= 51 #00ffff/rgb(  0,255,255)  [delta=0.000000]
  "       magenta: GUI=#ff00ff/rgb(255,  0,255)  Term=201 #ff00ff/rgb(255,  0,255)  [delta=0.000000]
  "          blue: GUI=#0000ff/rgb(  0,  0,255)  Term= 21 #0000ff/rgb(  0,  0,255)  [delta=0.000000]
  "    brightcyan: GUI=#64ffff/rgb(100,255,255)  Term= 87 #5fffff/rgb( 95,255,255)  [delta=0.282977]
  "   brightgreen: GUI=#64ff00/rgb(100,255,  0)  Term= 82 #5fff00/rgb( 95,255,  0)  [delta=0.315029]
  "  brightyellow: GUI=#ffff64/rgb(255,255,100)  Term=227 #ffff5f/rgb(255,255, 95)  [delta=0.457139]
  "   brightblack: GUI=#d2d2d2/rgb(210,210,210)  Term=252 #d0d0d0/rgb(208,208,208)  [delta=0.476484]
  "         white: GUI=#ebebeb/rgb(235,235,235)  Term=255 #eeeeee/rgb(238,238,238)  [delta=0.636113]
  " brightmagenta: GUI=#ff64ff/rgb(255,100,255)  Term=207 #ff5fff/rgb(255, 95,255)  [delta=0.704140]
  "     brightred: GUI=#ff6400/rgb(255,100,  0)  Term=202 #ff5f00/rgb(255, 95,  0)  [delta=1.252302]
  "    brightblue: GUI=#0064ff/rgb(  0,100,255)  Term= 27 #005fff/rgb(  0, 95,255)  [delta=1.596641]
  if !has('gui_running') && get(g:, 'dark_and_light_transp_bg', 0)
    hi Normal ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Terminal ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  else
    hi Normal ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
    hi Terminal ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  endif
  hi ColorColumn ctermfg=fg ctermbg=16 guifg=fg guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi Conceal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Cursor ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi CursorColumn ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi CursorLine ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi CursorLineNr ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi DiffAdd ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi DiffChange ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi DiffDelete ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi DiffText ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
  hi Directory ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi EndOfBuffer ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi ErrorMsg ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi FoldColumn ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi Folded ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi IncSearch ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,reverse gui=NONE,standout
  hi LineNr ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi MatchParen ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi ModeMsg ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi MoreMsg ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi NonText ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi Pmenu ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi PmenuSbar ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi PmenuSel ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi PmenuThumb ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi Question ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi! link QuickFixLine Search
  hi Search ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi SignColumn ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi SpecialKey ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi SpellBad ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=#ff0000 cterm=NONE gui=NONE
  hi SpellCap ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=#0000ff cterm=NONE gui=NONE
  hi SpellLocal ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=#ff00ff cterm=NONE gui=NONE
  hi SpellRare ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=#00ffff cterm=NONE,reverse gui=NONE,reverse
  hi StatusLine ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi StatusLineNC ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi! link StatusLineTerm StatusLine
  hi! link StatusLineTermNC StatusLineNC
  hi TabLine ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi TabLineFill ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi TabLineSel ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi Title ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi VertSplit ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi Visual ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi VisualNOS ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi WarningMsg ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi WildMenu ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE gui=NONE
  hi! link Boolean Constant
  hi! link Character Constant
  hi Comment ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Conditional Statement
  hi Constant ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Define PreProc
  hi! link Debug Special
  hi! link Delimiter Special
  hi Error ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi! link Exception Statement
  hi! link Float Constant
  hi! link Function Identifier
  hi Identifier ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Ignore ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Include PreProc
  hi! link Keyword Statement
  hi! link Label Statement
  hi! link Macro PreProc
  hi! link Number Constant
  hi! link Operator Statement
  hi! link PreCondit PreProc
  hi PreProc ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Repeat Statement
  hi Special ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link SpecialChar Special
  hi! link SpecialComment Special
  hi Statement ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link StorageClass Type
  hi! link String Constant
  hi! link Structure Type
  hi! link Tag Special
  hi Todo ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Type ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Typedef Type
  hi Underlined ctermfg=255 ctermbg=NONE guifg=#ebebeb guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link lCursor Cursor
  hi CursorIM ctermfg=NONE ctermbg=fg guifg=NONE guibg=fg guisp=NONE cterm=NONE gui=NONE
  hi ToolbarLine ctermfg=NONE ctermbg=255 guifg=NONE guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
  hi ToolbarButton ctermfg=255 ctermbg=16 guifg=#ebebeb guibg=#000000 guisp=NONE cterm=NONE,bold gui=NONE,bold
  finish
endif

" Color similarity table (light background)
"         green: GUI=#00ff00/rgb(  0,255,  0)  Term= 46 #00ff00/rgb(  0,255,  0)  [delta=0.000000]
"        yellow: GUI=#ffff00/rgb(255,255,  0)  Term=226 #ffff00/rgb(255,255,  0)  [delta=0.000000]
"           red: GUI=#ff0000/rgb(255,  0,  0)  Term=196 #ff0000/rgb(255,  0,  0)  [delta=0.000000]
"         black: GUI=#000000/rgb(  0,  0,  0)  Term= 16 #000000/rgb(  0,  0,  0)  [delta=0.000000]
"   brightwhite: GUI=#ffffff/rgb(255,255,255)  Term=231 #ffffff/rgb(255,255,255)  [delta=0.000000]
"          cyan: GUI=#00ffff/rgb(  0,255,255)  Term= 51 #00ffff/rgb(  0,255,255)  [delta=0.000000]
"       magenta: GUI=#ff00ff/rgb(255,  0,255)  Term=201 #ff00ff/rgb(255,  0,255)  [delta=0.000000]
"          blue: GUI=#0000ff/rgb(  0,  0,255)  Term= 21 #0000ff/rgb(  0,  0,255)  [delta=0.000000]
"    brightcyan: GUI=#64ffff/rgb(100,255,255)  Term= 87 #5fffff/rgb( 95,255,255)  [delta=0.282977]
"   brightgreen: GUI=#64ff00/rgb(100,255,  0)  Term= 82 #5fff00/rgb( 95,255,  0)  [delta=0.315029]
"  brightyellow: GUI=#ffff64/rgb(255,255,100)  Term=227 #ffff5f/rgb(255,255, 95)  [delta=0.457139]
"   brightblack: GUI=#d2d2d2/rgb(210,210,210)  Term=252 #d0d0d0/rgb(208,208,208)  [delta=0.476484]
"         white: GUI=#ebebeb/rgb(235,235,235)  Term=255 #eeeeee/rgb(238,238,238)  [delta=0.636113]
" brightmagenta: GUI=#ff64ff/rgb(255,100,255)  Term=207 #ff5fff/rgb(255, 95,255)  [delta=0.704140]
"     brightred: GUI=#ff6400/rgb(255,100,  0)  Term=202 #ff5f00/rgb(255, 95,  0)  [delta=1.252302]
"    brightblue: GUI=#0064ff/rgb(  0,100,255)  Term= 27 #005fff/rgb(  0, 95,255)  [delta=1.596641]
if !has('gui_running') && get(g:, 'dark_and_light_transp_bg', 0)
  hi Normal ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Terminal ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
  hi Normal ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
  hi Terminal ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
endif
hi ColorColumn ctermfg=fg ctermbg=16 guifg=fg guibg=#000000 guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi CursorColumn ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi CursorLine ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi CursorLineNr ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi DiffAdd ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi DiffChange ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi DiffDelete ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi DiffText ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
hi Directory ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi EndOfBuffer ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi ErrorMsg ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi FoldColumn ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,italic gui=NONE,italic
hi IncSearch ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,reverse gui=NONE,standout
hi LineNr ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi ModeMsg ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi MoreMsg ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi NonText ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi Pmenu ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi PmenuSbar ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi PmenuThumb ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi! link QuickFixLine Search
hi Search ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi SignColumn ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi SpecialKey ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=#ff0000 cterm=NONE gui=NONE
hi SpellCap ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=#0000ff cterm=NONE gui=NONE
hi SpellLocal ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=#ff00ff cterm=NONE gui=NONE
hi SpellRare ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=#00ffff cterm=NONE,reverse gui=NONE,reverse
hi StatusLine ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi StatusLineNC ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi TabLine ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi TabLineFill ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi TabLineSel ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi Title ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi VertSplit ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi Visual ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi VisualNOS ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi WarningMsg ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi WildMenu ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE gui=NONE
hi! link Boolean Constant
hi! link Character Constant
hi Comment ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Conditional Statement
hi Constant ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Define PreProc
hi! link Debug Special
hi! link Delimiter Special
hi Error ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi! link Exception Statement
hi! link Float Constant
hi! link Function Identifier
hi Identifier ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Ignore ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi! link Number Constant
hi! link Operator Statement
hi! link PreCondit PreProc
hi PreProc ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Repeat Statement
hi Special ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link SpecialChar Special
hi! link SpecialComment Special
hi Statement ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link Tag Special
hi Todo ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Type ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Typedef Type
hi Underlined ctermfg=16 ctermbg=NONE guifg=#000000 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link lCursor Cursor
hi CursorIM ctermfg=NONE ctermbg=fg guifg=NONE guibg=fg guisp=NONE cterm=NONE gui=NONE
hi ToolbarLine ctermfg=NONE ctermbg=16 guifg=NONE guibg=#000000 guisp=NONE cterm=NONE gui=NONE
hi ToolbarButton ctermfg=16 ctermbg=255 guifg=#000000 guibg=#ebebeb guisp=NONE cterm=NONE,bold gui=NONE,bold
finish

" Background: dark
" Color: black                rgb(  0,   0,   0)     ~        Black
" Color: red                  rgb(255,   0,   0)     ~        DarkRed
" Color: green                rgb(  0, 255,   0)     ~        DarkGreen
" Color: yellow               rgb(255, 255,   0)     ~        DarkYellow
" Color: blue                 rgb(  0,   0, 255)     ~        DarkBlue
" Color: magenta              rgb(255,   0, 255)     ~        DarkMagenta
" Color: cyan                 rgb(  0, 255, 255)     ~        DarkCyan
" Color: white                rgb(235, 235, 235)     ~        LightGrey
" Color: brightblack          rgb(210, 210, 210)     ~        DarkGrey
" Color: brightred            rgb(255, 100,   0)     ~        LightRed
" Color: brightgreen          rgb(100, 255,   0)     ~        LightGreen
" Color: brightyellow         rgb(255, 255, 100)     ~        LightYellow
" Color: brightblue           rgb(  0, 100, 255)     ~        LightBlue
" Color: brightmagenta        rgb(255, 100, 255)     ~        LightMagenta
" Color: brightcyan           rgb(100, 255, 255)     ~        LightCyan
" Color: brightwhite          #ffffff                231      White
"     Normal           white             none
"     Terminal         white             none
"     Normal           white             black
"     Terminal         white             black
" ColorColumn          fg                black
" Conceal              none              none
" Cursor               white             black
" CursorColumn         white             black
" CursorLine           white             black
" CursorLineNr         white             black
" DiffAdd              white             black             reverse
" DiffChange           white             black             reverse
" DiffDelete           white             black             reverse
" DiffText             white             black             bold,reverse
" Directory            white             black
" EndOfBuffer          white             black
" ErrorMsg             white             black             reverse
" FoldColumn           white             black
" Folded               white             black             italic
" IncSearch            white             black             t=reverse g=standout
" LineNr               white             black
" MatchParen           white             black
" ModeMsg              white             black
" MoreMsg              white             black
" NonText              white             black
" Pmenu                white             black
" PmenuSbar            white             black
" PmenuSel             white             black
" PmenuThumb           white             black
" Question             white             black
" QuickFixLine     ->  Search
" Search               white             black
" SignColumn           white             black
" SpecialKey           white             black
" SpellBad             white             black             s=red
" SpellCap             white             black             s=blue
" SpellLocal           white             black             s=magenta
" SpellRare            white             black             s=cyan reverse
" StatusLine           white             black
" StatusLineNC         white             black
" StatusLineTerm    -> StatusLine
" StatusLineTermNC  -> StatusLineNC
" TabLine              white             black
" TabLineFill          white             black
" TabLineSel           white             black
" Title                white             black
" VertSplit            white             black
" Visual               white             black
" VisualNOS            white             black
" WarningMsg           white             black
" WildMenu             white             black
" Boolean           -> Constant
" Character         -> Constant
" Comment              white             none
" Conditional       -> Statement
" Constant             white             none
" Define            -> PreProc
" Debug             -> Special
" Delimiter         -> Special
" Error                white             black             reverse
" Exception         -> Statement
" Float             -> Constant
" Function          -> Identifier
" Identifier           white             none
" Ignore               white             none
" Include           -> PreProc
" Keyword           -> Statement
" Label             -> Statement
" Macro             -> PreProc
" Number            -> Constant
" Operator          -> Statement
" PreCondit         -> PreProc
" PreProc              white             none
" Repeat            -> Statement
" Special              white             none
" SpecialChar       -> Special
" SpecialComment    -> Special
" Statement            white             none
" StorageClass      -> Type
" String            -> Constant
" Structure         -> Type
" Tag               -> Special
" Todo                 white             none
" Type                 white             none
" Typedef           -> Type
" Underlined           white             none
" lCursor           -> Cursor
" CursorIM             none              fg
" ToolbarLine          none              white
" ToolbarButton        white             black             bold
" Background: light
" Color: black                rgb(  0,   0,   0)     ~        Black
" Color: red                  rgb(255,   0,   0)     ~        DarkRed
" Color: green                rgb(  0, 255,   0)     ~        DarkGreen
" Color: yellow               rgb(255, 255,   0)     ~        DarkYellow
" Color: blue                 rgb(  0,   0, 255)     ~        DarkBlue
" Color: magenta              rgb(255,   0, 255)     ~        DarkMagenta
" Color: cyan                 rgb(  0, 255, 255)     ~        DarkCyan
" Color: white                rgb(235, 235, 235)     ~        LightGrey
" Color: brightblack          rgb(210, 210, 210)     ~        DarkGrey
" Color: brightred            rgb(255, 100,   0)     ~        LightRed
" Color: brightgreen          rgb(100, 255,   0)     ~        LightGreen
" Color: brightyellow         rgb(255, 255, 100)     ~        LightYellow
" Color: brightblue           rgb(  0, 100, 255)     ~        LightBlue
" Color: brightmagenta        rgb(255, 100, 255)     ~        LightMagenta
" Color: brightcyan           rgb(100, 255, 255)     ~        LightCyan
" Color: brightwhite          #ffffff                231      White
"     Normal           black             none
"     Terminal         black             none
"     Normal           black             white
"     Terminal         black             white
" ColorColumn          fg                black
" Conceal              none              none
" Cursor               black             white
" CursorColumn         black             white
" CursorLine           black             white
" CursorLineNr         black             white
" DiffAdd              black             white             reverse
" DiffChange           black             white             reverse
" DiffDelete           black             white             reverse
" DiffText             black             white             bold,reverse
" Directory            black             white
" EndOfBuffer          black             white
" ErrorMsg             black             white             reverse
" FoldColumn           black             white
" Folded               black             white             italic
" IncSearch            black             white             t=reverse g=standout
" LineNr               black             white
" MatchParen           black             white
" ModeMsg              black             white
" MoreMsg              black             white
" NonText              black             white
" Pmenu                black             white
" PmenuSbar            black             white
" PmenuSel             black             white
" PmenuThumb           black             white
" Question             black             white
" QuickFixLine     ->  Search
" Search               black             white
" SignColumn           black             white
" SpecialKey           black             white
" SpellBad             black             white             s=red
" SpellCap             black             white             s=blue
" SpellLocal           black             white             s=magenta
" SpellRare            black             white             s=cyan reverse
" StatusLine           black             white
" StatusLineNC         black             white
" StatusLineTerm    -> StatusLine
" StatusLineTermNC  -> StatusLineNC
" TabLine              black             white
" TabLineFill          black             white
" TabLineSel           black             white
" Title                black             white
" VertSplit            black             white
" Visual               black             white
" VisualNOS            black             white
" WarningMsg           black             white
" WildMenu             black             white
" Boolean           -> Constant
" Character         -> Constant
" Comment              black             none
" Conditional       -> Statement
" Constant             black             none
" Define            -> PreProc
" Debug             -> Special
" Delimiter         -> Special
" Error                black             white             reverse
" Exception         -> Statement
" Float             -> Constant
" Function          -> Identifier
" Identifier           black             none
" Ignore               black             none
" Include           -> PreProc
" Keyword           -> Statement
" Label             -> Statement
" Macro             -> PreProc
" Number            -> Constant
" Operator          -> Statement
" PreCondit         -> PreProc
" PreProc              black             none
" Repeat            -> Statement
" Special              black             none
" SpecialChar       -> Special
" SpecialComment    -> Special
" Statement            black             none
" StorageClass      -> Type
" String            -> Constant
" Structure         -> Type
" Tag               -> Special
" Todo                 black             none
" Type                 black             none
" Typedef           -> Type
" Underlined           black             none
" lCursor           -> Cursor
" CursorIM             none              fg
" ToolbarLine          none              black
" ToolbarButton        black             white             bold
