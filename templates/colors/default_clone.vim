" Name:         Default Clone
" Description:  A nearly exact clone of Vim's default colorscheme
" Author:       Bram Moolenaar <Bram@vim.org>
" Maintainer:   Lifepillar <lifepillar@lifepillar.me>
" Website:      https://github.com/vim/vim/blob/master/src/syntax.c
" License:      Vim License (see `:help license`)
" Last Updated: Tue Nov 21 19:58:39 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < 256)
  echoerr '[Default Clone] There are not enough colors.'
  finish
endif

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'default_clone'

if &background ==# 'dark'
  " Color similarity table (dark background)
  "            lightred: GUI=#ffd7d7/rgb(255,215,215)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=0.000000]
  "            white231: GUI=#ffffff/rgb(255,255,255)  Term=231 #ffffff/rgb(255,255,255)  [delta=0.000000]
  "        lightmagenta: GUI=#ffd7ff/rgb(255,215,255)  Term=225 #ffd7ff/rgb(255,215,255)  [delta=0.000000]
  "              grey40: GUI=#666666/rgb(102,102,102)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=2.286696]
  "          lightgreen: GUI=#90ee90/rgb(144,238,144)  Term=121 #87ffaf/rgb(135,255,175)  [delta=5.506701]
  "                grey: GUI=#bebebe/rgb(190,190,190)  Term=248 #a8a8a8/rgb(168,168,168)  [delta=6.064496]
  "              grey50: GUI=#7f7f7f/rgb(127,127,127)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=7.555364]
  "       cyanlightcyan: GUI=#00ffff/rgb(  0,255,255)  Term=159 #afffff/rgb(175,255,255)  [delta=9.538112]
  "           lightcyan: GUI=#e0ffff/rgb(224,255,255)  Term=159 #afffff/rgb(175,255,255)  [delta=9.677722]
  "           lightblue: GUI=#add8e6/rgb(173,216,230)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=10.163918]
  "   lightseagreentype: GUI=#60ff60/rgb( 96,255, 96)  Term=121 #87ffaf/rgb(135,255,175)  [delta=10.311495]
  "         lightyellow: GUI=#ffffe0/rgb(255,255,224)  Term=229 #ffffaf/rgb(255,255,175)  [delta=10.880707]
  "       lightgreygrey: GUI=#d3d3d3/rgb(211,211,211)  Term=248 #a8a8a8/rgb(168,168,168)  [delta=11.246825]
  "     greenlightgreen: GUI=#00ff00/rgb(  0,255,  0)  Term=121 #87ffaf/rgb(135,255,175)  [delta=14.742261]
  "       cyanlightblue: GUI=#00ffff/rgb(  0,255,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=19.943026]
  "            darkgrey: GUI=#a9a9a9/rgb(169,169,169)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=21.550199]
  "               brown: GUI=#a52a2a/rgb(165, 42, 42)  Term=130 #af5f00/rgb(175, 95,  0)  [delta=23.756716]
  "        greydarkgrey: GUI=#bebebe/rgb(190,190,190)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=27.078524]
  " lightblueunderlined: GUI=#80a0ff/rgb(128,160,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=30.383451]
  "       lightseagreen: GUI=#2e8b57/rgb( 46,139, 87)  Term=121 #87ffaf/rgb(135,255,175)  [delta=30.704694]
  " magentalightmagenta: GUI=#ff00ff/rgb(255,  0,255)  Term=225 #ffd7ff/rgb(255,215,255)  [delta=30.845801]
  "              orange: GUI=#ffa500/rgb(255,165,  0)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=31.310244]
  "         redlightred: GUI=#ff0000/rgb(255,  0,  0)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=37.517050]
  "    lightbluepreproc: GUI=#ff80ff/rgb(255,128,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=49.869151]
  "           slateblue: GUI=#6a5acd/rgb(106, 90,205)  Term=  5                           [delta=nan]
  "            darkblue: GUI=#00008b/rgb(  0,  0,139)  Term=  4                           [delta=nan]
  "              yellow: GUI=#ffff00/rgb(255,255,  0)  Term= 11                           [delta=nan]
  "  magentadarkmagenta: GUI=#ff00ff/rgb(255,  0,255)  Term=  5                           [delta=nan]
  "     magentaconstant: GUI=#ffa0a0/rgb(255,160,160)  Term= 13                           [delta=nan]
  "               black: GUI=#000000/rgb(  0,  0,  0)  Term=  0                           [delta=nan]
  "                blue: GUI=#0000ff/rgb(  0,  0,255)  Term= 12                           [delta=nan]
  "     yellowstatement: GUI=#ffff60/rgb(255,255, 96)  Term= 11                           [delta=nan]
  "           lightgrey: GUI=#d3d3d3/rgb(211,211,211)  Term=  7                           [delta=nan]
  "         cyancomment: GUI=#80a0ff/rgb(128,160,255)  Term= 14                           [delta=nan]
  "             darkred: GUI=#8b0000/rgb(139,  0,  0)  Term=  1                           [delta=nan]
  "             magenta: GUI=#ff00ff/rgb(255,  0,255)  Term= 13                           [delta=nan]
  "      magentadarkred: GUI=#ff00ff/rgb(255,  0,255)  Term=  1                           [delta=nan]
  "      cyanidentifier: GUI=#40ffff/rgb( 64,255,255)  Term= 14                           [delta=nan]
  "            seagreen: GUI=#2e8b57/rgb( 46,139, 87)  Term=  2                           [delta=nan]
  "           darkgreen: GUI=#006400/rgb(  0,100,  0)  Term=  2                           [delta=nan]
  "              purple: GUI=#a020f0/rgb(160, 32,240)  Term=  5                           [delta=nan]
  "         lightgrey90: GUI=#e5e5e5/rgb(229,229,229)  Term=  7                           [delta=nan]
  "        bluedarkblue: GUI=#0000ff/rgb(  0,  0,255)  Term=  4                           [delta=nan]
  "         darkmagenta: GUI=#8b008b/rgb(139,  0,139)  Term=  5                           [delta=nan]
  "               green: GUI=#00ff00/rgb(  0,255,  0)  Term= 10                           [delta=nan]
  "            darkcyan: GUI=#008b8b/rgb(  0,139,139)  Term=  6                           [delta=nan]
  "          reddarkred: GUI=#ff0000/rgb(255,  0,  0)  Term=  1                           [delta=nan]
  "                 red: GUI=#ff0000/rgb(255,  0,  0)  Term=  9                           [delta=nan]
  "                cyan: GUI=#00ffff/rgb(  0,255,255)  Term= 14                           [delta=nan]
  "               white: GUI=#ffffff/rgb(255,255,255)  Term= 15                           [delta=nan]
  if has('gui_running') || !get(g:, 'default_clone_transp_bg', 1)
    hi Normal ctermfg=15 ctermbg=0 guifg=White guibg=Black guisp=NONE cterm=NONE gui=NONE
    hi Terminal ctermfg=15 ctermbg=0 guifg=White guibg=Black guisp=NONE cterm=NONE gui=NONE
  else
    hi Normal ctermfg=15 ctermbg=NONE guifg=White guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Terminal ctermfg=15 ctermbg=0 guifg=White guibg=Black guisp=NONE cterm=NONE gui=NONE
  endif
  hi ColorColumn ctermfg=NONE ctermbg=1 guifg=NONE guibg=DarkRed guisp=NONE cterm=NONE gui=NONE
  hi Conceal ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
  hi Cursor ctermfg=0 ctermbg=fg guifg=Black guibg=fg guisp=NONE cterm=NONE gui=NONE
  hi CursorColumn ctermfg=NONE ctermbg=242 guifg=NONE guibg=Grey40 guisp=NONE cterm=NONE gui=NONE
  hi CursorLine ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=Grey40 gui=NONE guisp=NONE
  hi CursorLineNr ctermfg=11 ctermbg=NONE guifg=Yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi DiffAdd ctermfg=NONE ctermbg=4 guifg=NONE guibg=DarkBlue guisp=NONE cterm=NONE gui=NONE
  hi DiffChange ctermfg=NONE ctermbg=5 guifg=NONE guibg=DarkMagenta guisp=NONE cterm=NONE gui=NONE
  hi DiffDelete ctermfg=12 ctermbg=6 guifg=Blue guibg=DarkCyan guisp=NONE cterm=NONE gui=NONE,bold
  hi DiffText ctermfg=NONE ctermbg=9 guifg=NONE guibg=Red guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Directory ctermfg=159 ctermbg=NONE guifg=Cyan guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link EndOfBuffer NonText
  hi ErrorMsg ctermfg=15 ctermbg=1 guifg=White guibg=Red guisp=NONE cterm=NONE gui=NONE
  hi FoldColumn ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey guisp=NONE cterm=NONE gui=NONE
  hi Folded ctermfg=14 ctermbg=242 guifg=Cyan guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
  hi IncSearch ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi LineNr ctermfg=11 ctermbg=NONE guifg=Yellow guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi MatchParen ctermfg=NONE ctermbg=6 guifg=NONE guibg=DarkCyan guisp=NONE cterm=NONE gui=NONE
  hi ModeMsg ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi MoreMsg ctermfg=121 ctermbg=NONE guifg=SeaGreen guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi NonText ctermfg=12 ctermbg=NONE guifg=Blue guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi Pmenu ctermfg=0 ctermbg=13 cterm=NONE guifg=NONE guibg=Magenta gui=NONE guisp=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=248 guifg=NONE guibg=Grey guisp=NONE cterm=NONE gui=NONE
  hi PmenuSel ctermfg=242 ctermbg=0 cterm=NONE guifg=NONE guibg=DarkGrey gui=NONE guisp=NONE
  hi PmenuThumb ctermfg=NONE ctermbg=231 guifg=NONE guibg=White guisp=NONE cterm=NONE gui=NONE
  hi Question ctermfg=121 ctermbg=NONE guifg=Green guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi! link QuickFixLine Search
  hi Search ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow guisp=NONE cterm=NONE gui=NONE
  hi SignColumn ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey guisp=NONE cterm=NONE gui=NONE
  hi SpecialKey ctermfg=81 ctermbg=NONE guifg=Cyan guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SpellBad ctermfg=NONE ctermbg=9 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Red
  hi SpellCap ctermfg=NONE ctermbg=12 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Blue
  hi SpellLocal ctermfg=NONE ctermbg=14 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Cyan
  hi SpellRare ctermfg=NONE ctermbg=13 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Magenta
  hi StatusLine ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
  hi StatusLineNC ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi StatusLineTerm ctermfg=0 ctermbg=121 cterm=NONE,bold guifg=bg guibg=LightGreen gui=NONE,bold guisp=NONE
  hi StatusLineTermNC ctermfg=0 ctermbg=121 cterm=NONE guifg=bg guibg=LightGreen gui=NONE guisp=NONE
  hi TabLine ctermfg=231 ctermbg=242 cterm=NONE,underline guifg=NONE guibg=DarkGrey gui=NONE,underline guisp=NONE
  hi TabLineFill ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi TabLineSel ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Title ctermfg=225 ctermbg=NONE guifg=Magenta guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi VertSplit ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
  hi Visual ctermfg=NONE ctermbg=242 guifg=NONE guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
  hi VisualNOS ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
  hi WarningMsg ctermfg=224 ctermbg=NONE guifg=Red guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi WildMenu ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow guisp=NONE cterm=NONE gui=NONE
  hi! link Boolean Constant
  hi! link Character Constant
  hi Comment ctermfg=14 ctermbg=NONE guifg=#80a0ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Conditional Statement
  hi Constant ctermfg=13 ctermbg=NONE guifg=#ffa0a0 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Define PreProc
  hi! link Debug Special
  hi! link Delimiter Special
  hi Error ctermfg=231 ctermbg=9 guifg=White guibg=Red guisp=NONE cterm=NONE gui=NONE
  hi! link Exception Statement
  hi! link Float Number
  hi! link Function Identifier
  hi Identifier ctermfg=14 ctermbg=NONE guifg=#40ffff guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE
  hi Ignore ctermfg=0 ctermbg=NONE guifg=Black guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Include PreProc
  hi! link Keyword Statement
  hi! link Label Statement
  hi! link Macro PreProc
  hi! link Number Constant
  hi! link Operator Statement
  hi! link PreCondit PreProc
  hi PreProc ctermfg=81 ctermbg=NONE guifg=#ff80ff guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Repeat Statement
  hi Special ctermfg=224 ctermbg=NONE guifg=Orange guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link SpecialChar Special
  hi! link SpecialComment Special
  hi Statement ctermfg=11 ctermbg=NONE guifg=#ffff60 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi! link StorageClass Type
  hi! link String Constant
  hi! link Structure Type
  hi! link Tag Special
  hi Todo ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
  hi Type ctermfg=121 ctermbg=NONE guifg=#60ff60 guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
  hi! link Typedef Type
  hi Underlined ctermfg=81 ctermbg=NONE guifg=#80a0ff guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi! link lCursor Cursor
  hi ToolbarLine ctermfg=NONE ctermbg=242 guifg=NONE guibg=Grey50 guisp=NONE cterm=NONE gui=NONE
  hi ToolbarButton ctermfg=0 ctermbg=7 guifg=Black guibg=LightGrey guisp=NONE cterm=NONE,bold gui=NONE,bold
  finish
