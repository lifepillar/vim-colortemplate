" Name:         Gruvbox
" Description:  Retro groove color scheme
" Author:       morhetz <morhetz@gmail.com>
" Maintainer:   Lifepillar <lifepillar@lifepillar.me>
" Website:      https://github.com/morhetz/gruvbox/
" License:      Vim License (see `:help license`)
" Last Updated: Tue Nov 21 19:58:46 2017

if !(has('termguicolors') && &termguicolors) && !has('gui_running')
      \ && (!exists('&t_Co') || &t_Co < (get(g:, 'gruvbox_use16', 0) ? 16 : 256))
  echoerr '[Gruvbox] There are not enough colors.'
  finish
endif

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'gruvbox'

" 256-color variant
if !get(g:, 'gruvbox_use16', 0)
  if &background ==# 'dark'
    " Color similarity table (dark background)
    "  dark0: GUI=#282828/rgb( 40, 40, 40)  Term=235 #262626/rgb( 38, 38, 38)  [delta=0.631758]
    "  dark1: GUI=#3c3836/rgb( 60, 56, 54)  Term=237 #3a3a3a/rgb( 58, 58, 58)  [delta=2.591691]
    "  green: GUI=#b8bb26/rgb(184,187, 38)  Term=142 #afaf00/rgb(175,175,  0)  [delta=3.417395]
    " orange: GUI=#fe8019/rgb(254,128, 25)  Term=208 #ff8700/rgb(255,135,  0)  [delta=3.424299]
    "  dark2: GUI=#504945/rgb( 80, 73, 69)  Term=239 #4e4e4e/rgb( 78, 78, 78)  [delta=4.437203]
    " yellow: GUI=#fabd2f/rgb(250,189, 47)  Term=214 #ffaf00/rgb(255,175,  0)  [delta=5.124662]
    " purple: GUI=#d3869b/rgb(211,134,155)  Term=175 #d787af/rgb(215,135,175)  [delta=5.579873]
    "   aqua: GUI=#8ec07c/rgb(142,192,124)  Term=107 #87af5f/rgb(135,175, 95)  [delta=5.816248]
    "   blue: GUI=#83a598/rgb(131,165,152)  Term=109 #87afaf/rgb(135,175,175)  [delta=6.121678]
    "  dark3: GUI=#665c54/rgb(102, 92, 84)  Term= 59 #5f5f5f/rgb( 95, 95, 95)  [delta=6.186264]
    " light1: GUI=#ebdbb2/rgb(235,219,178)  Term=187 #d7d7af/rgb(215,215,175)  [delta=6.290489]
    "  dark4: GUI=#7c6f64/rgb(124,111,100)  Term=243 #767676/rgb(118,118,118)  [delta=7.889685]
    "    red: GUI=#fb4934/rgb(251, 73, 52)  Term=203 #ff5f5f/rgb(255, 95, 95)  [delta=8.215867]
    " light3: GUI=#bdae93/rgb(189,174,147)  Term=144 #afaf87/rgb(175,175,135)  [delta=8.449971]
    "   grey: GUI=#928374/rgb(146,131,116)  Term=102 #878787/rgb(135,135,135)  [delta=8.970802]
    " light4: GUI=#a89984/rgb(168,153,132)  Term=137 #af875f/rgb(175,135, 95)  [delta=10.269702]
    if !has('gui_running') && get(g:, 'gruvbox_transp_bg', 0)
      hi Normal ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
      hi CursorLineNr ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
      hi FoldColumn ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
      hi SignColumn ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
      hi VertSplit ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    else
      hi Normal ctermfg=187 ctermbg=235 guifg=#ebdbb2 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
      hi CursorLineNr ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
      hi FoldColumn ctermfg=102 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
      hi SignColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
      hi VertSplit ctermfg=59 ctermbg=235 guifg=#665c54 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
    endif
    hi ColorColumn ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi Conceal ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi! link CursorColumn CursorLine
    hi CursorLine ctermfg=NONE ctermbg=237 guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi DiffAdd ctermfg=142 ctermbg=bg guifg=#b8bb26 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi DiffChange ctermfg=107 ctermbg=bg guifg=#8ec07c guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi DiffDelete ctermfg=203 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi DiffText ctermfg=214 ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi Directory ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi EndOfBuffer ctermfg=235 ctermbg=NONE guifg=#282828 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Error ctermfg=203 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
    hi ErrorMsg ctermfg=235 ctermbg=203 guifg=#282828 guibg=#fb4934 guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi Folded ctermfg=102 ctermbg=237 guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE,italic gui=NONE,italic
    hi IncSearch ctermfg=208 ctermbg=bg guifg=#fe8019 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi LineNr ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi MatchParen ctermfg=NONE ctermbg=59 guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi ModeMsg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi MoreMsg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi NonText ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Pmenu ctermfg=187 ctermbg=239 guifg=#ebdbb2 guibg=#504945 guisp=NONE cterm=NONE gui=NONE
    hi PmenuSbar ctermfg=NONE ctermbg=239 guifg=NONE guibg=#504945 guisp=NONE cterm=NONE gui=NONE
    hi PmenuSel ctermfg=239 ctermbg=109 guifg=#504945 guibg=#83a598 guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi PmenuThumb ctermfg=NONE ctermbg=243 guifg=NONE guibg=#7c6f64 guisp=NONE cterm=NONE gui=NONE
    hi Question ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi! link QuickFixLine Search
    hi Search ctermfg=214 ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi SpecialKey ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SpellBad ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#83a598 cterm=NONE,underline gui=NONE,undercurl
    hi SpellCap ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
    hi SpellLocal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#8ec07c cterm=NONE,underline gui=NONE,undercurl
    hi SpellRare ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#d3869b cterm=NONE,underline gui=NONE,undercurl
    hi StatusLine ctermfg=239 ctermbg=187 guifg=#504945 guibg=#ebdbb2 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi StatusLineNC ctermfg=237 ctermbg=137 guifg=#3c3836 guibg=#a89984 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi! link StatusLineTerm StatusLine
    hi! link StatusLineTermNC StatusLineNC
    hi! link TabLine TabLineFill
    hi TabLineFill ctermfg=243 ctermbg=237 guifg=#7c6f64 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi TabLineSel ctermfg=142 ctermbg=237 guifg=#b8bb26 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi Title ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi Visual ctermfg=NONE ctermbg=59 guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE gui=NONE
    hi! link VisualNOS Visual
    hi WarningMsg ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi WildMenu ctermfg=109 ctermbg=239 guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi Boolean ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Character ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Comment ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
    hi Conditional ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Constant ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Define ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Debug ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Delimiter ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Error ctermfg=203 ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,bold,inverse gui=NONE,bold,inverse
    hi Exception ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Float ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Function ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi Identifier ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Ignore ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Include ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Keyword ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Label ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Macro ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Number ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi! link Operator Normal
    hi PreCondit ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi PreProc ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Repeat ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Special ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
    hi SpecialChar ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SpecialComment ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Statement ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StorageClass ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi String ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Structure ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi! link Tag Special
    hi Todo ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
    hi Type ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Typedef ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi Underlined ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
    hi! link lCursor Cursor
    hi CursorIM ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi! link iCursor Cursor
    hi! link vCursor Cursor
    hi NormalMode ctermfg=137 ctermbg=235 guifg=#a89984 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi InsertMode ctermfg=109 ctermbg=235 guifg=#83a598 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi ReplaceMode ctermfg=107 ctermbg=235 guifg=#8ec07c guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi VisualMode ctermfg=208 ctermbg=235 guifg=#fe8019 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi CommandMode ctermfg=175 ctermbg=235 guifg=#d3869b guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi Warnings ctermfg=208 ctermbg=235 guifg=#fe8019 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi! link EasyMotionTarget Search
    hi! link EasyMotionShade Comment
    hi GitGutterAdd ctermfg=142 ctermbg=237 guifg=#b8bb26 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi GitGutterChange ctermfg=107 ctermbg=237 guifg=#8ec07c guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi GitGutterDelete ctermfg=203 ctermbg=237 guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi GitGutterChangeDelete ctermfg=107 ctermbg=237 guifg=#8ec07c guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi gitcommitSelectedFile ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi gitcommitDiscardedFile ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SignifySignAdd ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SignifySignChange ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SignifySignDelete ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SyntasticError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
    hi SyntasticWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fabd2f cterm=NONE,underline gui=NONE,undercurl
    hi SyntasticErrorSign ctermfg=203 ctermbg=237 guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi SyntasticWarningSign ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi SignatureMarkText ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi SignatureMarkerText ctermfg=175 ctermbg=237 guifg=#d3869b guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi ShowMarksHLl ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi ShowMarksHLu ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi ShowMarksHLo ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi ShowMarksHLm ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi CtrlPMatch ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi CtrlPNoEntries ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi CtrlPPrtBase ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi CtrlPPrtCursor ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi CtrlPLinePre ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi CtrlPMode1 ctermfg=109 ctermbg=239 guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi CtrlPMode2 ctermfg=235 ctermbg=109 guifg=#282828 guibg=#83a598 guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi CtrlPStats ctermfg=137 ctermbg=239 guifg=#a89984 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi StartifyBracket ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifyFile ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifyNumber ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifyPath ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifySlash ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifySection ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifySpecial ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifyHeader ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi StartifyFooter ctermfg=239 ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi BufTabLineCurrent ctermfg=235 ctermbg=137 guifg=#282828 guibg=#a89984 guisp=NONE cterm=NONE gui=NONE
    hi BufTabLineActive ctermfg=137 ctermbg=239 guifg=#a89984 guibg=#504945 guisp=NONE cterm=NONE gui=NONE
    hi BufTabLineHidden ctermfg=243 ctermbg=237 guifg=#7c6f64 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi BufTabLineFill ctermfg=235 ctermbg=235 guifg=#282828 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
    hi ALEError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
    hi ALEWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
    hi ALEInfo ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#83a598 cterm=NONE,underline gui=NONE,undercurl
    hi ALEErrorSign ctermfg=203 ctermbg=237 guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi ALEWarningSign ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi ALEInfoSign ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi DirvishPathTail ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi DirvishArg ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwDir ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwClassify ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwLink ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwSymLink ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwExe ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwComment ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwList ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwHelpCmd ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwCmdSep ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi netrwVersion ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeDir ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeDirSlash ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeOpenable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeClosable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeFile ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeExecFile ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeUp ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeCWD ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeHelp ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeToggleOn ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi NERDTreeToggleOff ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi multiple_cursors_cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
    hi multiple_cursors_visual ctermfg=NONE ctermbg=239 guifg=NONE guibg=#504945 guisp=NONE cterm=NONE gui=NONE
    hi diffAdded ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi diffRemoved ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi diffChanged ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi diffFile ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi diffNewFile ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi diffLine ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi htmlTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi htmlEndTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi htmlTagName ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi htmlArg ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi htmlScriptTag ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi htmlTagN ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi htmlSpecialTagName ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi htmlLink ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
    hi htmlSpecialChar ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi htmlBold ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi htmlBoldUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
    hi htmlBoldItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
    hi htmlBoldUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic,underline gui=NONE,bold,italic,underline
    hi htmlUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,underline gui=NONE,underline
    hi htmlUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic,underline gui=NONE,italic,underline
    hi htmlItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic gui=NONE,italic
    hi xmlTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlEndTag ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlTagName ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlEqual ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi docbkKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi xmlDocTypeDecl ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlDocTypeKeyword ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlCdataStart ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlCdataCdata ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi dtdFunction ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi dtdTagName ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlAttrib ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlProcessingDelim ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi dtdParamEntityPunct ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi dtdParamEntityDPunct ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlAttribPunct ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlEntity ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi xmlEntityPunct ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi vimCommentTitle ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi vimNotation ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi vimBracket ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi vimMapModKey ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi vimFuncSID ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi vimSetSep ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi vimSep ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi vimContinue ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureKeyword ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureCond ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureSpecial ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureDefine ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureFunc ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureRepeat ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureCharacter ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureStringEscape ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureException ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureRegexp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureRegexpEscape ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi clojureRegexpCharClass ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi! link clojureRegexpMod clojureRegexpCharClass
    hi! link clojureRegexpQuantifier clojureRegexpCharClass
    hi clojureParen ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
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
    hi pythonFunction ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonDecorator ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonInclude ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonImport ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonRun ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonCoding ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonOperator ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonException ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonExceptions ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonBoolean ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonDot ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonConditional ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonRepeat ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi pythonDottedName ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi cssBraces ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssFunctionName ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssIdentifier ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssClassName ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssColor ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssSelectorOp ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssSelectorOp2 ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssImportant ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssVendor ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssTextProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssAnimationProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssUIProp ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssTransformProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssTransitionProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssPrintProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssPositioningProp ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssBoxProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssFontDescriptorProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssFlexibleBoxProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssBorderOutlineProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssBackgroundProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssMarginProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssListProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssTableProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssFontProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssPaddingProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssDimensionProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssRenderProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssColorProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi cssGeneratedContentProp ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaScriptBraces ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaScriptFunction ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaScriptIdentifier ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaScriptMember ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaScriptNumber ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaScriptNull ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaScriptParens ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptImport ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptExport ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptClassKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptClassExtends ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDefault ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptClassName ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptClassSuperName ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptGlobal ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptEndColons ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptFuncArg ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptGlobalMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptNodeGlobal ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptBOMWindowProp ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptArrayMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptArrayStaticMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptCacheMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDateMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptMathStaticMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptURLUtilsProp ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptBOMNavigatorProp ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDOMDocMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDOMDocProp ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptBOMLocationMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptBOMWindowMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptStringMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptVariable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptIdentifier ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptClassSuper ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptFuncKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptAsyncFunc ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptClassStatic ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptOperator ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptForOperator ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptYield ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptExceptions ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptMessage ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptTemplateSB ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptTemplateSubstitution ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptLabel ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptObjectLabel ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptPropertyName ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptLogicSymbols ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptArrowFunc ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDocParamName ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDocTags ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDocNotation ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDocParamType ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDocNamedParamType ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptBrackets ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDOMElemAttrs ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDOMEventMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDOMNodeMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptDOMStorageMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptHeadersMethod ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptAsyncFuncKeyword ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javascriptAwaitFuncKeyword ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsClassKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsExtendsKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsExportDefault ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsTemplateBraces ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsGlobalNodeObjects ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsGlobalObjects ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsFunction ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsFuncParens ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsParens ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsNull ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsUndefined ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsClassDefinition ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptReserved ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptLabel ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptFuncKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptIdentifier ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptBraces ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptEndColons ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptDOMObjects ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptAjaxMethods ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptLogicSymbols ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi! link typeScriptDocSeeTag Comment
    hi! link typeScriptDocParam Comment
    hi! link typeScriptDocTags vimCommentTitle
    hi typeScriptGlobalObjects ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptParens ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptOpSymbols ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptHtmlElemProperties ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptNull ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi typeScriptInterpolationDelimiter ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptModuleKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptModuleName ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptWhere ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptDelimiter ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptType ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptImportKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptHidingKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptAsKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptStructure ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptOperator ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptTypeVar ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptConstructor ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptFunction ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptConditional ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi purescriptBacktick ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi coffeeExtendedOp ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi coffeeSpecialOp ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi coffeeCurly ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi coffeeParen ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi coffeeBracket ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi rubyStringDelimiter ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi rubyInterpolationDelimiter ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi objcTypeModifier ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi objcDirective ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi goDirective ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi goConstants ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi goDeclaration ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi goDeclType ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi goBuiltins ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi luaIn ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi luaFunction ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi luaTable ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi moonSpecialOp ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi moonExtendedOp ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi moonFunction ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi moonObject ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaAnnotation ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaDocTags ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi! link javaCommentTitle vimCommentTitle
    hi javaParen ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaParen1 ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaParen2 ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaParen3 ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaParen4 ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaParen5 ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaOperator ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi javaVarArg ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi! link elixirDocString Comment
    hi elixirStringDelimiter ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi elixirInterpolationDelimiter ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi elixirModuleDeclaration ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaNameDefinition ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaCaseFollowing ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaCapitalWord ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaTypeExtension ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaKeyword ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaKeywordModifier ctermfg=203 ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaSpecial ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaOperator ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaTypeDeclaration ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaTypeTypePostDeclaration ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaInstanceDeclaration ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi scalaInterpolation ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownItalic ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
    hi markdownH1 ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi markdownH2 ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi markdownH3 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi markdownH4 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
    hi markdownH5 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownH6 ctermfg=214 ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownCode ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownCodeBlock ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownCodeDelimiter ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownBlockquote ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownListMarker ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownOrderedListMarker ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownRule ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownHeadingRule ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownUrlDelimiter ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownLinkDelimiter ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownLinkTextDelimiter ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownHeadingDelimiter ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownUrl ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownUrlTitleDelimiter ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi markdownLinkText ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
    hi! link markdownIdDeclaration markdownLinkText
    hi haskellType ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellIdentifier ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellSeparator ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellDelimiter ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellOperators ctermfg=109 ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellBacktick ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellStatement ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellConditional ctermfg=208 ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellLet ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellDefault ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellWhere ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellBottom ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellBlockKeywords ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellImportKeywords ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellDeclKeyword ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellDeriving ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellAssocType ctermfg=107 ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellNumber ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellPragma ctermfg=175 ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellString ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi haskellChar ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsonKeyword ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsonQuote ctermfg=142 ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsonBraces ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi jsonString ctermfg=187 ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    finish
  endif

  " Color similarity table (light background)
  "  dark1: GUI=#3c3836/rgb( 60, 56, 54)  Term=237 #3a3a3a/rgb( 58, 58, 58)  [delta=2.591691]
  "    red: GUI=#9e0006/rgb(158,  0,  6)  Term=124 #af0000/rgb(175,  0,  0)  [delta=3.751569]
  " light0: GUI=#fdf4c1/rgb(253,244,193)  Term=230 #ffffd7/rgb(255,255,215)  [delta=4.485567]
  "  dark3: GUI=#665c54/rgb(102, 92, 84)  Term= 59 #5f5f5f/rgb( 95, 95, 95)  [delta=6.186264]
  " light1: GUI=#ebdbb2/rgb(235,219,178)  Term=187 #d7d7af/rgb(215,215,175)  [delta=6.290489]
  "   aqua: GUI=#427b58/rgb( 66,123, 88)  Term= 29 #00875f/rgb(  0,135, 95)  [delta=6.512362]
  "  green: GUI=#79740e/rgb(121,116, 14)  Term=100 #878700/rgb(135,135,  0)  [delta=7.387225]
  "  dark4: GUI=#7c6f64/rgb(124,111,100)  Term=243 #767676/rgb(118,118,118)  [delta=7.889685]
  " yellow: GUI=#b57614/rgb(181,118, 20)  Term=172 #d78700/rgb(215,135,  0)  [delta=8.074928]
  " orange: GUI=#af3a03/rgb(175, 58,  3)  Term=124 #af0000/rgb(175,  0,  0)  [delta=8.117734]
  " light2: GUI=#d5c4a1/rgb(213,196,161)  Term=187 #d7d7af/rgb(215,215,175)  [delta=8.170537]
  " light3: GUI=#bdae93/rgb(189,174,147)  Term=144 #afaf87/rgb(175,175,135)  [delta=8.449971]
  " purple: GUI=#8f3f71/rgb(143, 63,113)  Term=126 #af0087/rgb(175,  0,135)  [delta=8.757905]
  "   grey: GUI=#928374/rgb(146,131,116)  Term=102 #878787/rgb(135,135,135)  [delta=8.970802]
  "   blue: GUI=#076678/rgb(  7,102,120)  Term= 23 #005f5f/rgb(  0, 95, 95)  [delta=9.442168]
  " light4: GUI=#a89984/rgb(168,153,132)  Term=137 #af875f/rgb(175,135, 95)  [delta=10.269702]
  if !has('gui_running') && get(g:, 'gruvbox_transp_bg', 0)
    hi Normal ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi CursorLineNr ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi FoldColumn ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SignColumn ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi VertSplit ctermfg=144 ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  else
    hi Normal ctermfg=237 ctermbg=230 guifg=#3c3836 guibg=#fdf4c1 guisp=NONE cterm=NONE gui=NONE
    hi CursorLineNr ctermfg=172 ctermbg=187 guifg=#b57614 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
    hi FoldColumn ctermfg=102 ctermbg=187 guifg=#928374 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
    hi SignColumn ctermfg=NONE ctermbg=187 guifg=NONE guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
    hi VertSplit ctermfg=144 ctermbg=230 guifg=#bdae93 guibg=#fdf4c1 guisp=NONE cterm=NONE gui=NONE
  endif
  hi ColorColumn ctermfg=NONE ctermbg=187 guifg=NONE guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi Conceal ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link CursorColumn CursorLine
  hi CursorLine ctermfg=NONE ctermbg=187 guifg=NONE guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi DiffAdd ctermfg=100 ctermbg=bg guifg=#79740e guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi DiffChange ctermfg=29 ctermbg=bg guifg=#427b58 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi DiffDelete ctermfg=124 ctermbg=bg guifg=#9e0006 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi DiffText ctermfg=172 ctermbg=bg guifg=#b57614 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi Directory ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi EndOfBuffer ctermfg=230 ctermbg=NONE guifg=#fdf4c1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Error ctermfg=124 ctermbg=bg guifg=#9e0006 guibg=bg guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
  hi ErrorMsg ctermfg=230 ctermbg=124 guifg=#fdf4c1 guibg=#9e0006 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Folded ctermfg=102 ctermbg=187 guifg=#928374 guibg=#ebdbb2 guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi IncSearch ctermfg=124 ctermbg=bg guifg=#af3a03 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi LineNr ctermfg=137 ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi MatchParen ctermfg=NONE ctermbg=144 guifg=NONE guibg=#bdae93 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi ModeMsg ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi MoreMsg ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi NonText ctermfg=187 ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Pmenu ctermfg=237 ctermbg=187 guifg=#3c3836 guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=187 guifg=NONE guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
  hi PmenuSel ctermfg=187 ctermbg=23 guifg=#d5c4a1 guibg=#076678 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi PmenuThumb ctermfg=NONE ctermbg=137 guifg=NONE guibg=#a89984 guisp=NONE cterm=NONE gui=NONE
  hi Question ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi! link QuickFixLine Search
  hi Search ctermfg=172 ctermbg=bg guifg=#b57614 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi SpecialKey ctermfg=187 ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SpellBad ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#076678 cterm=NONE,underline gui=NONE,undercurl
  hi SpellCap ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
  hi SpellLocal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#427b58 cterm=NONE,underline gui=NONE,undercurl
  hi SpellRare ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#8f3f71 cterm=NONE,underline gui=NONE,undercurl
  hi StatusLine ctermfg=187 ctermbg=237 guifg=#d5c4a1 guibg=#3c3836 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi StatusLineNC ctermfg=187 ctermbg=243 guifg=#ebdbb2 guibg=#7c6f64 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link StatusLineTerm StatusLine
  hi! link StatusLineTermNC StatusLineNC
  hi! link TabLine TabLineFill
  hi TabLineFill ctermfg=137 ctermbg=187 guifg=#a89984 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi TabLineSel ctermfg=100 ctermbg=187 guifg=#79740e guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi Title ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Visual ctermfg=NONE ctermbg=144 guifg=NONE guibg=#bdae93 guisp=NONE cterm=NONE gui=NONE
  hi! link VisualNOS Visual
  hi WarningMsg ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi WildMenu ctermfg=23 ctermbg=187 guifg=#076678 guibg=#d5c4a1 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Boolean ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Character ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Comment ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi Conditional ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Constant ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Define ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Debug ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Delimiter ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Error ctermfg=124 ctermbg=bg guifg=#9e0006 guibg=bg guisp=NONE cterm=NONE,bold,inverse gui=NONE,bold,inverse
  hi Exception ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Float ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Function ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Identifier ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Ignore ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Include ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Keyword ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Label ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Macro ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Number ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Operator Normal
  hi PreCondit ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi PreProc ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Repeat ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Special ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi SpecialChar ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SpecialComment ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Statement ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StorageClass ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi String ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Structure ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Tag Special
  hi Todo ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
  hi Type ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Typedef ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Underlined ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi! link lCursor Cursor
  hi CursorIM ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link iCursor Cursor
  hi! link vCursor Cursor
  hi NormalMode ctermfg=243 ctermbg=230 guifg=#7c6f64 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi InsertMode ctermfg=23 ctermbg=230 guifg=#076678 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi ReplaceMode ctermfg=29 ctermbg=230 guifg=#427b58 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi VisualMode ctermfg=124 ctermbg=230 guifg=#af3a03 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi CommandMode ctermfg=126 ctermbg=230 guifg=#8f3f71 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi Warnings ctermfg=124 ctermbg=230 guifg=#af3a03 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link EasyMotionTarget Search
  hi! link EasyMotionShade Comment
  hi GitGutterAdd ctermfg=100 ctermbg=187 guifg=#79740e guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi GitGutterChange ctermfg=29 ctermbg=187 guifg=#427b58 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi GitGutterDelete ctermfg=124 ctermbg=187 guifg=#9e0006 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi GitGutterChangeDelete ctermfg=29 ctermbg=187 guifg=#427b58 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi gitcommitSelectedFile ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi gitcommitDiscardedFile ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SignifySignAdd ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SignifySignChange ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SignifySignDelete ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SyntasticError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
  hi SyntasticWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#b57614 cterm=NONE,underline gui=NONE,undercurl
  hi SyntasticErrorSign ctermfg=124 ctermbg=187 guifg=#9e0006 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi SyntasticWarningSign ctermfg=172 ctermbg=187 guifg=#b57614 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi SignatureMarkText ctermfg=23 ctermbg=187 guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi SignatureMarkerText ctermfg=126 ctermbg=187 guifg=#8f3f71 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLl ctermfg=23 ctermbg=187 guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLu ctermfg=23 ctermbg=187 guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLo ctermfg=23 ctermbg=187 guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLm ctermfg=23 ctermbg=187 guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi CtrlPMatch ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPNoEntries ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPPrtBase ctermfg=187 ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPPrtCursor ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPLinePre ctermfg=187 ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPMode1 ctermfg=23 ctermbg=187 guifg=#076678 guibg=#d5c4a1 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi CtrlPMode2 ctermfg=230 ctermbg=23 guifg=#fdf4c1 guibg=#076678 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi CtrlPStats ctermfg=243 ctermbg=187 guifg=#7c6f64 guibg=#d5c4a1 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi StartifyBracket ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyFile ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyNumber ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyPath ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifySlash ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifySection ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifySpecial ctermfg=187 ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyHeader ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyFooter ctermfg=187 ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineCurrent ctermfg=230 ctermbg=243 guifg=#fdf4c1 guibg=#7c6f64 guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineActive ctermfg=243 ctermbg=187 guifg=#7c6f64 guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineHidden ctermfg=137 ctermbg=187 guifg=#a89984 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineFill ctermfg=230 ctermbg=230 guifg=#fdf4c1 guibg=#fdf4c1 guisp=NONE cterm=NONE gui=NONE
  hi ALEError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
  hi ALEWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
  hi ALEInfo ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#076678 cterm=NONE,underline gui=NONE,undercurl
  hi ALEErrorSign ctermfg=124 ctermbg=187 guifg=#9e0006 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi ALEWarningSign ctermfg=172 ctermbg=187 guifg=#b57614 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi ALEInfoSign ctermfg=23 ctermbg=187 guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi DirvishPathTail ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi DirvishArg ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwDir ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwClassify ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwLink ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwSymLink ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwExe ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwComment ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwList ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwHelpCmd ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwCmdSep ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwVersion ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeDir ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeDirSlash ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeOpenable ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeClosable ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeFile ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeExecFile ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeUp ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeCWD ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeHelp ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeToggleOn ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeToggleOff ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi multiple_cursors_cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi multiple_cursors_visual ctermfg=NONE ctermbg=187 guifg=NONE guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
  hi diffAdded ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffRemoved ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffChanged ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffFile ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffNewFile ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffLine ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlTag ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlEndTag ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlTagName ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi htmlArg ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlScriptTag ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlTagN ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlSpecialTagName ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi htmlLink ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi htmlSpecialChar ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlBold ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi htmlBoldUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
  hi htmlBoldItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
  hi htmlBoldUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic,underline gui=NONE,bold,italic,underline
  hi htmlUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi htmlUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic,underline gui=NONE,italic,underline
  hi htmlItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi xmlTag ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEndTag ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlTagName ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEqual ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi docbkKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi xmlDocTypeDecl ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlDocTypeKeyword ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlCdataStart ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlCdataCdata ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdFunction ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdTagName ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlAttrib ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlProcessingDelim ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdParamEntityPunct ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdParamEntityDPunct ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlAttribPunct ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEntity ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEntityPunct ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimCommentTitle ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi vimNotation ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimBracket ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimMapModKey ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimFuncSID ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimSetSep ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimSep ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimContinue ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureKeyword ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureCond ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureSpecial ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureDefine ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureFunc ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRepeat ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureCharacter ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureStringEscape ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureException ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRegexp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRegexpEscape ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRegexpCharClass ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi! link clojureRegexpMod clojureRegexpCharClass
  hi! link clojureRegexpQuantifier clojureRegexpCharClass
  hi clojureParen ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureAnonArg ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureVariable ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureMacro ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureMeta ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureDeref ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureQuote ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureUnquote ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cOperator ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cStructure ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBuiltin ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBuiltinObj ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBuiltinFunc ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonFunction ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonDecorator ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonInclude ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonImport ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonRun ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonCoding ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonOperator ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonException ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonExceptions ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBoolean ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonDot ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonConditional ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonRepeat ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonDottedName ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi cssBraces ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFunctionName ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssIdentifier ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssClassName ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssColor ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssSelectorOp ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssSelectorOp2 ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssImportant ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssVendor ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTextProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssAnimationProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssUIProp ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTransformProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTransitionProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssPrintProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssPositioningProp ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssBoxProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFontDescriptorProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFlexibleBoxProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssBorderOutlineProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssBackgroundProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssMarginProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssListProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTableProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFontProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssPaddingProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssDimensionProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssRenderProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssColorProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssGeneratedContentProp ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptBraces ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptFunction ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptIdentifier ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptMember ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptNumber ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptNull ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptParens ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptImport ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptExport ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassExtends ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDefault ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassName ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassSuperName ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptGlobal ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptEndColons ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptFuncArg ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptGlobalMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptNodeGlobal ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMWindowProp ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptArrayMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptArrayStaticMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptCacheMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDateMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptMathStaticMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptURLUtilsProp ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMNavigatorProp ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMDocMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMDocProp ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMLocationMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMWindowMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptStringMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptVariable ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptIdentifier ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassSuper ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptFuncKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptAsyncFunc ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassStatic ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptOperator ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptForOperator ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptYield ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptExceptions ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptMessage ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptTemplateSB ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptTemplateSubstitution ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptLabel ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptObjectLabel ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptPropertyName ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptLogicSymbols ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptArrowFunc ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocParamName ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocTags ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocNotation ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocParamType ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocNamedParamType ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBrackets ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMElemAttrs ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMEventMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMNodeMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMStorageMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptHeadersMethod ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptAsyncFuncKeyword ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptAwaitFuncKeyword ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsClassKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsExtendsKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsExportDefault ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsTemplateBraces ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsGlobalNodeObjects ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsGlobalObjects ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsFunction ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsFuncParens ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsParens ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsNull ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsUndefined ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsClassDefinition ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptReserved ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptLabel ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptFuncKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptIdentifier ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptBraces ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptEndColons ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptDOMObjects ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptAjaxMethods ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptLogicSymbols ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link typeScriptDocSeeTag Comment
  hi! link typeScriptDocParam Comment
  hi! link typeScriptDocTags vimCommentTitle
  hi typeScriptGlobalObjects ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptParens ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptOpSymbols ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptHtmlElemProperties ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptNull ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptInterpolationDelimiter ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptModuleKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptModuleName ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptWhere ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptDelimiter ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptType ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptImportKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptHidingKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptAsKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptStructure ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptOperator ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptTypeVar ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptConstructor ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptFunction ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptConditional ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptBacktick ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeExtendedOp ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeSpecialOp ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeCurly ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeParen ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeBracket ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi rubyStringDelimiter ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi rubyInterpolationDelimiter ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi objcTypeModifier ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi objcDirective ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goDirective ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goConstants ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goDeclaration ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goDeclType ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goBuiltins ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi luaIn ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi luaFunction ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi luaTable ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonSpecialOp ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonExtendedOp ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonFunction ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonObject ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaAnnotation ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaDocTags ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link javaCommentTitle vimCommentTitle
  hi javaParen ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen1 ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen2 ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen3 ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen4 ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen5 ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaOperator ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaVarArg ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link elixirDocString Comment
  hi elixirStringDelimiter ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi elixirInterpolationDelimiter ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi elixirModuleDeclaration ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaNameDefinition ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaCaseFollowing ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaCapitalWord ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaTypeExtension ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaKeyword ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaKeywordModifier ctermfg=124 ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaSpecial ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaOperator ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaTypeDeclaration ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaTypeTypePostDeclaration ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaInstanceDeclaration ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaInterpolation ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownItalic ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi markdownH1 ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH2 ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH3 ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH4 ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH5 ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownH6 ctermfg=172 ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownCode ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownCodeBlock ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownCodeDelimiter ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownBlockquote ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownListMarker ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownOrderedListMarker ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownRule ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownHeadingRule ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownUrlDelimiter ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownLinkDelimiter ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownLinkTextDelimiter ctermfg=59 ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownHeadingDelimiter ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownUrl ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownUrlTitleDelimiter ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownLinkText ctermfg=102 ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi! link markdownIdDeclaration markdownLinkText
  hi haskellType ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellIdentifier ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellSeparator ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDelimiter ctermfg=243 ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellOperators ctermfg=23 ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellBacktick ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellStatement ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellConditional ctermfg=124 ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellLet ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDefault ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellWhere ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellBottom ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellBlockKeywords ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellImportKeywords ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDeclKeyword ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDeriving ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellAssocType ctermfg=29 ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellNumber ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellPragma ctermfg=126 ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellString ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellChar ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonKeyword ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonQuote ctermfg=100 ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonBraces ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonString ctermfg=237 ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  finish
