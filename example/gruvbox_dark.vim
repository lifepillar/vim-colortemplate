" Name:         Gruvbox Dark colorscheme for Vim
" Author:       morhetz <morhetz@gmail.com>
" Maintainer:   Lifepillar <lifepillar@lifepillar.me>
" License:      Vim License  (see `:help license`)

" Color palette:
"  "light4": ["#a89984", 246, "LightGreen"]
"  "green": ["#b8bb26", 142, "LightGreen"]
"  "yellow": ["#fabd2f", 214, "LightYellow"]
"  "aqua": ["#8ec07c", 108, "LightCyan"]
"  "bg": ["#282828", 235, "Black"]
"  "none": ["NONE", NONE, "NONE"]
"  "red": ["#fb4934", 167, "LightRed"]
"  "orange": ["#fe8019", 208, "LightYellow"]
"  "fg": ["#ebdbb2", 223, "LightGrey"]
"  "dark0": ["#282828", 235, "Black"]
"  "dark1": ["#3c3836", 237, "DarkRed"]
"  "dark2": ["#504945", 239, "DarkGreen"]
"  "dark3": ["#665c54", 241, "DarkYellow"]
"  "dark4": ["#7c6f64", 243, "DarkBlue"]
"  "purple": ["#d3869b", 175, "LightBlue"]
"  "blue": ["#83a598", 109, "LightBlue"]
"  "grey": ["#928374", 245, "DarkMagenta"]
"  "light0": ["#fdf4c1", 229, "DarkCyan"]
"  "light1": ["#ebdbb2", 223, "LightGrey"]
"  "light2": ["#d5c4a1", 250, "DarkGrey"]
"  "light3": ["#bdae93", 248, "LightRed"]

if !exists('&t_Co')
" FIXME: Do something?
endif

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'gruvbox_dark'

if !has('gui_running') && get(g:,'gruvbox_dark_transp_bg', 0)
  hi Normal ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
  hi Normal ctermfg=223 ctermbg=235 guifg=#ebdbb2 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
endif

hi ColorColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link CursorColumn CursorLine
hi CursorLine ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi CursorLineNr ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi DiffAdd ctermfg=142 ctermbg=235 guifg=#b8bb26 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffChange ctermfg=108 ctermbg=235 guifg=#8ec07c guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffDelete ctermfg=167 ctermbg=235 guifg=#fb4934 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffText ctermfg=214 ctermbg=235 guifg=#fabd2f guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Directory ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi EndOfBuffer ctermfg=235 ctermbg=NONE guifg=#282828 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=167 ctermbg=235 guifg=#fb4934 guibg=#282828 guisp=NONE cterm=NONE,bold,inverse gui=NONE,bold,inverse
hi ErrorMsg ctermfg=235 ctermbg=167 guifg=#282828 guibg=#fb4934 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi FoldColumn ctermfg=245 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Folded ctermfg=245 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE,italic gui=NONE,italic
hi IncSearch ctermfg=208 ctermbg=235 guifg=#fe8019 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi LineNr ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=NONE ctermbg=241 guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi ModeMsg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi MoreMsg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi NonText ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Pmenu ctermfg=223 ctermbg=239 guifg=#ebdbb2 guibg=#504945 guisp=NONE cterm=NONE gui=NONE
hi PmenuSbar ctermfg=NONE ctermbg=239 guifg=NONE guibg=#504945 guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermfg=239 ctermbg=109 guifg=#504945 guibg=#83a598 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi PmenuThumb ctermfg=NONE ctermbg=243 guifg=NONE guibg=#7c6f64 guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi! link QuickFixLine Search
hi Search ctermfg=214 ctermbg=235 guifg=#fabd2f guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi SignColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi SpecialKey ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#83a598 cterm=NONE,underline gui=NONE,undercurl
hi SpellCap ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
hi SpellLocal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#8ec07c cterm=NONE,underline gui=NONE,undercurl
hi SpellRare ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,undercurl
hi StatusLine ctermfg=239 ctermbg=223 guifg=#504945 guibg=#ebdbb2 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi StatusLineNC ctermfg=237 ctermbg=246 guifg=#3c3836 guibg=#a89984 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link TabLine TabLineFill
hi TabLineFill ctermfg=243 ctermbg=237 guifg=#7c6f64 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi TabLineSel ctermfg=142 ctermbg=237 guifg=#b8bb26 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Title ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi VertSplit ctermfg=241 ctermbg=235 guifg=#665c54 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
hi Visual ctermfg=NONE ctermbg=241 guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE gui=NONE
hi! link VisualNOS Visual
hi WarningMsg ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi WildMenu ctermfg=109 ctermbg=239 guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Boolean ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Character ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Comment ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi Constant ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Debug ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Delimiter ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Float ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Function ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Identifier ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Ignore ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Include ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Keyword ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Label ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Number ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Operator Normal
hi PreProc ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Special ctermfg=208 ctermbg=237 guifg=#fe8019 guibg=#3c3836 guisp=NONE cterm=NONE,italic gui=NONE,italic
hi SpecialChar ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpecialComment ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Statement ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StorageClass ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi String ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Structure ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Todo ctermfg=223 ctermbg=235 guifg=#ebdbb2 guibg=#282828 guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi Type ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Underlined ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link lCursor Cursor
hi CursorIM ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi vimCommentTitle ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi vimMapModKey ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link vimMapMod vimMapModKey
hi vimBracket ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimNotation ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link gitcommitComment Comment