endif

" Color similarity table (light background)
"            lightred: GUI=#ffd7d7/rgb(255,215,215)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=0.000000]
"            white231: GUI=#ffffff/rgb(255,255,255)  Term=231 #ffffff/rgb(255,255,255)  [delta=0.000000]
"        lightmagenta: GUI=#ffd7ff/rgb(255,215,255)  Term=225 #ffd7ff/rgb(255,215,255)  [delta=0.000000]
"              grey40: GUI=#666666/rgb(102,102,102)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=2.286696]
"          lightgreen: GUI=#90ee90/rgb(144,238,144)  Term=121 #87ffaf/rgb(135,255,175)  [delta=5.506701]
"                grey: GUI=#bebebe/rgb(190,190,190)  Term=248 #a8a8a8/rgb(168,168,168)  [delta=6.064496]
"              grey50: GUI=#7f7f7f/rgb(127,127,127)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=7.555364]
"       cyanlightcyan: GUI=#00ffff/rgb(  0,255,255)  Term=159 #afffff/rgb(175,255,255)  [delta=9.538112]
"           lightcyan: GUI=#e0ffff/rgb(224,255,255)  Term=159 #afffff/rgb(175,255,255)  [delta=9.677722]
"           lightblue: GUI=#add8e6/rgb(173,216,230)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=10.163918]
"   lightseagreentype: GUI=#60ff60/rgb( 96,255, 96)  Term=121 #87ffaf/rgb(135,255,175)  [delta=10.311495]
"         lightyellow: GUI=#ffffe0/rgb(255,255,224)  Term=229 #ffffaf/rgb(255,255,175)  [delta=10.880707]
"       lightgreygrey: GUI=#d3d3d3/rgb(211,211,211)  Term=248 #a8a8a8/rgb(168,168,168)  [delta=11.246825]
"     greenlightgreen: GUI=#00ff00/rgb(  0,255,  0)  Term=121 #87ffaf/rgb(135,255,175)  [delta=14.742261]
"       cyanlightblue: GUI=#00ffff/rgb(  0,255,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=19.943026]
"            darkgrey: GUI=#a9a9a9/rgb(169,169,169)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=21.550199]
"               brown: GUI=#a52a2a/rgb(165, 42, 42)  Term=130 #af5f00/rgb(175, 95,  0)  [delta=23.756716]
"        greydarkgrey: GUI=#bebebe/rgb(190,190,190)  Term=242 #6c6c6c/rgb(108,108,108)  [delta=27.078524]
" lightblueunderlined: GUI=#80a0ff/rgb(128,160,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=30.383451]
"       lightseagreen: GUI=#2e8b57/rgb( 46,139, 87)  Term=121 #87ffaf/rgb(135,255,175)  [delta=30.704694]
" magentalightmagenta: GUI=#ff00ff/rgb(255,  0,255)  Term=225 #ffd7ff/rgb(255,215,255)  [delta=30.845801]
"              orange: GUI=#ffa500/rgb(255,165,  0)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=31.310244]
"         redlightred: GUI=#ff0000/rgb(255,  0,  0)  Term=224 #ffd7d7/rgb(255,215,215)  [delta=37.517050]
"    lightbluepreproc: GUI=#ff80ff/rgb(255,128,255)  Term= 81 #5fd7ff/rgb( 95,215,255)  [delta=49.869151]
"           slateblue: GUI=#6a5acd/rgb(106, 90,205)  Term=  5                           [delta=nan]
"            darkblue: GUI=#00008b/rgb(  0,  0,139)  Term=  4                           [delta=nan]
"              yellow: GUI=#ffff00/rgb(255,255,  0)  Term= 11                           [delta=nan]
"  magentadarkmagenta: GUI=#ff00ff/rgb(255,  0,255)  Term=  5                           [delta=nan]
"     magentaconstant: GUI=#ffa0a0/rgb(255,160,160)  Term= 13                           [delta=nan]
"               black: GUI=#000000/rgb(  0,  0,  0)  Term=  0                           [delta=nan]
"                blue: GUI=#0000ff/rgb(  0,  0,255)  Term= 12                           [delta=nan]
"     yellowstatement: GUI=#ffff60/rgb(255,255, 96)  Term= 11                           [delta=nan]
"           lightgrey: GUI=#d3d3d3/rgb(211,211,211)  Term=  7                           [delta=nan]
"         cyancomment: GUI=#80a0ff/rgb(128,160,255)  Term= 14                           [delta=nan]
"             darkred: GUI=#8b0000/rgb(139,  0,  0)  Term=  1                           [delta=nan]
"             magenta: GUI=#ff00ff/rgb(255,  0,255)  Term= 13                           [delta=nan]
"      magentadarkred: GUI=#ff00ff/rgb(255,  0,255)  Term=  1                           [delta=nan]
"      cyanidentifier: GUI=#40ffff/rgb( 64,255,255)  Term= 14                           [delta=nan]
"            seagreen: GUI=#2e8b57/rgb( 46,139, 87)  Term=  2                           [delta=nan]
"           darkgreen: GUI=#006400/rgb(  0,100,  0)  Term=  2                           [delta=nan]
"              purple: GUI=#a020f0/rgb(160, 32,240)  Term=  5                           [delta=nan]
"         lightgrey90: GUI=#e5e5e5/rgb(229,229,229)  Term=  7                           [delta=nan]
"        bluedarkblue: GUI=#0000ff/rgb(  0,  0,255)  Term=  4                           [delta=nan]
"         darkmagenta: GUI=#8b008b/rgb(139,  0,139)  Term=  5                           [delta=nan]
"               green: GUI=#00ff00/rgb(  0,255,  0)  Term= 10                           [delta=nan]
"            darkcyan: GUI=#008b8b/rgb(  0,139,139)  Term=  6                           [delta=nan]
"          reddarkred: GUI=#ff0000/rgb(255,  0,  0)  Term=  1                           [delta=nan]
"                 red: GUI=#ff0000/rgb(255,  0,  0)  Term=  9                           [delta=nan]
"                cyan: GUI=#00ffff/rgb(  0,255,255)  Term= 14                           [delta=nan]
"               white: GUI=#ffffff/rgb(255,255,255)  Term= 15                           [delta=nan]
if has('gui_running') || !get(g:, 'default_clone_transp_bg', 1)
  hi Normal ctermfg=0 ctermbg=15 guifg=Black guibg=White guisp=NONE cterm=NONE gui=NONE
  hi Terminal ctermfg=0 ctermbg=15 guifg=Black guibg=White guisp=NONE cterm=NONE gui=NONE