endif

" 16-color variant
if &background ==# 'dark'
  if !has('gui_running') && get(g:, 'gruvbox_transp_bg', 0)
    hi Normal ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi CursorLineNr ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi FoldColumn ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi SignColumn ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
    hi VertSplit ctermfg=DarkYellow ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  else
    hi Normal ctermfg=White ctermbg=Black guifg=#ebdbb2 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
    hi CursorLineNr ctermfg=LightYellow ctermbg=DarkRed guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi FoldColumn ctermfg=DarkGrey ctermbg=DarkRed guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi SignColumn ctermfg=NONE ctermbg=DarkRed guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
    hi VertSplit ctermfg=DarkYellow ctermbg=Black guifg=#665c54 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
  endif
  hi ColorColumn ctermfg=NONE ctermbg=DarkRed guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi Conceal ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link CursorColumn CursorLine
  hi CursorLine ctermfg=NONE ctermbg=DarkRed guifg=NONE guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi DiffAdd ctermfg=LightGreen ctermbg=bg guifg=#b8bb26 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi DiffChange ctermfg=LightCyan ctermbg=bg guifg=#8ec07c guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi DiffDelete ctermfg=LightRed ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi DiffText ctermfg=LightYellow ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi Directory ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi EndOfBuffer ctermfg=Black ctermbg=NONE guifg=#282828 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Error ctermfg=LightRed ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
  hi ErrorMsg ctermfg=Black ctermbg=LightRed guifg=#282828 guibg=#fb4934 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Folded ctermfg=DarkGrey ctermbg=DarkRed guifg=#928374 guibg=#3c3836 guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi IncSearch ctermfg=DarkMagenta ctermbg=bg guifg=#fe8019 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi LineNr ctermfg=DarkBlue ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi MatchParen ctermfg=NONE ctermbg=DarkYellow guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi ModeMsg ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi MoreMsg ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi NonText ctermfg=DarkGreen ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Pmenu ctermfg=White ctermbg=DarkGreen guifg=#ebdbb2 guibg=#504945 guisp=NONE cterm=NONE gui=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=DarkGreen guifg=NONE guibg=#504945 guisp=NONE cterm=NONE gui=NONE
  hi PmenuSel ctermfg=DarkGreen ctermbg=LightBlue guifg=#504945 guibg=#83a598 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi PmenuThumb ctermfg=NONE ctermbg=DarkBlue guifg=NONE guibg=#7c6f64 guisp=NONE cterm=NONE gui=NONE
  hi Question ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi! link QuickFixLine Search
  hi Search ctermfg=LightYellow ctermbg=bg guifg=#fabd2f guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi SpecialKey ctermfg=DarkGreen ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SpellBad ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#83a598 cterm=NONE,underline gui=NONE,undercurl
  hi SpellCap ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
  hi SpellLocal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#8ec07c cterm=NONE,underline gui=NONE,undercurl
  hi SpellRare ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#d3869b cterm=NONE,underline gui=NONE,undercurl
  hi StatusLine ctermfg=DarkGreen ctermbg=White guifg=#504945 guibg=#ebdbb2 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi StatusLineNC ctermfg=DarkRed ctermbg=LightGrey guifg=#3c3836 guibg=#a89984 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link StatusLineTerm StatusLine
  hi! link StatusLineTermNC StatusLineNC
  hi! link TabLine TabLineFill
  hi TabLineFill ctermfg=DarkBlue ctermbg=DarkRed guifg=#7c6f64 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi TabLineSel ctermfg=LightGreen ctermbg=DarkRed guifg=#b8bb26 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi Title ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Visual ctermfg=NONE ctermbg=DarkYellow guifg=NONE guibg=#665c54 guisp=NONE cterm=NONE gui=NONE
  hi! link VisualNOS Visual
  hi WarningMsg ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi WildMenu ctermfg=LightBlue ctermbg=DarkGreen guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Boolean ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Character ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Comment ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi Conditional ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Constant ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Define ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Debug ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Delimiter ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Error ctermfg=LightRed ctermbg=bg guifg=#fb4934 guibg=bg guisp=NONE cterm=NONE,bold,inverse gui=NONE,bold,inverse
  hi Exception ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Float ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Function ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi Identifier ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Ignore ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Include ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Keyword ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Label ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Macro ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Number ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Operator Normal
  hi PreCondit ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi PreProc ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Repeat ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Special ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi SpecialChar ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SpecialComment ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Statement ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StorageClass ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi String ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Structure ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link Tag Special
  hi Todo ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
  hi Type ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Typedef ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi Underlined ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi! link lCursor Cursor
  hi CursorIM ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link iCursor Cursor
  hi! link vCursor Cursor
  hi NormalMode ctermfg=LightGrey ctermbg=Black guifg=#a89984 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi InsertMode ctermfg=LightBlue ctermbg=Black guifg=#83a598 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi ReplaceMode ctermfg=LightCyan ctermbg=Black guifg=#8ec07c guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi VisualMode ctermfg=DarkMagenta ctermbg=Black guifg=#fe8019 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi CommandMode ctermfg=LightMagenta ctermbg=Black guifg=#d3869b guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi Warnings ctermfg=DarkMagenta ctermbg=Black guifg=#fe8019 guibg=#282828 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi! link EasyMotionTarget Search
  hi! link EasyMotionShade Comment
  hi GitGutterAdd ctermfg=LightGreen ctermbg=DarkRed guifg=#b8bb26 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi GitGutterChange ctermfg=LightCyan ctermbg=DarkRed guifg=#8ec07c guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi GitGutterDelete ctermfg=LightRed ctermbg=DarkRed guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi GitGutterChangeDelete ctermfg=LightCyan ctermbg=DarkRed guifg=#8ec07c guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi gitcommitSelectedFile ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi gitcommitDiscardedFile ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SignifySignAdd ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SignifySignChange ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SignifySignDelete ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SyntasticError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
  hi SyntasticWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fabd2f cterm=NONE,underline gui=NONE,undercurl
  hi SyntasticErrorSign ctermfg=LightRed ctermbg=DarkRed guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi SyntasticWarningSign ctermfg=LightYellow ctermbg=DarkRed guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi SignatureMarkText ctermfg=LightBlue ctermbg=DarkRed guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi SignatureMarkerText ctermfg=LightMagenta ctermbg=DarkRed guifg=#d3869b guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLl ctermfg=LightBlue ctermbg=DarkRed guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLu ctermfg=LightBlue ctermbg=DarkRed guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLo ctermfg=LightBlue ctermbg=DarkRed guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi ShowMarksHLm ctermfg=LightBlue ctermbg=DarkRed guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi CtrlPMatch ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPNoEntries ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPPrtBase ctermfg=DarkGreen ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPPrtCursor ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPLinePre ctermfg=DarkGreen ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CtrlPMode1 ctermfg=LightBlue ctermbg=DarkGreen guifg=#83a598 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi CtrlPMode2 ctermfg=Black ctermbg=LightBlue guifg=#282828 guibg=#83a598 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi CtrlPStats ctermfg=LightGrey ctermbg=DarkGreen guifg=#a89984 guibg=#504945 guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi StartifyBracket ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyFile ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyNumber ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyPath ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifySlash ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifySection ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifySpecial ctermfg=DarkGreen ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyHeader ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi StartifyFooter ctermfg=DarkGreen ctermbg=NONE guifg=#504945 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineCurrent ctermfg=Black ctermbg=LightGrey guifg=#282828 guibg=#a89984 guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineActive ctermfg=LightGrey ctermbg=DarkGreen guifg=#a89984 guibg=#504945 guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineHidden ctermfg=DarkBlue ctermbg=DarkRed guifg=#7c6f64 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi BufTabLineFill ctermfg=Black ctermbg=Black guifg=#282828 guibg=#282828 guisp=NONE cterm=NONE gui=NONE
  hi ALEError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
  hi ALEWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#fb4934 cterm=NONE,underline gui=NONE,undercurl
  hi ALEInfo ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#83a598 cterm=NONE,underline gui=NONE,undercurl
  hi ALEErrorSign ctermfg=LightRed ctermbg=DarkRed guifg=#fb4934 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi ALEWarningSign ctermfg=LightYellow ctermbg=DarkRed guifg=#fabd2f guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi ALEInfoSign ctermfg=LightBlue ctermbg=DarkRed guifg=#83a598 guibg=#3c3836 guisp=NONE cterm=NONE gui=NONE
  hi DirvishPathTail ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi DirvishArg ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwDir ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwClassify ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwLink ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwSymLink ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwExe ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwComment ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwList ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwHelpCmd ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwCmdSep ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi netrwVersion ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeDir ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeDirSlash ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeOpenable ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeClosable ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeFile ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeExecFile ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeUp ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeCWD ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeHelp ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeToggleOn ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi NERDTreeToggleOff ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi multiple_cursors_cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
  hi multiple_cursors_visual ctermfg=NONE ctermbg=DarkGreen guifg=NONE guibg=#504945 guisp=NONE cterm=NONE gui=NONE
  hi diffAdded ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffRemoved ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffChanged ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffFile ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffNewFile ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi diffLine ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlTag ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlEndTag ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlTagName ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi htmlArg ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlScriptTag ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlTagN ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlSpecialTagName ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi htmlLink ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi htmlSpecialChar ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi htmlBold ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi htmlBoldUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
  hi htmlBoldItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
  hi htmlBoldUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic,underline gui=NONE,bold,italic,underline
  hi htmlUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi htmlUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic,underline gui=NONE,italic,underline
  hi htmlItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi xmlTag ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEndTag ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlTagName ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEqual ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi docbkKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi xmlDocTypeDecl ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlDocTypeKeyword ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlCdataStart ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlCdataCdata ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdFunction ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdTagName ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlAttrib ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlProcessingDelim ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdParamEntityPunct ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi dtdParamEntityDPunct ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlAttribPunct ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEntity ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi xmlEntityPunct ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimCommentTitle ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi vimNotation ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimBracket ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimMapModKey ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimFuncSID ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimSetSep ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimSep ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi vimContinue ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureKeyword ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureCond ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureSpecial ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureDefine ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureFunc ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRepeat ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureCharacter ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureStringEscape ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureException ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRegexp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRegexpEscape ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureRegexpCharClass ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi! link clojureRegexpMod clojureRegexpCharClass
  hi! link clojureRegexpQuantifier clojureRegexpCharClass
  hi clojureParen ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureAnonArg ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureVariable ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureMacro ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureMeta ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureDeref ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureQuote ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi clojureUnquote ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cOperator ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cStructure ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBuiltin ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBuiltinObj ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBuiltinFunc ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonFunction ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonDecorator ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonInclude ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonImport ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonRun ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonCoding ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonOperator ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonException ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonExceptions ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonBoolean ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonDot ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonConditional ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonRepeat ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi pythonDottedName ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi cssBraces ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFunctionName ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssIdentifier ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssClassName ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssColor ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssSelectorOp ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssSelectorOp2 ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssImportant ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssVendor ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTextProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssAnimationProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssUIProp ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTransformProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTransitionProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssPrintProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssPositioningProp ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssBoxProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFontDescriptorProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFlexibleBoxProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssBorderOutlineProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssBackgroundProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssMarginProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssListProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssTableProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssFontProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssPaddingProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssDimensionProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssRenderProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssColorProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi cssGeneratedContentProp ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptBraces ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptFunction ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptIdentifier ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptMember ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptNumber ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptNull ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaScriptParens ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptImport ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptExport ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassExtends ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDefault ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassName ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassSuperName ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptGlobal ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptEndColons ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptFuncArg ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptGlobalMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptNodeGlobal ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMWindowProp ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptArrayMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptArrayStaticMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptCacheMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDateMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptMathStaticMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptURLUtilsProp ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMNavigatorProp ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMDocMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMDocProp ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMLocationMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBOMWindowMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptStringMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptVariable ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptIdentifier ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassSuper ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptFuncKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptAsyncFunc ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptClassStatic ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptOperator ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptForOperator ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptYield ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptExceptions ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptMessage ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptTemplateSB ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptTemplateSubstitution ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptLabel ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptObjectLabel ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptPropertyName ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptLogicSymbols ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptArrowFunc ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocParamName ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocTags ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocNotation ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocParamType ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDocNamedParamType ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptBrackets ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMElemAttrs ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMEventMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMNodeMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptDOMStorageMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptHeadersMethod ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptAsyncFuncKeyword ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javascriptAwaitFuncKeyword ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsClassKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsExtendsKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsExportDefault ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsTemplateBraces ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsGlobalNodeObjects ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsGlobalObjects ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsFunction ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsFuncParens ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsParens ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsNull ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsUndefined ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsClassDefinition ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptReserved ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptLabel ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptFuncKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptIdentifier ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptBraces ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptEndColons ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptDOMObjects ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptAjaxMethods ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptLogicSymbols ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link typeScriptDocSeeTag Comment
  hi! link typeScriptDocParam Comment
  hi! link typeScriptDocTags vimCommentTitle
  hi typeScriptGlobalObjects ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptParens ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptOpSymbols ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptHtmlElemProperties ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptNull ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi typeScriptInterpolationDelimiter ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptModuleKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptModuleName ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptWhere ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptDelimiter ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptType ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptImportKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptHidingKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptAsKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptStructure ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptOperator ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptTypeVar ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptConstructor ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptFunction ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptConditional ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi purescriptBacktick ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeExtendedOp ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeSpecialOp ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeCurly ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeParen ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi coffeeBracket ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi rubyStringDelimiter ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi rubyInterpolationDelimiter ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi objcTypeModifier ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi objcDirective ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goDirective ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goConstants ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goDeclaration ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goDeclType ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi goBuiltins ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi luaIn ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi luaFunction ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi luaTable ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonSpecialOp ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonExtendedOp ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonFunction ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi moonObject ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaAnnotation ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaDocTags ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link javaCommentTitle vimCommentTitle
  hi javaParen ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen1 ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen2 ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen3 ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen4 ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaParen5 ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaOperator ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi javaVarArg ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi! link elixirDocString Comment
  hi elixirStringDelimiter ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi elixirInterpolationDelimiter ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi elixirModuleDeclaration ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaNameDefinition ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaCaseFollowing ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaCapitalWord ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaTypeExtension ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaKeyword ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaKeywordModifier ctermfg=LightRed ctermbg=NONE guifg=#fb4934 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaSpecial ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaOperator ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaTypeDeclaration ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaTypeTypePostDeclaration ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaInstanceDeclaration ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi scalaInterpolation ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownItalic ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
  hi markdownH1 ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH2 ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH3 ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH4 ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
  hi markdownH5 ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownH6 ctermfg=LightYellow ctermbg=NONE guifg=#fabd2f guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownCode ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownCodeBlock ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownCodeDelimiter ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownBlockquote ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownListMarker ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownOrderedListMarker ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownRule ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownHeadingRule ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownUrlDelimiter ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownLinkDelimiter ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownLinkTextDelimiter ctermfg=DarkCyan ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownHeadingDelimiter ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownUrl ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownUrlTitleDelimiter ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi markdownLinkText ctermfg=DarkGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
  hi! link markdownIdDeclaration markdownLinkText
  hi haskellType ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellIdentifier ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellSeparator ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDelimiter ctermfg=LightGrey ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellOperators ctermfg=LightBlue ctermbg=NONE guifg=#83a598 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellBacktick ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellStatement ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellConditional ctermfg=DarkMagenta ctermbg=NONE guifg=#fe8019 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellLet ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDefault ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellWhere ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellBottom ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellBlockKeywords ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellImportKeywords ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDeclKeyword ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellDeriving ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellAssocType ctermfg=LightCyan ctermbg=NONE guifg=#8ec07c guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellNumber ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellPragma ctermfg=LightMagenta ctermbg=NONE guifg=#d3869b guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellString ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi haskellChar ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonKeyword ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonQuote ctermfg=LightGreen ctermbg=NONE guifg=#b8bb26 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonBraces ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi jsonString ctermfg=White ctermbg=NONE guifg=#ebdbb2 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  finish
