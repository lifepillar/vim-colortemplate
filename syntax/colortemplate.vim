" Name:        Colorscheme template
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:current_syntax")
  finish
endif


syn case ignore
syn match   colortemplateComment  "#.*$" contains=colortemplateTodo,@Spell
syn match   colortemplateKey      "^\s*\(\w[^:]*\):"
syn match   colortemplateColorDef "^\s*color\s*:.*$" contains=colortemplateKey,colortemplateNumber,colortemplateHexColor,colortemplateFunction,colortemplateConstant
syn match   colortemplateNumber   "\d\+" contained
syn match   colortemplateArrow    "->"
syn match   colortemplateHexColor "#[a-f0-9]\{6\}" contained
syn keyword colortemplateFunction rgb contained
syn keyword colortemplateTodo     contained TODO FIXME XXX DEBUG NOTE
syntax case match
syn keyword colortemplateConstant contained Black DarkRed DarkGreen DarkYellow DarkBlue DarkMagenta DarkCyan LightGrey
syn keyword colortemplateConstant contained DarkGrey LightRed LightGreen LightYellow LightBlue LightMagenta LightCyan White
syn match   colortemplateAttrs    "\<\%(te\?r\?m\?\|gu\?i\?\)=\S\+" contains=colortemplateAttr
syn match   colortemplateGuisp    "\<\%(guisp\|sp\?\)="
syn match   colortemplateHiGroup  "\<Conceal\>"
syn keyword colortemplateHiGroup  Boolean Character ColorColumn Comment Constant Cursor CursorColumn CursorIM
syn keyword colortemplateHiGroup  CursorLine CursorLineNr Debug Delimiter DiffAdd DiffChange DiffDelete DiffText Directory
syn keyword colortemplateHiGroup  EndOfBuffer Error ErrorMsg Float FoldColumn Folded Function Identifier Ignore
syn keyword colortemplateHiGroup  IncSearch Include Keyword Label LineNr MatchParen ModeMsg MoreMsg NonText
syn keyword colortemplateHiGroup  Normal Number Operator Pmenu PmenuSbar PmenuSel PmenuThumb PreProc Question
syn keyword colortemplateHiGroup  QuickFixLine Search SignColumn Special SpecialChar SpecialComment SpecialKey SpellBad SpellCap
syn keyword colortemplateHiGroup  SpellLocal SpellRare Statement StatusLine StatusLineNC StatusLineTerm StatusLineTermNC StorageClass String
syn keyword colortemplateHiGroup  Structure TabLine TabLineFill TabLineSel Title Todo Type Underlined VertSplit
syn keyword colortemplateHiGroup  Visual VisualNOS WarningMsg WildMenu lCursor
syn keyword colortemplateHiGroup  vimAuSyntax vimAugroup vimAutoCmdSfxList vimAutoCmdSpace vimAutoEventList vimBracket vimClusterName vimCmdSep
syn keyword colortemplateHiGroup  vimCollClass vimCollection vimCommentTitle vimCommentTitleLeader vimEcho vimEscapeBrace vimExecute vimExtCmd
syn keyword colortemplateHiGroup  vimFiletype vimFilter vimFuncBlank vimFuncBody vimFunction vimGlobal vimGroupList vimHiBang
syn keyword colortemplateHiGroup  vimHiCtermColor vimHiFontname vimHiGuiFontname vimHiKeyList vimHiLink vimHiTermcap vimIf vimIsCommand
syn keyword colortemplateHiGroup  vimIskList vimMapLhs vimMapMod vimMapModKey vimMapRhs vimMapRhsExtend vimMenuBang vimMenuMap
syn keyword colortemplateHiGroup  vimMenuPriority vimMenuRhs vimNormCmds vimNotation vimOperParen vimPatRegion vimRegion vimSet
syn keyword colortemplateHiGroup  vimSetEqual vimStdPlugin vimSubstPat vimSubstRange vimSubstRep vimSubstRep4 vimSynKeyRegion vimSynLine
syn keyword colortemplateHiGroup  vimSynMatchRegion vimSynMtchCchar vimSynMtchGroup vimSynPatMod vimSynRegion vimSyncLinebreak vimSyncLinecont vimSyncLines
syn keyword colortemplateHiGroup  vimSyncMatch vimSyncRegion vimUserCmd vimUserFunc
syn keyword colortemplateAttr     bold underline undercurl strikethrough reverse inverse italic standout nocombine NONE
syn keyword colortemplateSpecial  fg bg none

hi def link colortemplateArrow    Delimiter
hi def link colortemplateAttr     Label
hi def link colortemplateAttrs    String
hi def link colortemplateConstant Type
hi def link colortemplateComment  Comment
hi def link colortemplateFunction Function
hi def link colortemplateGuisp    String
hi def link colortemplateHexColor Constant
hi def link colortemplateHiGroup  Identifier
hi def link colortemplateNumber   Number
hi def link colortemplateKey      Special
hi def link colortemplateSpecial  Boolean

let b:current_syntax = "colortemplate"
