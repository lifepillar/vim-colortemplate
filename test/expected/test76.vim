" Name:         Test 76
" Author:       y
" Maintainer:   y
" License:      Vim License (see `:help license`)

set background=dark

hi clear
let g:colors_name = 'test76'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

hi! link PopupSelected PmenuSel
hi! link QuickFixLine Search

" @suppress ColorColumn
" @suppress Comment
" @suppress Conceal
" @suppress Constant
" @suppress Cursor
" @suppress CursorColumn
" @suppress CursorLine
" @suppress CursorLineFold
" @suppress CursorLineNr
" @suppress CursorLineSign
" @suppress DiffAdd
" @suppress DiffChange
" @suppress DiffDelete
" @suppress DiffText
" @suppress Directory
" @suppress EndOfBuffer
" @suppress Error
" @suppress ErrorMsg
" @suppress FoldColumn
" @suppress Folded
" @suppress Identifier
" @suppress Ignore
" @suppress IncSearch
" @suppress LineNr
" @suppress LineNrAbove
" @suppress LineNrBelow
" @suppress MatchParen
" @suppress MessageWindow
" @suppress ModeMsg
" @suppress MoreMsg
" @suppress NonText
" @suppress Pmenu
" @suppress PmenuSbar
" @suppress PmenuSel
" @suppress PmenuThumb
" @suppress PopupNotification
" @suppress PreProc
" @suppress Question
" @suppress Search
" @suppress SignColumn
" @suppress Special
" @suppress SpecialKey
" @suppress SpellBad
" @suppress SpellCap
" @suppress SpellLocal
" @suppress SpellRare
" @suppress Statement
" @suppress StatusLine
" @suppress StatusLineNC
" @suppress StatusLineTerm
" @suppress StatusLineTermNC
" @suppress TabLine
" @suppress TabLineFill
" @suppress TabLineSel
" @suppress Title
" @suppress Todo
" @suppress ToolbarButton
" @suppress ToolbarLine
" @suppress Type
" @suppress Underlined
" @suppress VertSplit
" @suppress Visual
" @suppress VisualNOS
" @suppress WarningMsg
" @suppress WildMenu

if s:t_Co >= 256
  hi Normal ctermfg=8 ctermbg=8 cterm=NONE
  unlet s:t_Co
  finish
endif

" vim: et ts=2 sw=2