endif

if !has('gui_running') && get(g:, 'gruvbox_transp_bg', 0)
  hi Normal ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi CursorLineNr ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi FoldColumn ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi SignColumn ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE gui=NONE
  hi VertSplit ctermfg=LightBlue ctermbg=NONE guifg=#bdae93 guibg=NONE guisp=NONE cterm=NONE gui=NONE
else
  hi Normal ctermfg=Black ctermbg=White guifg=#3c3836 guibg=#fdf4c1 guisp=NONE cterm=NONE gui=NONE
  hi CursorLineNr ctermfg=DarkYellow ctermbg=LightCyan guifg=#b57614 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi FoldColumn ctermfg=LightGrey ctermbg=LightCyan guifg=#928374 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi SignColumn ctermfg=NONE ctermbg=LightCyan guifg=NONE guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
  hi VertSplit ctermfg=LightBlue ctermbg=White guifg=#bdae93 guibg=#fdf4c1 guisp=NONE cterm=NONE gui=NONE
endif
hi ColorColumn ctermfg=NONE ctermbg=LightCyan guifg=NONE guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi Conceal ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link CursorColumn CursorLine
hi CursorLine ctermfg=NONE ctermbg=LightCyan guifg=NONE guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi DiffAdd ctermfg=DarkGreen ctermbg=bg guifg=#79740e guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffChange ctermfg=DarkCyan ctermbg=bg guifg=#427b58 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffDelete ctermfg=DarkRed ctermbg=bg guifg=#9e0006 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi DiffText ctermfg=DarkYellow ctermbg=bg guifg=#b57614 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Directory ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi EndOfBuffer ctermfg=White ctermbg=NONE guifg=#fdf4c1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=DarkRed ctermbg=bg guifg=#9e0006 guibg=bg guisp=NONE cterm=NONE,bold,reverse gui=NONE,bold,reverse
hi ErrorMsg ctermfg=White ctermbg=DarkRed guifg=#fdf4c1 guibg=#9e0006 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Folded ctermfg=LightGrey ctermbg=LightCyan guifg=#928374 guibg=#ebdbb2 guisp=NONE cterm=NONE,italic gui=NONE,italic
hi IncSearch ctermfg=LightGreen ctermbg=bg guifg=#af3a03 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi LineNr ctermfg=LightYellow ctermbg=NONE guifg=#a89984 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi MatchParen ctermfg=NONE ctermbg=LightBlue guifg=NONE guibg=#bdae93 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi ModeMsg ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi MoreMsg ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi NonText ctermfg=LightMagenta ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Pmenu ctermfg=Black ctermbg=LightMagenta guifg=#3c3836 guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
hi PmenuSbar ctermfg=NONE ctermbg=LightMagenta guifg=NONE guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
hi PmenuSel ctermfg=LightMagenta ctermbg=DarkBlue guifg=#d5c4a1 guibg=#076678 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi PmenuThumb ctermfg=NONE ctermbg=LightYellow guifg=NONE guibg=#a89984 guisp=NONE cterm=NONE gui=NONE
hi Question ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi! link QuickFixLine Search
hi Search ctermfg=DarkYellow ctermbg=bg guifg=#b57614 guibg=bg guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi SpecialKey ctermfg=LightMagenta ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpellBad ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#076678 cterm=NONE,underline gui=NONE,undercurl
hi SpellCap ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
hi SpellLocal ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#427b58 cterm=NONE,underline gui=NONE,undercurl
hi SpellRare ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#8f3f71 cterm=NONE,underline gui=NONE,undercurl
hi StatusLine ctermfg=LightMagenta ctermbg=Black guifg=#d5c4a1 guibg=#3c3836 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi StatusLineNC ctermfg=LightCyan ctermbg=DarkGrey guifg=#ebdbb2 guibg=#7c6f64 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link TabLine TabLineFill
hi TabLineFill ctermfg=LightYellow ctermbg=LightCyan guifg=#a89984 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi TabLineSel ctermfg=DarkGreen ctermbg=LightCyan guifg=#79740e guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi Title ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Visual ctermfg=NONE ctermbg=LightBlue guifg=NONE guibg=#bdae93 guisp=NONE cterm=NONE gui=NONE
hi! link VisualNOS Visual
hi WarningMsg ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi WildMenu ctermfg=DarkBlue ctermbg=LightMagenta guifg=#076678 guibg=#d5c4a1 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Boolean ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Character ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Comment ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi Conditional ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Constant ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Define ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Debug ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Delimiter ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Error ctermfg=DarkRed ctermbg=bg guifg=#9e0006 guibg=bg guisp=NONE cterm=NONE,bold,inverse gui=NONE,bold,inverse
hi Exception ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Float ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Function ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi Identifier ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Ignore ctermfg=fg ctermbg=NONE guifg=fg guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Include ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Keyword ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Label ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Macro ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Number ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Operator Normal
hi PreCondit ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi PreProc ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Repeat ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Special ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi SpecialChar ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SpecialComment ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Statement ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StorageClass ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi String ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Structure ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link Tag Special
hi Todo ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi Type ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Typedef ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi Underlined ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link lCursor Cursor
hi CursorIM ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link iCursor Cursor
hi! link vCursor Cursor
hi NormalMode ctermfg=DarkGrey ctermbg=White guifg=#7c6f64 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi InsertMode ctermfg=DarkBlue ctermbg=White guifg=#076678 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi ReplaceMode ctermfg=DarkCyan ctermbg=White guifg=#427b58 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi VisualMode ctermfg=LightGreen ctermbg=White guifg=#af3a03 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi CommandMode ctermfg=DarkMagenta ctermbg=White guifg=#8f3f71 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi Warnings ctermfg=LightGreen ctermbg=White guifg=#af3a03 guibg=#fdf4c1 guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi! link EasyMotionTarget Search
hi! link EasyMotionShade Comment
hi GitGutterAdd ctermfg=DarkGreen ctermbg=LightCyan guifg=#79740e guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi GitGutterChange ctermfg=DarkCyan ctermbg=LightCyan guifg=#427b58 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi GitGutterDelete ctermfg=DarkRed ctermbg=LightCyan guifg=#9e0006 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi GitGutterChangeDelete ctermfg=DarkCyan ctermbg=LightCyan guifg=#427b58 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi gitcommitSelectedFile ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi gitcommitDiscardedFile ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SignifySignAdd ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SignifySignChange ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SignifySignDelete ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi SyntasticError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
hi SyntasticWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#b57614 cterm=NONE,underline gui=NONE,undercurl
hi SyntasticErrorSign ctermfg=DarkRed ctermbg=LightCyan guifg=#9e0006 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi SyntasticWarningSign ctermfg=DarkYellow ctermbg=LightCyan guifg=#b57614 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi SignatureMarkText ctermfg=DarkBlue ctermbg=LightCyan guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi SignatureMarkerText ctermfg=DarkMagenta ctermbg=LightCyan guifg=#8f3f71 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLl ctermfg=DarkBlue ctermbg=LightCyan guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLu ctermfg=DarkBlue ctermbg=LightCyan guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLo ctermfg=DarkBlue ctermbg=LightCyan guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi ShowMarksHLm ctermfg=DarkBlue ctermbg=LightCyan guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi CtrlPMatch ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPNoEntries ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPPrtBase ctermfg=LightMagenta ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPPrtCursor ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPLinePre ctermfg=LightMagenta ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi CtrlPMode1 ctermfg=DarkBlue ctermbg=LightMagenta guifg=#076678 guibg=#d5c4a1 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi CtrlPMode2 ctermfg=White ctermbg=DarkBlue guifg=#fdf4c1 guibg=#076678 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi CtrlPStats ctermfg=DarkGrey ctermbg=LightMagenta guifg=#7c6f64 guibg=#d5c4a1 guisp=NONE cterm=NONE,bold gui=NONE,bold
hi StartifyBracket ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyFile ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyNumber ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyPath ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifySlash ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifySection ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifySpecial ctermfg=LightMagenta ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyHeader ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi StartifyFooter ctermfg=LightMagenta ctermbg=NONE guifg=#d5c4a1 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi BufTabLineCurrent ctermfg=White ctermbg=DarkGrey guifg=#fdf4c1 guibg=#7c6f64 guisp=NONE cterm=NONE gui=NONE
hi BufTabLineActive ctermfg=DarkGrey ctermbg=LightMagenta guifg=#7c6f64 guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
hi BufTabLineHidden ctermfg=LightYellow ctermbg=LightCyan guifg=#a89984 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi BufTabLineFill ctermfg=White ctermbg=White guifg=#fdf4c1 guibg=#fdf4c1 guisp=NONE cterm=NONE gui=NONE
hi ALEError ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
hi ALEWarning ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#9e0006 cterm=NONE,underline gui=NONE,undercurl
hi ALEInfo ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=#076678 cterm=NONE,underline gui=NONE,undercurl
hi ALEErrorSign ctermfg=DarkRed ctermbg=LightCyan guifg=#9e0006 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi ALEWarningSign ctermfg=DarkYellow ctermbg=LightCyan guifg=#b57614 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi ALEInfoSign ctermfg=DarkBlue ctermbg=LightCyan guifg=#076678 guibg=#ebdbb2 guisp=NONE cterm=NONE gui=NONE
hi DirvishPathTail ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi DirvishArg ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwDir ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwClassify ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwLink ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwSymLink ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwExe ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwComment ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwList ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwHelpCmd ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwCmdSep ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi netrwVersion ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeDir ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeDirSlash ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeOpenable ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeClosable ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeFile ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeExecFile ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeUp ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeCWD ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeHelp ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeToggleOn ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi NERDTreeToggleOff ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi multiple_cursors_cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE guisp=NONE cterm=NONE,inverse gui=NONE,inverse
hi multiple_cursors_visual ctermfg=NONE ctermbg=LightMagenta guifg=NONE guibg=#d5c4a1 guisp=NONE cterm=NONE gui=NONE
hi diffAdded ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffRemoved ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffChanged ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffFile ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffNewFile ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi diffLine ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlTag ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlEndTag ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlTagName ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi htmlArg ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlScriptTag ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlTagN ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlSpecialTagName ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi htmlLink ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi htmlSpecialChar ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi htmlBold ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold gui=NONE,bold
hi htmlBoldUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,underline gui=NONE,bold,underline
hi htmlBoldItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic gui=NONE,bold,italic
hi htmlBoldUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,bold,italic,underline gui=NONE,bold,italic,underline
hi htmlUnderline ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,underline gui=NONE,underline
hi htmlUnderlineItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic,underline gui=NONE,italic,underline
hi htmlItalic ctermfg=fg ctermbg=bg guifg=fg guibg=bg guisp=NONE cterm=NONE,italic gui=NONE,italic
hi xmlTag ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEndTag ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlTagName ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEqual ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi docbkKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi xmlDocTypeDecl ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlDocTypeKeyword ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlCdataStart ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlCdataCdata ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdFunction ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdTagName ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlAttrib ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlProcessingDelim ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdParamEntityPunct ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi dtdParamEntityDPunct ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlAttribPunct ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEntity ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi xmlEntityPunct ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimCommentTitle ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi vimNotation ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimBracket ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimMapModKey ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimFuncSID ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimSetSep ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimSep ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi vimContinue ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureKeyword ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureCond ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureSpecial ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureDefine ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureFunc ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRepeat ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureCharacter ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureStringEscape ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureException ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRegexp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRegexpEscape ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureRegexpCharClass ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi! link clojureRegexpMod clojureRegexpCharClass
hi! link clojureRegexpQuantifier clojureRegexpCharClass
hi clojureParen ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureAnonArg ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureVariable ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureMacro ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureMeta ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureDeref ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureQuote ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi clojureUnquote ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cOperator ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cStructure ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBuiltin ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBuiltinObj ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBuiltinFunc ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonFunction ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonDecorator ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonInclude ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonImport ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonRun ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonCoding ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonOperator ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonException ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonExceptions ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonBoolean ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonDot ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonConditional ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonRepeat ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi pythonDottedName ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi cssBraces ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFunctionName ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssIdentifier ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssClassName ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssColor ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssSelectorOp ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssSelectorOp2 ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssImportant ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssVendor ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTextProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssAnimationProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssUIProp ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTransformProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTransitionProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssPrintProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssPositioningProp ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssBoxProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFontDescriptorProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFlexibleBoxProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssBorderOutlineProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssBackgroundProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssMarginProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssListProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssTableProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssFontProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssPaddingProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssDimensionProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssRenderProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssColorProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi cssGeneratedContentProp ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptBraces ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptFunction ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptIdentifier ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptMember ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptNumber ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptNull ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaScriptParens ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptImport ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptExport ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassExtends ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDefault ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassName ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassSuperName ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptGlobal ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptEndColons ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptFuncArg ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptGlobalMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptNodeGlobal ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMWindowProp ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptArrayMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptArrayStaticMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptCacheMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDateMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptMathStaticMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptURLUtilsProp ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMNavigatorProp ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMDocMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMDocProp ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMLocationMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBOMWindowMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptStringMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptVariable ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptIdentifier ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassSuper ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptFuncKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptAsyncFunc ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptClassStatic ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptOperator ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptForOperator ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptYield ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptExceptions ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptMessage ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptTemplateSB ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptTemplateSubstitution ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptLabel ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptObjectLabel ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptPropertyName ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptLogicSymbols ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptArrowFunc ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocParamName ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocTags ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocNotation ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocParamType ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDocNamedParamType ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptBrackets ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMElemAttrs ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMEventMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMNodeMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptDOMStorageMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptHeadersMethod ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptAsyncFuncKeyword ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javascriptAwaitFuncKeyword ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsClassKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsExtendsKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsExportDefault ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsTemplateBraces ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsGlobalNodeObjects ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsGlobalObjects ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsFunction ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsFuncParens ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsParens ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsNull ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsUndefined ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsClassDefinition ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptReserved ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptLabel ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptFuncKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptIdentifier ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptBraces ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptEndColons ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptDOMObjects ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptAjaxMethods ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptLogicSymbols ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link typeScriptDocSeeTag Comment
hi! link typeScriptDocParam Comment
hi! link typeScriptDocTags vimCommentTitle
hi typeScriptGlobalObjects ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptParens ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptOpSymbols ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptHtmlElemProperties ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptNull ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi typeScriptInterpolationDelimiter ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptModuleKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptModuleName ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptWhere ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptDelimiter ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptType ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptImportKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptHidingKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptAsKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptStructure ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptOperator ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptTypeVar ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptConstructor ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptFunction ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptConditional ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi purescriptBacktick ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeExtendedOp ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeSpecialOp ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeCurly ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeParen ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi coffeeBracket ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi rubyStringDelimiter ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi rubyInterpolationDelimiter ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi objcTypeModifier ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi objcDirective ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goDirective ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goConstants ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goDeclaration ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goDeclType ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi goBuiltins ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi luaIn ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi luaFunction ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi luaTable ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonSpecialOp ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonExtendedOp ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonFunction ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi moonObject ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaAnnotation ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaDocTags ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link javaCommentTitle vimCommentTitle
hi javaParen ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen1 ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen2 ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen3 ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen4 ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaParen5 ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaOperator ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi javaVarArg ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi! link elixirDocString Comment
hi elixirStringDelimiter ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi elixirInterpolationDelimiter ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi elixirModuleDeclaration ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaNameDefinition ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaCaseFollowing ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaCapitalWord ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaTypeExtension ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaKeyword ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaKeywordModifier ctermfg=DarkRed ctermbg=NONE guifg=#9e0006 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaSpecial ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaOperator ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaTypeDeclaration ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaTypeTypePostDeclaration ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaInstanceDeclaration ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi scalaInterpolation ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownItalic ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE,italic gui=NONE,italic
hi markdownH1 ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH2 ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH3 ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH4 ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE,bold gui=NONE,bold
hi markdownH5 ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownH6 ctermfg=DarkYellow ctermbg=NONE guifg=#b57614 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownCode ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownCodeBlock ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownCodeDelimiter ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownBlockquote ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownListMarker ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownOrderedListMarker ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownRule ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownHeadingRule ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownUrlDelimiter ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownLinkDelimiter ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownLinkTextDelimiter ctermfg=LightRed ctermbg=NONE guifg=#665c54 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownHeadingDelimiter ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownUrl ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownUrlTitleDelimiter ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi markdownLinkText ctermfg=LightGrey ctermbg=NONE guifg=#928374 guibg=NONE guisp=NONE cterm=NONE,underline gui=NONE,underline
hi! link markdownIdDeclaration markdownLinkText
hi haskellType ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellIdentifier ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellSeparator ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDelimiter ctermfg=DarkGrey ctermbg=NONE guifg=#7c6f64 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellOperators ctermfg=DarkBlue ctermbg=NONE guifg=#076678 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellBacktick ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellStatement ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellConditional ctermfg=LightGreen ctermbg=NONE guifg=#af3a03 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellLet ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDefault ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellWhere ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellBottom ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellBlockKeywords ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellImportKeywords ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDeclKeyword ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellDeriving ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellAssocType ctermfg=DarkCyan ctermbg=NONE guifg=#427b58 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellNumber ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellPragma ctermfg=DarkMagenta ctermbg=NONE guifg=#8f3f71 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellString ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi haskellChar ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonKeyword ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonQuote ctermfg=DarkGreen ctermbg=NONE guifg=#79740e guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonBraces ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
hi jsonString ctermfg=Black ctermbg=NONE guifg=#3c3836 guibg=NONE guisp=NONE cterm=NONE gui=NONE
finish

