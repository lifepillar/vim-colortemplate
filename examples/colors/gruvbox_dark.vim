" Name:         Gruvbox Dark
" Description:  Retro groove color scheme
" Author:       morhetz <morhetz@gmail.com>
" Maintainer:   Lifepillar <lifepillar@lifepillar.me>
" Website:      https://github.com/morhetz/gruvbox/
" License:      Vim License (see `:help license`)
" Last Updated: Sun Oct  1 10:51:41 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < 256)
  echohl Error
  echomsg 'Gruvbox Dark: There are not enough colors.'
  echohl None
  finish
endif

set background=dark

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'gruvbox_dark'

if !has('gui_running') && get(g:, 'gruvbox_dark_transp_bg', 0)
hi Normal ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CursorLineNr ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi DiffAdd ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffChange ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffDelete ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffText ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Error ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
hi FoldColumn ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi IncSearch ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Search ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi SignColumn ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi VertSplit ctermfg=241 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,bold,inverse gui=NONE,bold,inverse
hi Todo ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi htmlBold ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi htmlBoldUnderline ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
hi htmlBoldItalic ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi htmlBoldUnderlineItalic ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,bold,underline,italic gui=NONE,bold,underline,italic
hi htmlUnderline ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi htmlUnderlineItalic ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,underline,italic gui=NONE,underline,italic
hi htmlItalic ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
else
hi Normal ctermfg=223 ctermbg=235 guifg=#ebdbb2 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
hi CursorLineNr ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi DiffAdd ctermfg=142 ctermbg=bg guifg=#b8bb26 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffChange ctermfg=108 ctermbg=bg guifg=#8ec07c guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffDelete ctermfg=167 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffText ctermfg=214 ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Error ctermfg=167 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
hi FoldColumn ctermfg=245 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi IncSearch ctermfg=208 ctermbg=bg guifg=#fe8019 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Search ctermfg=214 ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi SignColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi VertSplit ctermfg=241 ctermbg=235 guifg=#665c54 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=167 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,bold,inverse gui=NONE,bold,inverse
hi Todo ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi htmlBold ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold gui=NONE,bold
hi htmlBoldUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
hi htmlBoldItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi htmlBoldUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,underline,italic gui=NONE,bold,underline,italic
hi htmlUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,underline gui=NONE,underline
hi htmlUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,underline,italic gui=NONE,underline,italic
hi htmlItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic gui=NONE,italic
endif
hi ColorColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link CursorColumn CursorLine
hi CursorLine ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi Directory ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi EndOfBuffer ctermfg=235 ctermbg=NONE guifg=#282828 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi ErrorMsg ctermfg=235 ctermbg=167 guifg=#282828 guibg=#fb4934 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Folded ctermfg=245 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE,italic gui=NONE,italic
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
hi Visual ctermfg=NONE ctermbg=241 guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE gui=NONE
hi! link VisualNOS Visual
hi WarningMsg ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi WildMenu ctermfg=109 ctermbg=239 guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Boolean ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Character ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Comment ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi Conditional ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Constant ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Define ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Debug ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Delimiter ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Exception ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Float ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Function ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Identifier ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Ignore ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Include ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Keyword ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Label ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Macro ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Number ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Operator Normal
hi PreCondit ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi PreProc ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Repeat ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Special ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi SpecialChar ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpecialComment ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Statement ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StorageClass ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi String ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Structure ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Tag Special
hi Type ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Typedef ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Underlined ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link lCursor Cursor
hi CursorIM ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link iCursor Cursor
hi! link vCursor Cursor
hi NormalMode ctermfg=246 ctermbg=235 guifg=#a89984 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi InsertMode ctermfg=109 ctermbg=235 guifg=#83a598 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi ReplaceMode ctermfg=108 ctermbg=235 guifg=#8ec07c guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi VisualMode ctermfg=208 ctermbg=235 guifg=#fe8019 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi CommandMode ctermfg=175 ctermbg=235 guifg=#d3869b guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Warnings ctermfg=208 ctermbg=235 guifg=#fe8019 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link EasyMotionTarget Search
hi! link EasyMotionShade Comment
hi GitGutterAdd ctermfg=142 ctermbg=237 guifg=#b8bb26 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi GitGutterChange ctermfg=108 ctermbg=237 guifg=#8ec07c guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi GitGutterDelete ctermfg=167 ctermbg=237 guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi GitGutterChangeDelete ctermfg=108 ctermbg=237 guifg=#8ec07c guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi gitcommitSelectedFile ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi gitcommitDiscardedFile ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SignifySignAdd ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SignifySignChange ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SignifySignDelete ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SyntasticError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
hi SyntasticWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fabd2f cterm=NONE,underline gui=NONE,undercurl
hi SyntasticErrorSign ctermfg=167 ctermbg=237 guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi SyntasticWarningSign ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi SignatureMarkText ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi SignatureMarkerText ctermfg=175 ctermbg=237 guifg=#d3869b guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLl ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLu ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLo ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLm ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi CtrlPMatch ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPNoEntries ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPPrtBase ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPPrtCursor ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPLinePre ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPMode1 ctermfg=109 ctermbg=239 guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi CtrlPMode2 ctermfg=235 ctermbg=109 guifg=#282828 guibg=#83a598 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi CtrlPStats ctermfg=246 ctermbg=239 guifg=#a89984 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi StartifyBracket ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyFile ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyNumber ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyPath ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifySlash ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifySection ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifySpecial ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyHeader ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyFooter ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi BufTabLineCurrent ctermfg=235 ctermbg=246 guifg=#282828 guibg=#a89984 guisp=NONE cterm=NONE gui=NONE
hi BufTabLineActive ctermfg=246 ctermbg=239 guifg=#a89984 guibg=#504945 guisp=NONE cterm=NONE gui=NONE
hi BufTabLineHidden ctermfg=243 ctermbg=237 guifg=#7c6f64 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi BufTabLineFill ctermfg=235 ctermbg=235 guifg=#282828 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
hi ALEError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
hi ALEWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
hi ALEInfo ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#83a598 cterm=NONE,underline gui=NONE,undercurl
hi ALEErrorSign ctermfg=167 ctermbg=237 guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi ALEWarningSign ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi ALEInfoSign ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
hi DirvishPathTail ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi DirvishArg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwDir ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwClassify ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwLink ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwSymLink ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwExe ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwComment ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwList ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwHelpCmd ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwCmdSep ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwVersion ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeDir ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeDirSlash ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeOpenable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeClosable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeFile ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeExecFile ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeUp ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeCWD ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeHelp ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeToggleOn ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeToggleOff ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi multiple_cursors_cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi multiple_cursors_visual ctermfg=NONE ctermbg=239 guifg=NONE guibg=#504945 guisp=NONE cterm=NONE gui=NONE
hi diffAdded ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffRemoved ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffChanged ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffFile ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffNewFile ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffLine ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlEndTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlTagName ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi htmlArg ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlScriptTag ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlTagN ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlSpecialTagName ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi htmlLink ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi htmlSpecialChar ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEndTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlTagName ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEqual ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi docbkKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi xmlDocTypeDecl ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlDocTypeKeyword ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlCdataStart ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlCdataCdata ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdFunction ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdTagName ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlAttrib ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlProcessingDelim ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdParamEntityPunct ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdParamEntityDPunct ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlAttribPunct ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEntity ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEntityPunct ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimCommentTitle ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi vimNotation ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimBracket ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimMapModKey ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimFuncSID ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimSetSep ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimSep ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimContinue ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureKeyword ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureCond ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureSpecial ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureDefine ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureFunc ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRepeat ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureCharacter ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureStringEscape ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureException ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRegexp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRegexpEscape ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRegexpCharClass ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi! link clojureRegexpMod clojureRegexpCharClass
hi! link clojureRegexpQuantifier clojureRegexpCharClass
hi clojureParen ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureAnonArg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureVariable ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureMacro ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureMeta ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureDeref ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureQuote ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureUnquote ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cOperator ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cStructure ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBuiltin ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBuiltinObj ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBuiltinFunc ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonFunction ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonDecorator ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonInclude ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonImport ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonRun ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonCoding ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonOperator ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonException ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonExceptions ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBoolean ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonDot ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonConditional ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonRepeat ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonDottedName ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi cssBraces ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFunctionName ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssIdentifier ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssClassName ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssColor ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssSelectorOp ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssSelectorOp2 ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssImportant ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssVendor ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTextProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssAnimationProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssUIProp ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTransformProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTransitionProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssPrintProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssPositioningProp ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssBoxProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFontDescriptorProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFlexibleBoxProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssBorderOutlineProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssBackgroundProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssMarginProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssListProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTableProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFontProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssPaddingProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssDimensionProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssRenderProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssColorProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssGeneratedContentProp ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptBraces ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptFunction ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptIdentifier ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptMember ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptNumber ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptNull ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptParens ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptImport ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptExport ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassExtends ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDefault ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassName ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassSuperName ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptGlobal ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptEndColons ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptFuncArg ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptGlobalMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptNodeGlobal ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMWindowProp ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptArrayMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptArrayStaticMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptCacheMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDateMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptMathStaticMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptURLUtilsProp ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMNavigatorProp ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMDocMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMDocProp ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMLocationMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMWindowMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptStringMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptVariable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptIdentifier ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassSuper ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptFuncKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptAsyncFunc ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassStatic ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptOperator ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptForOperator ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptYield ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptExceptions ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptMessage ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptTemplateSB ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptTemplateSubstitution ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptLabel ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptObjectLabel ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptPropertyName ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptLogicSymbols ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptArrowFunc ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocParamName ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocTags ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocNotation ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocParamType ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocNamedParamType ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBrackets ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMElemAttrs ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMEventMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMNodeMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMStorageMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptHeadersMethod ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptAsyncFuncKeyword ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptAwaitFuncKeyword ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsClassKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsExtendsKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsExportDefault ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsTemplateBraces ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsGlobalNodeObjects ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsGlobalObjects ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsFunction ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsFuncParens ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsParens ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsNull ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsUndefined ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsClassDefinition ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptReserved ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptLabel ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptFuncKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptIdentifier ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptBraces ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptEndColons ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptDOMObjects ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptAjaxMethods ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptLogicSymbols ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link typeScriptDocSeeTag Comment
hi! link typeScriptDocParam Comment
hi! link typeScriptDocTags vimCommentTitle
hi typeScriptGlobalObjects ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptParens ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptOpSymbols ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptHtmlElemProperties ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptNull ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptInterpolationDelimiter ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptModuleKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptModuleName ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptWhere ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptDelimiter ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptType ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptImportKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptHidingKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptAsKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptStructure ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptOperator ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptTypeVar ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptConstructor ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptFunction ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptConditional ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptBacktick ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeExtendedOp ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeSpecialOp ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeCurly ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeParen ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeBracket ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi rubyStringDelimiter ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi rubyInterpolationDelimiter ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi objcTypeModifier ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi objcDirective ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goDirective ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goConstants ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goDeclaration ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goDeclType ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goBuiltins ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi luaIn ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi luaFunction ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi luaTable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonSpecialOp ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonExtendedOp ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonFunction ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonObject ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaAnnotation ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaDocTags ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link javaCommentTitle vimCommentTitle
hi javaParen ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen1 ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen2 ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen3 ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen4 ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen5 ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaOperator ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaVarArg ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link elixirDocString Comment
hi elixirStringDelimiter ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi elixirInterpolationDelimiter ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi elixirModuleDeclaration ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaNameDefinition ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaCaseFollowing ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaCapitalWord ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaTypeExtension ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaKeyword ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaKeywordModifier ctermfg=167 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaSpecial ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaOperator ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaTypeDeclaration ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaTypeTypePostDeclaration ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaInstanceDeclaration ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaInterpolation ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownItalic ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi markdownH1 ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH2 ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH3 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH4 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH5 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownH6 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownCode ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownCodeBlock ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownCodeDelimiter ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownBlockquote ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownListMarker ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownOrderedListMarker ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownRule ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownHeadingRule ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownUrlDelimiter ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownLinkDelimiter ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownLinkTextDelimiter ctermfg=248 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownHeadingDelimiter ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownUrl ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownUrlTitleDelimiter ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownLinkText ctermfg=245 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link markdownIdDeclaration markdownLinkText
hi haskellType ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellIdentifier ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellSeparator ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDelimiter ctermfg=246 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellOperators ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellBacktick ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellStatement ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellConditional ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellLet ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDefault ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellWhere ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellBottom ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellBlockKeywords ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellImportKeywords ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDeclKeyword ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDeriving ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellAssocType ctermfg=108 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellNumber ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellPragma ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellString ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellChar ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonKeyword ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonQuote ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonBraces ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonString ctermfg=223 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE

" Background: dark
" Color: dark0             rgb(40,  40,  40)     235         Black
" Color: dark1             rgb(60,  56,  54)     237       DarkRed
" Color: dark2             rgb(80,  73,  69)     239     DarkGreen
" Color: dark3             rgb(102, 92,  84)     241    DarkYellow
" Color: dark4             rgb(124, 111, 100)    243      DarkBlue
" Color: orange            rgb(254, 128, 25)     208   DarkMagenta
" Color: light3            rgb(189, 174, 147)    248      DarkCyan
" Color: light4            rgb(168, 153, 132)    246     LightGrey
" Color: grey              rgb(146, 131, 116)    245      DarkGrey
" Color: red               rgb(251, 73,  52)     167      LightRed
" Color: green             rgb(184, 187, 38)     142    LightGreen
" Color: yellow            rgb(250, 189, 47)     214   LightYellow
" Color: blue              rgb(131, 165, 152)    109     LightBlue
" Color: purple            rgb(211, 134, 155)    175  LightMagenta
" Color: aqua              rgb(142, 192, 124)    108     LightCyan
" Color: light1            rgb(235, 219, 178)    223         White
" Normal                           light1 dark0
" ColorColumn                      none   dark1
" Conceal                          blue   none
" Cursor                           none   none    inverse
" CursorColumn                  -> CursorLine
" CursorLine                       none   dark1
" CursorLineNr                     yellow dark1/none
" DiffAdd                          green  bg      inverse
" DiffChange                       aqua   bg      inverse
" DiffDelete                       red    bg      inverse
" DiffText                         yellow bg      inverse
" Directory                        green  none    bold
" EndOfBuffer                      dark0  none
" Error                            red    bg      bold,reverse
" ErrorMsg                         dark0  red     bold
" FoldColumn                       grey   dark1/none
" Folded                           grey   dark1   italic
" IncSearch                        orange bg      inverse
" LineNr                           dark4  none
" MatchParen                       none   dark3   bold
" ModeMsg                          yellow none    bold
" MoreMsg                          yellow none    bold
" NonText                          dark2  none
" Pmenu                            light1 dark2
" PmenuSbar                        none   dark2
" PmenuSel                         dark2  blue    bold
" PmenuThumb                       none   dark4
" Question                         orange none    bold
" QuickFixLine                  -> Search
" Search                           yellow bg      inverse
" SignColumn                       none   dark1/none
" SpecialKey                       dark2  none
" SpellBad                         none   none    t=underline g=undercurl s=blue
" SpellCap                         none   none    t=underline g=undercurl s=red
" SpellLocal                       none   none    t=underline g=undercurl s=aqua
" SpellRare                        none   none    t=underline g=undercurl s=magenta
" StatusLine                       dark2  light1  inverse
" StatusLineNC                     dark1  light4  inverse
" StatusLineTerm                -> StatusLine
" StatusLineTermNC              -> StatusLineNC
" TabLine                       -> TabLineFill
" TabLineFill                      dark4  dark1
" TabLineSel                       green  dark1
" Title                            green  none    bold
" VertSplit                        dark3  dark0/none
" Visual                           none   dark3
" VisualNOS                     -> Visual
" WarningMsg                       red    none    bold
" WildMenu                         blue   dark2   bold
" Boolean                          purple none
" Character                        purple none
" Comment                          grey   none    italic
" Conditional                      red    none
" Constant                         purple none
" Define                           aqua   none
" Debug                            red    none
" Delimiter                        orange none
" Error                            red    bg      bold,inverse
" Exception                        red    none
" Float                            purple none
" Function                         green  none    bold
" Identifier                       blue   none
" Ignore                           fg     none
" Include                          aqua   none
" Keyword                          red    none
" Label                            red    none
" Macro                            aqua   none
" Number                           purple none
" Operator                      -> Normal
" PreCondit                        aqua   none
" PreProc                          aqua   none
" Repeat                           red    none
" Special                          orange none    italic
" SpecialChar                      red    none
" SpecialComment                   red    none
" Statement                        red    none
" StorageClass                     orange none
" String                           green  none
" Structure                        aqua   none
" Tag                           -> Special
" Todo                             fg     bg      bold,italic
" Type                             yellow none
" Typedef                          yellow none
" Underlined                       blue   none    underline
" lCursor                       -> Cursor
" CursorIM                         none   none    inverse
" iCursor                       -> Cursor
" vCursor                       -> Cursor
" NormalMode                       light4 dark0   inverse
" InsertMode                       blue   dark0   inverse
" ReplaceMode                      aqua   dark0   inverse
" VisualMode                       orange dark0   inverse
" CommandMode                      purple dark0   inverse
" Warnings                         orange dark0   inverse
" EasyMotionTarget              -> Search
" EasyMotionShade               -> Comment
" GitGutterAdd                     green  dark1
" GitGutterChange                  aqua   dark1
" GitGutterDelete                  red    dark1
" GitGutterChangeDelete            aqua   dark1
" gitcommitSelectedFile            green  none
" gitcommitDiscardedFile           red    none
" SignifySignAdd                   green  none
" SignifySignChange                aqua   none
" SignifySignDelete                red    none
" SyntasticError                   none   none    t=underline g=undercurl s=red
" SyntasticWarning                 none   none    t=underline g=undercurl s=yellow
" SyntasticErrorSign               red    dark1
" SyntasticWarningSign             yellow dark1
" SignatureMarkText                blue   dark1
" SignatureMarkerText              purple dark1
" ShowMarksHLl                     blue   dark1
" ShowMarksHLu                     blue   dark1
" ShowMarksHLo                     blue   dark1
" ShowMarksHLm                     blue   dark1
" CtrlPMatch                       yellow none
" CtrlPNoEntries                   red    none
" CtrlPPrtBase                     dark2  none
" CtrlPPrtCursor                   blue   none
" CtrlPLinePre                     dark2  none
" CtrlPMode1                       blue   dark2   bold
" CtrlPMode2                       dark0  blue    bold
" CtrlPStats                       light4 dark2   bold
" StartifyBracket                  light3 none
" StartifyFile                     light1 none
" StartifyNumber                   blue   none
" StartifyPath                     grey   none
" StartifySlash                    grey   none
" StartifySection                  yellow none
" StartifySpecial                  dark2  none
" StartifyHeader                   orange none
" StartifyFooter                   dark2  none
" BufTabLineCurrent                dark0  light4
" BufTabLineActive                 light4 dark2
" BufTabLineHidden                 dark4  dark1
" BufTabLineFill                   dark0  dark0
" ALEError                         none   none    t=underline g=undercurl s=red
" ALEWarning                       none   none    t=underline g=undercurl s=red
" ALEInfo                          none   none    t=underline g=undercurl s=blue
" ALEErrorSign                     red    dark1
" ALEWarningSign                   yellow dark1
" ALEInfoSign                      blue   dark1
" DirvishPathTail                  aqua   none
" DirvishArg                       yellow none
" netrwDir                         aqua   none
" netrwClassify                    aqua   none
" netrwLink                        grey   none
" netrwSymLink                     light1 none
" netrwExe                         yellow none
" netrwComment                     grey   none
" netrwList                        blue   none
" netrwHelpCmd                     aqua   none
" netrwCmdSep                      light3 none
" netrwVersion                     green  none
" NERDTreeDir                      aqua   none
" NERDTreeDirSlash                 aqua   none
" NERDTreeOpenable                 orange none
" NERDTreeClosable                 orange none
" NERDTreeFile                     light1 none
" NERDTreeExecFile                 yellow none
" NERDTreeUp                       grey   none
" NERDTreeCWD                      green  none
" NERDTreeHelp                     light1 none
" NERDTreeToggleOn                 green  none
" NERDTreeToggleOff                red    none
" multiple_cursors_cursor          none   none    inverse
" multiple_cursors_visual          none   dark2
" diffAdded                        green  none
" diffRemoved                      red    none
" diffChanged                      aqua   none
" diffFile                         orange none
" diffNewFile                      yellow none
" diffLine                         blue   none
" htmlTag                          blue   none
" htmlEndTag                       blue   none
" htmlTagName                      aqua   none    bold
" htmlArg                          aqua   none
" htmlScriptTag                    purple none
" htmlTagN                         light1 none
" htmlSpecialTagName               aqua   none    bold
" htmlLink                         light4 none    underline
" htmlSpecialChar                  orange none
" htmlBold                         fg     bg      bold
" htmlBoldUnderline                fg     bg      bold,underline
" htmlBoldItalic                   fg     bg      bold,italic
" htmlBoldUnderlineItalic          fg     bg      bold,underline,italic
" htmlUnderline                    fg     bg      underline
" htmlUnderlineItalic              fg     bg      underline,italic
" htmlItalic                       fg     bg      italic
" xmlTag                           blue   none
" xmlEndTag                        blue   none
" xmlTagName                       blue   none
" xmlEqual                         blue   none
" docbkKeyword                     aqua   none    bold
" xmlDocTypeDecl                   grey   none
" xmlDocTypeKeyword                purple none
" xmlCdataStart                    grey   none
" xmlCdataCdata                    purple none
" dtdFunction                      grey   none
" dtdTagName                       purple none
" xmlAttrib                        aqua   none
" xmlProcessingDelim               grey   none
" dtdParamEntityPunct              grey   none
" dtdParamEntityDPunct             grey   none
" xmlAttribPunct                   grey   none
" xmlEntity                        orange none
" xmlEntityPunct                   orange none
" vimCommentTitle                  light4 none    bold
" vimNotation                      orange none
" vimBracket                       orange none
" vimMapModKey                     orange none
" vimFuncSID                       light3 none
" vimSetSep                        light3 none
" vimSep                           light3 none
" vimContinue                      light3 none
" clojureKeyword                   blue   none
" clojureCond                      orange none
" clojureSpecial                   orange none
" clojureDefine                    orange none
" clojureFunc                      yellow none
" clojureRepeat                    yellow none
" clojureCharacter                 aqua   none
" clojureStringEscape              aqua   none
" clojureException                 red    none
" clojureRegexp                    aqua   none
" clojureRegexpEscape              aqua   none
" clojureRegexpCharClass           light3 none    bold
" clojureRegexpMod              -> clojureRegexpCharClass
" clojureRegexpQuantifier       -> clojureRegexpCharClass
" clojureParen                     light3 none
" clojureAnonArg                   yellow none
" clojureVariable                  blue   none
" clojureMacro                     orange none
" clojureMeta                      yellow none
" clojureDeref                     yellow none
" clojureQuote                     yellow none
" clojureUnquote                   yellow none
" cOperator                        purple none
" cStructure                       orange none
" pythonBuiltin                    orange none
" pythonBuiltinObj                 orange none
" pythonBuiltinFunc                orange none
" pythonFunction                   aqua   none
" pythonDecorator                  red    none
" pythonInclude                    blue   none
" pythonImport                     blue   none
" pythonRun                        blue   none
" pythonCoding                     blue   none
" pythonOperator                   red    none
" pythonException                  red    none
" pythonExceptions                 purple none
" pythonBoolean                    purple none
" pythonDot                        light3 none
" pythonConditional                red    none
" pythonRepeat                     red    none
" pythonDottedName                 green  none    bold
" cssBraces                        blue   none
" cssFunctionName                  yellow none
" cssIdentifier                    orange none
" cssClassName                     green  none
" cssColor                         blue   none
" cssSelectorOp                    blue   none
" cssSelectorOp2                   blue   none
" cssImportant                     green  none
" cssVendor                        light1 none
" cssTextProp                      aqua   none
" cssAnimationProp                 aqua   none
" cssUIProp                        yellow none
" cssTransformProp                 aqua   none
" cssTransitionProp                aqua   none
" cssPrintProp                     aqua   none
" cssPositioningProp               yellow none
" cssBoxProp                       aqua   none
" cssFontDescriptorProp            aqua   none
" cssFlexibleBoxProp               aqua   none
" cssBorderOutlineProp             aqua   none
" cssBackgroundProp                aqua   none
" cssMarginProp                    aqua   none
" cssListProp                      aqua   none
" cssTableProp                     aqua   none
" cssFontProp                      aqua   none
" cssPaddingProp                   aqua   none
" cssDimensionProp                 aqua   none
" cssRenderProp                    aqua   none
" cssColorProp                     aqua   none
" cssGeneratedContentProp          aqua   none
" javaScriptBraces                 light1 none
" javaScriptFunction               aqua   none
" javaScriptIdentifier             red    none
" javaScriptMember                 blue   none
" javaScriptNumber                 purple none
" javaScriptNull                   purple none
" javaScriptParens                 light3 none
" javascriptImport                 aqua   none
" javascriptExport                 aqua   none
" javascriptClassKeyword           aqua   none
" javascriptClassExtends           aqua   none
" javascriptDefault                aqua   none
" javascriptClassName              yellow none
" javascriptClassSuperName         yellow none
" javascriptGlobal                 yellow none
" javascriptEndColons              light1 none
" javascriptFuncArg                light1 none
" javascriptGlobalMethod           light1 none
" javascriptNodeGlobal             light1 none
" javascriptBOMWindowProp          light1 none
" javascriptArrayMethod            light1 none
" javascriptArrayStaticMethod      light1 none
" javascriptCacheMethod            light1 none
" javascriptDateMethod             light1 none
" javascriptMathStaticMethod       light1 none
" javascriptURLUtilsProp           light1 none
" javascriptBOMNavigatorProp       light1 none
" javascriptDOMDocMethod           light1 none
" javascriptDOMDocProp             light1 none
" javascriptBOMLocationMethod      light1 none
" javascriptBOMWindowMethod        light1 none
" javascriptStringMethod           light1 none
" javascriptVariable               orange none
" javascriptIdentifier             orange none
" javascriptClassSuper             orange none
" javascriptFuncKeyword            aqua   none
" javascriptAsyncFunc              aqua   none
" javascriptClassStatic            orange none
" javascriptOperator               red    none
" javascriptForOperator            red    none
" javascriptYield                  red    none
" javascriptExceptions             red    none
" javascriptMessage                red    none
" javascriptTemplateSB             aqua   none
" javascriptTemplateSubstitution   light1 none
" javascriptLabel                  light1 none
" javascriptObjectLabel            light1 none
" javascriptPropertyName           light1 none
" javascriptLogicSymbols           light1 none
" javascriptArrowFunc              yellow none
" javascriptDocParamName           light4 none
" javascriptDocTags                light4 none
" javascriptDocNotation            light4 none
" javascriptDocParamType           light4 none
" javascriptDocNamedParamType      light4 none
" javascriptBrackets               light1 none
" javascriptDOMElemAttrs           light1 none
" javascriptDOMEventMethod         light1 none
" javascriptDOMNodeMethod          light1 none
" javascriptDOMStorageMethod       light1 none
" javascriptHeadersMethod          light1 none
" javascriptAsyncFuncKeyword       red    none
" javascriptAwaitFuncKeyword       red    none
" jsClassKeyword                   aqua   none
" jsExtendsKeyword                 aqua   none
" jsExportDefault                  aqua   none
" jsTemplateBraces                 aqua   none
" jsGlobalNodeObjects              light1 none
" jsGlobalObjects                  light1 none
" jsFunction                       aqua   none
" jsFuncParens                     light3 none
" jsParens                         light3 none
" jsNull                           purple none
" jsUndefined                      purple none
" jsClassDefinition                yellow none
" typeScriptReserved               aqua   none
" typeScriptLabel                  aqua   none
" typeScriptFuncKeyword            aqua   none
" typeScriptIdentifier             orange none
" typeScriptBraces                 light1 none
" typeScriptEndColons              light1 none
" typeScriptDOMObjects             light1 none
" typeScriptAjaxMethods            light1 none
" typeScriptLogicSymbols           light1 none
" typeScriptDocSeeTag           -> Comment
" typeScriptDocParam            -> Comment
" typeScriptDocTags             -> vimCommentTitle
" typeScriptGlobalObjects          light1 none
" typeScriptParens                 light3 none
" typeScriptOpSymbols              light3 none
" typeScriptHtmlElemProperties     light1 none
" typeScriptNull                   purple none
" typeScriptInterpolationDelimiter aqua   none
" purescriptModuleKeyword          aqua   none
" purescriptModuleName             light1 none
" purescriptWhere                  aqua   none
" purescriptDelimiter              light4 none
" purescriptType                   light1 none
" purescriptImportKeyword          aqua   none
" purescriptHidingKeyword          aqua   none
" purescriptAsKeyword              aqua   none
" purescriptStructure              aqua   none
" purescriptOperator               blue   none
" purescriptTypeVar                light1 none
" purescriptConstructor            light1 none
" purescriptFunction               light1 none
" purescriptConditional            orange none
" purescriptBacktick               orange none
" coffeeExtendedOp                 light3 none
" coffeeSpecialOp                  light3 none
" coffeeCurly                      orange none
" coffeeParen                      light3 none
" coffeeBracket                    orange none
" rubyStringDelimiter              green  none
" rubyInterpolationDelimiter       aqua   none
" objcTypeModifier                 red    none
" objcDirective                    blue   none
" goDirective                      aqua   none
" goConstants                      purple none
" goDeclaration                    red    none
" goDeclType                       blue   none
" goBuiltins                       orange none
" luaIn                            red    none
" luaFunction                      aqua   none
" luaTable                         orange none
" moonSpecialOp                    light3 none
" moonExtendedOp                   light3 none
" moonFunction                     light3 none
" moonObject                       yellow none
" javaAnnotation                   blue   none
" javaDocTags                      aqua   none
" javaCommentTitle              -> vimCommentTitle
" javaParen                        light3 none
" javaParen1                       light3 none
" javaParen2                       light3 none
" javaParen3                       light3 none
" javaParen4                       light3 none
" javaParen5                       light3 none
" javaOperator                     orange none
" javaVarArg                       green  none
" elixirDocString               -> Comment
" elixirStringDelimiter            green  none
" elixirInterpolationDelimiter     aqua   none
" elixirModuleDeclaration          yellow none
" scalaNameDefinition              light1 none
" scalaCaseFollowing               light1 none
" scalaCapitalWord                 light1 none
" scalaTypeExtension               light1 none
" scalaKeyword                     red    none
" scalaKeywordModifier             red    none
" scalaSpecial                     aqua   none
" scalaOperator                    light1 none
" scalaTypeDeclaration             yellow none
" scalaTypeTypePostDeclaration     yellow none
" scalaInstanceDeclaration         light1 none
" scalaInterpolation               aqua   none
" markdownItalic                   light3 none    italic
" markdownH1                       green  none    bold
" markdownH2                       green  none    bold
" markdownH3                       yellow none    bold
" markdownH4                       yellow none    bold
" markdownH5                       yellow none
" markdownH6                       yellow none
" markdownCode                     aqua   none
" markdownCodeBlock                aqua   none
" markdownCodeDelimiter            aqua   none
" markdownBlockquote               grey   none
" markdownListMarker               grey   none
" markdownOrderedListMarker        grey   none
" markdownRule                     grey   none
" markdownHeadingRule              grey   none
" markdownUrlDelimiter             light3 none
" markdownLinkDelimiter            light3 none
" markdownLinkTextDelimiter        light3 none
" markdownHeadingDelimiter         orange none
" markdownUrl                      purple none
" markdownUrlTitleDelimiter        green  none
" markdownLinkText                 grey   none    underline
" markdownIdDeclaration         -> markdownLinkText
" haskellType                      light1 none
" haskellIdentifier                light1 none
" haskellSeparator                 light1 none
" haskellDelimiter                 light4 none
" haskellOperators                 blue   none
" haskellBacktick                  orange none
" haskellStatement                 orange none
" haskellConditional               orange none
" haskellLet                       aqua   none
" haskellDefault                   aqua   none
" haskellWhere                     aqua   none
" haskellBottom                    aqua   none
" haskellBlockKeywords             aqua   none
" haskellImportKeywords            aqua   none
" haskellDeclKeyword               aqua   none
" haskellDeriving                  aqua   none
" haskellAssocType                 aqua   none
" haskellNumber                    purple none
" haskellPragma                    purple none
" haskellString                    green  none
" haskellChar                      green  none
" jsonKeyword                      green  none
" jsonQuote                        green  none
" jsonBraces                       light1 none
" jsonString                       light1 none