else
  hi Normal ctermfg=15 ctermbg=NONE guifg=White guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Terminal ctermfg=15 ctermbg=NONE guifg=White guibg=NONE guisp=NONE cterm=NONE gui=NONE
endif
hi ColorColumn ctermfg=NONE ctermbg=224 guifg=NONE guibg=LightRed guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=15 ctermbg=fg guifg=White guibg=fg guisp=NONE cterm=NONE gui=NONE
hi CursorColumn ctermfg=NONE ctermbg=7 guifg=NONE guibg=Grey90 guisp=NONE cterm=NONE gui=NONE
hi CursorLine ctermfg=NONE ctermbg=NONE cterm=underline guifg=NONE guibg=Grey90 gui=NONE guisp=NONE
hi CursorLineNr ctermfg=130 ctermbg=NONE guifg=Brown guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi DiffAdd ctermfg=NONE ctermbg=81 guifg=NONE guibg=LightBlue guisp=NONE cterm=NONE gui=NONE
hi DiffChange ctermfg=NONE ctermbg=225 guifg=NONE guibg=LightMagenta guisp=NONE cterm=NONE gui=NONE
hi DiffDelete ctermfg=12 ctermbg=159 guifg=Blue guibg=LightCyan guisp=NONE cterm=NONE gui=NONE,bold
hi DiffText ctermfg=NONE ctermbg=9 guifg=NONE guibg=Red guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Directory ctermfg=4 ctermbg=NONE guifg=Blue guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link EndOfBuffer NonText
hi ErrorMsg ctermfg=15 ctermbg=1 guifg=White guibg=Red guisp=NONE cterm=NONE gui=NONE
hi FoldColumn ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=Grey guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=LightGrey guisp=NONE cterm=NONE gui=NONE
hi IncSearch ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi LineNr ctermfg=130 ctermbg=NONE guifg=Brown guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=NONE ctermbg=14 guifg=NONE guibg=Cyan guisp=NONE cterm=NONE gui=NONE
hi ModeMsg ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi MoreMsg ctermfg=2 ctermbg=NONE guifg=SeaGreen guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi NonText ctermfg=12 ctermbg=NONE guifg=Blue guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi Pmenu ctermfg=0 ctermbg=225 cterm=NONE guifg=NONE guibg=LightMagenta gui=NONE guisp=NONE
hi PmenuSbar ctermfg=NONE ctermbg=248 guifg=NONE guibg=Grey guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermfg=0 ctermbg=7 cterm=NONE guifg=NONE guibg=Grey gui=NONE guisp=NONE
hi PmenuThumb ctermfg=NONE ctermbg=0 guifg=NONE guibg=Black guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=2 ctermbg=NONE guifg=SeaGreen guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link QuickFixLine Search
hi Search ctermfg=NONE ctermbg=11 guifg=NONE guibg=Yellow guisp=NONE cterm=NONE gui=NONE
hi SignColumn ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=Grey guisp=NONE cterm=NONE gui=NONE
hi SpecialKey ctermfg=4 ctermbg=NONE guifg=Blue guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermfg=NONE ctermbg=224 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Red
hi SpellCap ctermfg=NONE ctermbg=81 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Blue
hi SpellLocal ctermfg=NONE ctermbg=14 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=DarkCyan
hi SpellRare ctermfg=NONE ctermbg=225 cterm=NONE guifg=NONE guibg=NONE gui=NONE,undercurl guisp=Magenta
hi StatusLine ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
hi StatusLineNC ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi StatusLineTerm ctermfg=15 ctermbg=2 cterm=NONE,bold guifg=bg guibg=DarkGreen gui=NONE,bold guisp=NONE
hi StatusLineTermNC ctermfg=15 ctermbg=2 cterm=NONE guifg=bg guibg=DarkGreen gui=NONE guisp=NONE
hi TabLine ctermfg=0 ctermbg=7 cterm=NONE,underline guifg=NONE guibg=LightGrey gui=NONE,underline guisp=NONE
hi TabLineFill ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi TabLineSel ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Title ctermfg=5 ctermbg=NONE guifg=Magenta guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi VertSplit ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,reverse gui=NONE,reverse
hi Visual ctermfg=NONE ctermbg=7 guifg=NONE guibg=LightGrey guisp=NONE cterm=NONE gui=NONE
hi VisualNOS ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
hi WarningMsg ctermfg=1 ctermbg=NONE guifg=Red guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi WildMenu ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow guisp=NONE cterm=NONE gui=NONE
hi! link Boolean Constant
hi! link Character Constant
hi Comment ctermfg=4 ctermbg=NONE guifg=Blue guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Conditional Statement
hi Constant ctermfg=1 ctermbg=NONE guifg=Magenta guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Define PreProc
hi! link Debug Special
hi! link Delimiter Special
hi Error ctermfg=15 ctermbg=9 guifg=White guibg=Red guisp=NONE cterm=NONE gui=NONE
hi! link Exception Statement
hi! link Float Number
hi! link Function Identifier
hi Identifier ctermfg=6 ctermbg=NONE guifg=DarkCyan guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Ignore ctermfg=15 ctermbg=NONE cterm=NONE guifg=bg guibg=NONE gui=NONE guisp=NONE
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi! link Number Constant
hi! link Operator Statement
hi! link PreCondit PreProc
hi PreProc ctermfg=5 ctermbg=NONE guifg=Purple guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Repeat Statement
hi Special ctermfg=5 ctermbg=NONE guifg=SlateBlue guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link SpecialChar Special
hi! link SpecialComment Special
hi Statement ctermfg=130 ctermbg=NONE guifg=Brown guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link Tag Special
hi Todo ctermfg=0 ctermbg=11 cterm=NONE guifg=Blue guibg=Yellow gui=NONE guisp=NONE
hi Type ctermfg=2 ctermbg=NONE guifg=SeaGreen guibg=NONE guisp=NONE cterm=NONE gui=NONE,bold
hi! link Typedef Type
hi Underlined ctermfg=5 ctermbg=NONE guifg=SlateBlue guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi lCursor ctermfg=15 ctermbg=fg guifg=White guibg=fg guisp=NONE cterm=NONE gui=NONE
hi ToolbarLine ctermfg=NONE ctermbg=7 guifg=NONE guibg=LightGrey guisp=NONE cterm=NONE gui=NONE
hi ToolbarButton ctermfg=15 ctermbg=242 guifg=White guibg=Grey40 guisp=NONE cterm=NONE,bold gui=NONE,bold
finish