" Background: dark
" Color: dark0             rgb(40,  40,  40)     ~           Black
" Color: dark1             rgb(60,  56,  54)     ~         DarkRed
" Color: dark2             rgb(80,  73,  69)     ~       DarkGreen
" Color: dark3             rgb(102, 92,  84)     ~      DarkYellow
" Color: dark4             rgb(124, 111, 100)    ~        DarkBlue
" Color: orange            rgb(254, 128, 25)     ~     DarkMagenta
" Color: light3            rgb(189, 174, 147)    ~        DarkCyan
" Color: light4            rgb(168, 153, 132)    ~       LightGrey
" Color: grey              rgb(146, 131, 116)    ~        DarkGrey
" Color: red               rgb(251, 73,  52)     203      LightRed
" Color: green             rgb(184, 187, 38)     ~      LightGreen
" Color: yellow            rgb(250, 189, 47)     ~     LightYellow
" Color: blue              rgb(131, 165, 152)    ~       LightBlue
" Color: purple            rgb(211, 134, 155)    ~    LightMagenta
" Color: aqua              rgb(142, 192, 124)    ~       LightCyan
" Color: light1            rgb(235, 219, 178)    ~           White
"     Normal       light1 none
"     CursorLineNr yellow none
"     FoldColumn   grey   none
"     SignColumn   none   none
"     VertSplit    dark3  none
"     Normal       light1 dark0
"     CursorLineNr yellow dark1
"     FoldColumn   grey   dark1
"     SignColumn   none   dark1
"     VertSplit    dark3  dark0
" ColorColumn                      none   dark1
" Conceal                          blue   none
" Cursor                           none   none    inverse
" CursorColumn                  -> CursorLine
" CursorLine                       none   dark1
" DiffAdd                          green  bg      inverse
" DiffChange                       aqua   bg      inverse
" DiffDelete                       red    bg      inverse
" DiffText                         yellow bg      inverse
" Directory                        green  none    bold
" EndOfBuffer                      dark0  none
" Error                            red    bg      bold,reverse
" ErrorMsg                         dark0  red     bold
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
" SpecialKey                       dark2  none
" SpellBad                         none   none    t=underline g=undercurl s=blue
" SpellCap                         none   none    t=underline g=undercurl s=red
" SpellLocal                       none   none    t=underline g=undercurl s=aqua
" SpellRare                        none   none    t=underline g=undercurl s=purple
" StatusLine                       dark2  light1  inverse
" StatusLineNC                     dark1  light4  inverse
" StatusLineTerm                -> StatusLine
" StatusLineTermNC              -> StatusLineNC
" TabLine                       -> TabLineFill
" TabLineFill                      dark4  dark1
" TabLineSel                       green  dark1
" Title                            green  none    bold
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
" Background: light
" Color: dark1             rgb( 60,  56,  54)    ~           Black
" Color: red               rgb(158,   0,   6)    ~         DarkRed
" Color: green             rgb(121, 116,  14)    ~       DarkGreen
" Color: yellow            rgb(181, 118,  20)    ~      DarkYellow
" Color: blue              rgb(  7, 102, 120)    ~        DarkBlue
" Color: purple            rgb(143,  63, 113)    ~     DarkMagenta
" Color: aqua              rgb( 66, 123,  88)    ~        DarkCyan
" Color: grey              rgb(146, 131, 116)    ~       LightGrey
" Color: dark4             rgb(124, 111, 100)    ~        DarkGrey
" Color: dark3             rgb(102,  92,  84)    ~        LightRed
" Color: orange            rgb(175,  58,   3)    ~      LightGreen
" Color: light4            rgb(168, 153, 132)    ~     LightYellow
" Color: light3            rgb(189, 174, 147)    ~       LightBlue
" Color: light2            rgb(213, 196, 161)    ~    LightMagenta
" Color: light1            rgb(235, 219, 178)    ~       LightCyan
" Color: light0            rgb(253, 244, 193)    ~           White
"     Normal       dark1  none
"     CursorLineNr yellow none
"     FoldColumn   grey   none
"     SignColumn   none   none
"     VertSplit    light3 none
"     Normal       dark1  light0
"     CursorLineNr yellow light1
"     FoldColumn   grey   light1
"     SignColumn   none   light1
"     VertSplit    light3 light0
" ColorColumn                      none   light1
" Conceal                          blue   none
" Cursor                           none   none    inverse
" CursorColumn                  -> CursorLine
" CursorLine                       none   light1
" DiffAdd                          green  bg      inverse
" DiffChange                       aqua   bg      inverse
" DiffDelete                       red    bg      inverse
" DiffText                         yellow bg      inverse
" Directory                        green  none    bold
" EndOfBuffer                      light0 none
" Error                            red    bg      bold,reverse
" ErrorMsg                         light0 red     bold
" Folded                           grey   light1  italic
" IncSearch                        orange bg      inverse
" LineNr                           light4 none
" MatchParen                       none   light3  bold
" ModeMsg                          yellow none    bold
" MoreMsg                          yellow none    bold
" NonText                          light2 none
" Pmenu                            dark1  light2
" PmenuSbar                        none   light2
" PmenuSel                         light2 blue    bold
" PmenuThumb                       none   light4
" Question                         orange none    bold
" QuickFixLine                  -> Search
" Search                           yellow bg      inverse
" SpecialKey                       light2 none
" SpellBad                         none   none    t=underline g=undercurl s=blue
" SpellCap                         none   none    t=underline g=undercurl s=red
" SpellLocal                       none   none    t=underline g=undercurl s=aqua
" SpellRare                        none   none    t=underline g=undercurl s=purple
" StatusLine                       light2 dark1   inverse
" StatusLineNC                     light1 dark4   inverse
" StatusLineTerm                -> StatusLine
" StatusLineTermNC              -> StatusLineNC
" TabLine                       -> TabLineFill
" TabLineFill                      light4 light1
" TabLineSel                       green  light1
" Title                            green  none    bold
" Visual                           none   light3
" VisualNOS                     -> Visual
" WarningMsg                       red    none    bold
" WildMenu                         blue   light2  bold
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
" NormalMode                       dark4  light0  inverse
" InsertMode                       blue   light0  inverse
" ReplaceMode                      aqua   light0  inverse
" VisualMode                       orange light0  inverse
" CommandMode                      purple light0  inverse
" Warnings                         orange light0  inverse
" EasyMotionTarget              -> Search
" EasyMotionShade               -> Comment
" GitGutterAdd                     green  light1
" GitGutterChange                  aqua   light1
" GitGutterDelete                  red    light1
" GitGutterChangeDelete            aqua   light1
" gitcommitSelectedFile            green  none
" gitcommitDiscardedFile           red    none
" SignifySignAdd                   green  none
" SignifySignChange                aqua   none
" SignifySignDelete                red    none
" SyntasticError                   none   none    t=underline g=undercurl s=red
" SyntasticWarning                 none   none    t=underline g=undercurl s=yellow
" SyntasticErrorSign               red    light1
" SyntasticWarningSign             yellow light1
" SignatureMarkText                blue   light1
" SignatureMarkerText              purple light1
" ShowMarksHLl                     blue   light1
" ShowMarksHLu                     blue   light1
" ShowMarksHLo                     blue   light1
" ShowMarksHLm                     blue   light1
" CtrlPMatch                       yellow none
" CtrlPNoEntries                   red    none
" CtrlPPrtBase                     light2 none
" CtrlPPrtCursor                   blue   none
" CtrlPLinePre                     light2 none
" CtrlPMode1                       blue   light2  bold
" CtrlPMode2                       light0 blue    bold
" CtrlPStats                       dark4  light2  bold
" StartifyBracket                  dark3  none
" StartifyFile                     dark1  none
" StartifyNumber                   blue   none
" StartifyPath                     grey   none
" StartifySlash                    grey   none
" StartifySection                  yellow none
" StartifySpecial                  light2 none
" StartifyHeader                   orange none
" StartifyFooter                   light2 none
" BufTabLineCurrent                light0 dark4
" BufTabLineActive                 dark4  light2
" BufTabLineHidden                 light4 light1
" BufTabLineFill                   light0 light0
" ALEError                         none   none    t=underline g=undercurl s=red
" ALEWarning                       none   none    t=underline g=undercurl s=red
" ALEInfo                          none   none    t=underline g=undercurl s=blue
" ALEErrorSign                     red    light1
" ALEWarningSign                   yellow light1
" ALEInfoSign                      blue   light1
" DirvishPathTail                  aqua   none
" DirvishArg                       yellow none
" netrwDir                         aqua   none
" netrwClassify                    aqua   none
" netrwLink                        grey   none
" netrwSymLink                     dark1  none
" netrwExe                         yellow none
" netrwComment                     grey   none
" netrwList                        blue   none
" netrwHelpCmd                     aqua   none
" netrwCmdSep                      dark3  none
" netrwVersion                     green  none
" NERDTreeDir                      aqua   none
" NERDTreeDirSlash                 aqua   none
" NERDTreeOpenable                 orange none
" NERDTreeClosable                 orange none
" NERDTreeFile                     dark1  none
" NERDTreeExecFile                 yellow none
" NERDTreeUp                       grey   none
" NERDTreeCWD                      green  none
" NERDTreeHelp                     dark1  none
" NERDTreeToggleOn                 green  none
" NERDTreeToggleOff                red    none
" multiple_cursors_cursor          none   none    inverse
" multiple_cursors_visual          none   light2
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
" htmlTagN                         dark1  none
" htmlSpecialTagName               aqua   none    bold
" htmlLink                         dark4  none    underline
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
" vimCommentTitle                  dark4  none    bold
" vimNotation                      orange none
" vimBracket                       orange none
" vimMapModKey                     orange none
" vimFuncSID                       dark3  none
" vimSetSep                        dark3  none
" vimSep                           dark3  none
" vimContinue                      dark3  none
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
" clojureRegexpCharClass           dark3  none    bold
" clojureRegexpMod              -> clojureRegexpCharClass
" clojureRegexpQuantifier       -> clojureRegexpCharClass
" clojureParen                     dark3  none
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
" pythonDot                        dark3  none
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
" cssVendor                        dark1  none
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
" javaScriptBraces                 dark1  none
" javaScriptFunction               aqua   none
" javaScriptIdentifier             red    none
" javaScriptMember                 blue   none
" javaScriptNumber                 purple none
" javaScriptNull                   purple none
" javaScriptParens                 dark3  none
" javascriptImport                 aqua   none
" javascriptExport                 aqua   none
" javascriptClassKeyword           aqua   none
" javascriptClassExtends           aqua   none
" javascriptDefault                aqua   none
" javascriptClassName              yellow none
" javascriptClassSuperName         yellow none
" javascriptGlobal                 yellow none
" javascriptEndColons              dark1  none
" javascriptFuncArg                dark1  none
" javascriptGlobalMethod           dark1  none
" javascriptNodeGlobal             dark1  none
" javascriptBOMWindowProp          dark1  none
" javascriptArrayMethod            dark1  none
" javascriptArrayStaticMethod      dark1  none
" javascriptCacheMethod            dark1  none
" javascriptDateMethod             dark1  none
" javascriptMathStaticMethod       dark1  none
" javascriptURLUtilsProp           dark1  none
" javascriptBOMNavigatorProp       dark1  none
" javascriptDOMDocMethod           dark1  none
" javascriptDOMDocProp             dark1  none
" javascriptBOMLocationMethod      dark1  none
" javascriptBOMWindowMethod        dark1  none
" javascriptStringMethod           dark1  none
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
" javascriptTemplateSubstitution   dark1  none
" javascriptLabel                  dark1  none
" javascriptObjectLabel            dark1  none
" javascriptPropertyName           dark1  none
" javascriptLogicSymbols           dark1  none
" javascriptArrowFunc              yellow none
" javascriptDocParamName           dark4  none
" javascriptDocTags                dark4  none
" javascriptDocNotation            dark4  none
" javascriptDocParamType           dark4  none
" javascriptDocNamedParamType      dark4  none
" javascriptBrackets               dark1  none
" javascriptDOMElemAttrs           dark1  none
" javascriptDOMEventMethod         dark1  none
" javascriptDOMNodeMethod          dark1  none
" javascriptDOMStorageMethod       dark1  none
" javascriptHeadersMethod          dark1  none
" javascriptAsyncFuncKeyword       red    none
" javascriptAwaitFuncKeyword       red    none
" jsClassKeyword                   aqua   none
" jsExtendsKeyword                 aqua   none
" jsExportDefault                  aqua   none
" jsTemplateBraces                 aqua   none
" jsGlobalNodeObjects              dark1  none
" jsGlobalObjects                  dark1  none
" jsFunction                       aqua   none
" jsFuncParens                     dark3  none
" jsParens                         dark3  none
" jsNull                           purple none
" jsUndefined                      purple none
" jsClassDefinition                yellow none
" typeScriptReserved               aqua   none
" typeScriptLabel                  aqua   none
" typeScriptFuncKeyword            aqua   none
" typeScriptIdentifier             orange none
" typeScriptBraces                 dark1  none
" typeScriptEndColons              dark1  none
" typeScriptDOMObjects             dark1  none
" typeScriptAjaxMethods            dark1  none
" typeScriptLogicSymbols           dark1  none
" typeScriptDocSeeTag           -> Comment
" typeScriptDocParam            -> Comment
" typeScriptDocTags             -> vimCommentTitle
" typeScriptGlobalObjects          dark1  none
" typeScriptParens                 dark3  none
" typeScriptOpSymbols              dark3  none
" typeScriptHtmlElemProperties     dark1  none
" typeScriptNull                   purple none
" typeScriptInterpolationDelimiter aqua   none
" purescriptModuleKeyword          aqua   none
" purescriptModuleName             dark1  none
" purescriptWhere                  aqua   none
" purescriptDelimiter              dark4  none
" purescriptType                   dark1  none
" purescriptImportKeyword          aqua   none
" purescriptHidingKeyword          aqua   none
" purescriptAsKeyword              aqua   none
" purescriptStructure              aqua   none
" purescriptOperator               blue   none
" purescriptTypeVar                dark1  none
" purescriptConstructor            dark1  none
" purescriptFunction               dark1  none
" purescriptConditional            orange none
" purescriptBacktick               orange none
" coffeeExtendedOp                 dark3  none
" coffeeSpecialOp                  dark3  none
" coffeeCurly                      orange none
" coffeeParen                      dark3  none
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
" moonSpecialOp                    dark3  none
" moonExtendedOp                   dark3  none
" moonFunction                     dark3  none
" moonObject                       yellow none
" javaAnnotation                   blue   none
" javaDocTags                      aqua   none
" javaCommentTitle              -> vimCommentTitle
" javaParen                        dark3  none
" javaParen1                       dark3  none
" javaParen2                       dark3  none
" javaParen3                       dark3  none
" javaParen4                       dark3  none
" javaParen5                       dark3  none
" javaOperator                     orange none
" javaVarArg                       green  none
" elixirDocString               -> Comment
" elixirStringDelimiter            green  none
" elixirInterpolationDelimiter     aqua   none
" elixirModuleDeclaration          yellow none
" scalaNameDefinition              dark1  none
" scalaCaseFollowing               dark1  none
" scalaCapitalWord                 dark1  none
" scalaTypeExtension               dark1  none
" scalaKeyword                     red    none
" scalaKeywordModifier             red    none
" scalaSpecial                     aqua   none
" scalaOperator                    dark1  none
" scalaTypeDeclaration             yellow none
" scalaTypeTypePostDeclaration     yellow none
" scalaInstanceDeclaration         dark1  none
" scalaInterpolation               aqua   none
" markdownItalic                   dark3  none    italic
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
" markdownUrlDelimiter             dark3  none
" markdownLinkDelimiter            dark3  none
" markdownLinkTextDelimiter        dark3  none
" markdownHeadingDelimiter         orange none
" markdownUrl                      purple none
" markdownUrlTitleDelimiter        green  none
" markdownLinkText                 grey   none    underline
" markdownIdDeclaration         -> markdownLinkText
" haskellType                      dark1  none
" haskellIdentifier                dark1  none
" haskellSeparator                 dark1  none
" haskellDelimiter                 dark4  none
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
" jsonBraces                       dark1  none
" jsonString                       dark1  none