" Color: black                Black                  0        Black
" Color: blue                 Blue                  12        Blue
" Color: bluedarkblue         Blue                   4        DarkBlue
" Color: brown                Brown                130        Brown
" Color: cyan                 Cyan                  14        Cyan
" Color: cyancomment          #80a0ff               14        Cyan
" Color: cyanidentifier       #40ffff               14        Cyan
" Color: cyanlightblue        Cyan                  81        LightBlue
" Color: cyanlightcyan        Cyan                 159        LightCyan
" Color: darkblue             DarkBlue               4        DarkBlue
" Color: darkcyan             DarkCyan               6        DarkCyan
" Color: darkgreen            DarkGreen              2        DarkGreen
" Color: darkgrey             DarkGrey             242        DarkGrey
" Color: darkmagenta          DarkMagenta            5        DarkMagenta
" Color: darkred              DarkRed                1        DarkRed
" Color: green                Green                 10        Green
" Color: greenlightgreen      Green                121        LightGreen
" Color: grey                 Grey                 248        Grey
" Color: grey40               Grey40               242        DarkGrey
" Color: grey50               Grey50               242        DarkGrey
" Color: greydarkgrey         Grey                 242        DarkGrey
" Color: lightblue            LightBlue             81        LightBlue
" Color: lightbluepreproc     #ff80ff               81        LightBlue
" Color: lightblueunderlined  #80a0ff               81        LightBlue
" Color: lightcyan            LightCyan            159        LightCyan
" Color: lightgreen           LightGreen           121        LightGreen
" Color: lightgrey            LightGrey              7        LightGrey
" Color: lightgrey90          Grey90                 7        LightGrey
" Color: lightgreygrey        LightGrey            248        Grey
" Color: lightmagenta         LightMagenta         225        LightMagenta
" Color: lightred             LightRed             224        LightRed
" Color: lightseagreen        SeaGreen             121        LightGreen
" Color: lightseagreentype    #60ff60              121        LightGreen
" Color: lightyellow          LightYellow          229        LightYellow
" Color: magenta              Magenta               13        Magenta
" Color: magentaconstant      #ffa0a0               13        Magenta
" Color: magentadarkmagenta   Magenta                5        DarkMagenta
" Color: magentadarkred       Magenta                1        DarkRed
" Color: magentalightmagenta  Magenta              225        LightMagenta
" Color: orange               Orange               224        LightRed
" Color: purple               Purple                 5        DarkMagenta
" Color: red                  Red                    9        Red
" Color: reddarkred           Red                    1        DarkRed
" Color: redlightred          Red                  224        LightRed
" Color: seagreen             SeaGreen               2        DarkGreen
" Color: slateblue            SlateBlue              5        DarkMagenta
" Color: white                White                 15        White
" Color: white231             White                231        White
" Color: yellow               Yellow                11        Yellow
" Color: yellowstatement      #ffff60               11        Yellow
" Background: light
"     Normal           black             white
"     Terminal         black             white
"     Normal           white             none
"     Terminal         white             none
" ColorColumn          none              lightred
" Conceal              lightgrey         darkgrey
" Cursor               white             fg
" CursorColumn         none              lightgrey90
" CursorLineNr         brown             none              g=bold
" DiffAdd              none              lightblue
" DiffChange           none              lightmagenta
" DiffDelete           blue              lightcyan         g=bold
" DiffText             none              red               bold
" Directory            bluedarkblue      none
" EndOfBuffer       -> NonText
" ErrorMsg             white             reddarkred
" FoldColumn           darkblue          grey
" Folded               darkblue          lightgreygrey
" IncSearch            none              none              reverse
" LineNr               brown             none
" MatchParen           none              cyan
" ModeMsg              none              none              bold
" MoreMsg              seagreen          none              g=bold
" NonText              blue              none              g=bold
" PmenuSbar            none              grey
" PmenuThumb           none              black
" Question             seagreen          none              g=bold
" QuickFixLine     ->  Search
" Search               none              yellow
" SignColumn           darkblue          grey
" SpecialKey           bluedarkblue      none
" StatusLine           none              none              reverse,bold
" StatusLineNC         none              none              reverse
" TabLineFill          none              none              reverse
" TabLineSel           none              none              bold
" Title                magentadarkmagenta none             g=bold
" VertSplit            none              none              reverse
" Visual               none              lightgrey
" VisualNOS            none              none              underline,bold
" WarningMsg           reddarkred        none
" WildMenu             black             yellow
" Boolean           -> Constant
" Character         -> Constant
" Comment              bluedarkblue      none
" Conditional       -> Statement
" Constant             magentadarkred    none
" Define            -> PreProc
" Debug             -> Special
" Delimiter         -> Special
" Error                white             red
" Exception         -> Statement
" Float             -> Number
" Function          -> Identifier
" Identifier           darkcyan          none
" Include           -> PreProc
" Keyword           -> Statement
" Label             -> Statement
" Macro             -> PreProc
" Number            -> Constant
" Operator          -> Statement
" PreCondit         -> PreProc
" PreProc              purple            none
" Repeat            -> Statement
" Special              slateblue         none
" SpecialChar       -> Special
" SpecialComment    -> Special
" Statement            brown             none              g=bold
" StorageClass      -> Type
" String            -> Constant
" Structure         -> Type
" Tag               -> Special
" Type                 seagreen          none              g=bold
" Typedef           -> Type
" Underlined           slateblue         none              underline
" lCursor              white             fg
" ToolbarLine          none              lightgrey
" ToolbarButton        white             grey40            bold
" Background: dark
"     Normal           white             black
"     Terminal         white             black
"     Normal           white             none
"     Terminal         white             black
" ColorColumn          none              darkred
" Conceal              lightgrey         darkgrey
" Cursor               black             fg
" CursorColumn         none              grey40
" CursorLineNr         yellow            none              g=bold
" DiffAdd              none              darkblue
" DiffChange           none              darkmagenta
" DiffDelete           blue              darkcyan          g=bold
" DiffText             none              red               bold
" Directory            cyanlightcyan     none
" EndOfBuffer       -> NonText
" ErrorMsg             white             reddarkred
" FoldColumn           cyan              greydarkgrey
" Folded               cyan              darkgrey
" IncSearch            none              none              reverse
" LineNr               yellow            none
" MatchParen           none              darkcyan
" ModeMsg              none              none              bold
" MoreMsg              lightseagreen     none              g=bold
" NonText              blue              none              g=bold
" PmenuSbar            none              grey
" PmenuThumb           none              white231
" Question             greenlightgreen   none              g=bold
" QuickFixLine     ->  Search
" Search               black             yellow
" SignColumn           cyan              greydarkgrey
" SpecialKey           cyanlightblue     none
" StatusLine           none              none              reverse,bold
" StatusLineNC         none              none              reverse
" TabLineFill          none              none              reverse
" TabLineSel           none              none              bold
" Title                magentalightmagenta none            g=bold
" VertSplit            none              none              reverse
" Visual               none              darkgrey
" VisualNOS            none              none              underline,bold
" WarningMsg           redlightred       none
" WildMenu             black             yellow
" Boolean           -> Constant
" Character         -> Constant
" Comment              cyancomment       none
" Conditional       -> Statement
" Constant             magentaconstant   none
" Define            -> PreProc
" Debug             -> Special
" Delimiter         -> Special
" Error                white231          red
" Exception         -> Statement
" Float             -> Number
" Function          -> Identifier
" Identifier           cyanidentifier    none              t=bold
" Ignore               black             none
" Include           -> PreProc
" Keyword           -> Statement
" Label             -> Statement
" Macro             -> PreProc
" Number            -> Constant
" Operator          -> Statement
" PreCondit         -> PreProc
" PreProc              lightbluepreproc  none
" Repeat            -> Statement
" Special              orange            none
" SpecialChar       -> Special
" SpecialComment    -> Special
" Statement            yellowstatement   none              g=bold
" StorageClass      -> Type
" String            -> Constant
" Structure         -> Type
" Tag               -> Special
" Type                 lightseagreentype none              g=bold
" Typedef           -> Type
" Underlined           lightblueunderlined none            underline
" lCursor           -> Cursor
" ToolbarLine          none              grey50
" ToolbarButton        black             lightgrey         bold
