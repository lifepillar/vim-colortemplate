vim9script
# Name:        Colortemplate
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     MIT

if exists("b:current_syntax")
  finish
endif

const COLORNAMES = join(keys(v:colornames), '\|')

syn case ignore

execute $'syn match colortemplateRgbName +"\%({COLORNAMES}\)"+ contained'

syn case    match

syn match   colortemplateDiscrName    "+\s*\h\w*\>"
syn match   colortemplateVariant      "/\s*\d\+\|/gui\>"
syn match   colortemplateSpecial        "\<sp\?="
syn match   colortemplateTermCode     "\<st\%(art\|op\)="
syn match   colortemplateHiGroupDef   "^\h\w*\>" contains=colortemplateHiGroup
syn match   colortemplateHiGroup      contained "\<Conceal\>"
syn keyword colortemplateHiGroup      contained Added Boolean Changed Character ColorColumn Comment Conditional Constant CurSearch Cursor CursorColumn CursorIM
syn keyword colortemplateHiGroup      contained CursorLine CursorLineFold CursorLineNr CursorLineSign Define Debug Delimiter
syn keyword colortemplateHiGroup      contained DiffAdd diffAdded DiffChange diffChanged DiffDelete diffRemoved DiffText Directory
syn keyword colortemplateHiGroup      contained EndOfBuffer Error ErrorMsg Exception Float FoldColumn Folded Function Identifier Ignore
syn keyword colortemplateHiGroup      contained IncSearch Include Keyword Label LineNr LineNrAbove LineNrBelow Macro MatchParen MessageWindow ModeMsg MoreMsg NonText
syn keyword colortemplateHiGroup      contained Normal Number Operator Pmenu PmenuKind PmenuKindSel PmenuExtra PmenuExtraSel PmenuMatch PmenuMatchSel
syn keyword colortemplateHiGroup      contained PmenuSbar PmenuSel PmenuThumb PopupNotification PopupSelected PreCondit PreProc Question
syn keyword colortemplateHiGroup      contained QuickFixLine Removed Repeat Search SignColumn Special SpecialChar SpecialComment SpecialKey SpellBad SpellCap
syn keyword colortemplateHiGroup      contained SpellLocal SpellRare Statement StatusLine StatusLineNC StatusLineTerm StatusLineTermNC StorageClass String
syn keyword colortemplateHiGroup      contained Structure TabLine TabLineFill TabLineSel TabPanel TabPanelFill TabPanelSel Tag Terminal Title Todo Type
syn keyword colortemplateHiGroup      contained Typedef Underlined VertSplit debugPC debugBreakpoint ToolbarLine ToolbarButton
syn keyword colortemplateHiGroup      contained Visual VisualNOS WarningMsg WildMenu lCursor
syn keyword colortemplateHiGroup      contained Menu Scrollbar Tooltip User1 User2 User3 User4 User5 User6 User7 User8 User9
syn keyword colortemplateHiGroup      contained vimAuSyntax vimAugroup vimAutoCmdSfxList vimAutoCmdSpace vimAutoEventList vimBracket vimClusterName vimCmdSep
syn keyword colortemplateHiGroup      contained vimCollClass vimCollection vimCommentTitle vimCommentTitleLeader vimEcho vimEscapeBrace vimExecute vimExtCmd
syn keyword colortemplateHiGroup      contained vimFiletype vimFilter vimFuncBlank vimFuncBody vimFunction vimGlobal vimGroupList vimHiBang
syn keyword colortemplateHiGroup      contained vimHiCtermColor vimHiFontname vimHiGuiFontname vimHiKeyList vimHiLink vimHiTermcap vimIf vimIsCommand
syn keyword colortemplateHiGroup      contained vimIskList vimMapLhs vimMapMod vimMapModKey vimMapRhs vimMapRhsExtend vimMenuBang vimMenuMap
syn keyword colortemplateHiGroup      contained vimMenuPriority vimMenuRhs vimNormCmds vimNotation vimOperParen vimPatRegion vimRegion vimSet
syn keyword colortemplateHiGroup      contained vimSetEqual vimStdPlugin vimSubstPat vimSubstRange vimSubstRep vimSubstRep4 vimSynKeyRegion vimSynLine
syn keyword colortemplateHiGroup      contained vimSynMatchRegion vimSynMtchCchar vimSynMtchGroup vimSynPatMod vimSynRegion vimSyncLinebreak vimSyncLinecont vimSyncLines
syn keyword colortemplateHiGroup      contained vimSyncMatch vimSyncRegion vimUserCmd vimUserFunc
syn keyword colortemplateAttr         bold underline undercurl underdouble underdotted underdashed strikethrough reverse inverse italic standout nocombine NONE
syn keyword colortemplateSpecial      fg bg none omit
syn match   colortemplateComment      ";.*$" contains=colortemplateTodo,@Spell
syn match   colortemplateKey          "\%(Color\|Background\|Environments\|Include\|\%(Full\|Short\)\s\+[Nn]ame\|Author\|Maintainer\|URL\|Description\|License\|Term\s\+[Cc]olors\|Options\|Prefix\|Variants\):"
syn match   colortemplateColorSpec    "^\s*Color\s*:\s*\w\+" contains=colortemplateKey nextgroup=colortemplateColorDef
syn match   colortemplateColorDef     ".\+$" contained contains=colortemplateNumber,colortemplateHexColor,colortemplateFunction,colortemplateConstant,colortemplateCompound,colortemplateComment,colortemplateRgbName
syn match   colortemplateNumber       "\<\d\+\>" contained
syn match   colortemplateArrow        "->"
syn match   colortemplateHexColor     "#[A-Fa-f0-9]\{6\}" contained
syn keyword colortemplateFunction     contained rgb
syn keyword colortemplateTodo         contained TODO FIXME XXX DEBUG NOTE
# Basic color names
syn keyword colortemplateConstant     contained Black Blue Brown Cyan DarkRed DarkGreen DarkYellow DarkBlue DarkMagenta DarkCyan Green LightGray LightGrey
syn keyword colortemplateConstant     contained DarkGray DarkGrey Gray Grey LightRed LightGreen LightYellow LightBlue LightMagenta LightCyan Magenta Red Yellow White

# These are defined for syntax completion. Since they are `contained`, but not
# really contained into anything, this rule is never triggered.
syn keyword colortemplateKeyword      contained auxfile endauxfile helpfile endhelpfile verbatim endverbatim

syn include @colortemplatevim syntax/vim.vim
unlet b:current_syntax
syn region colortemplateVim matchgroup=colortemplateVerb start=/^\s*verbatim\>/ end=/^\s*endverbatim\>/ keepend contains=@colortemplatevim
syn region colortemplateAux   matchgroup=colortemplateVerb start=/^\s*auxfile\s\+.*$/ end=/^\s*endauxfile\>/ keepend contains=@colortemplatevim
syn region colortemplateConst matchgroup=colortemplateConst start=/#const\>/ end=/$/ keepend contains=@colortemplatevim

syn include @colortemplatehelp syntax/help.vim
unlet b:current_syntax
syn region colortemplateHelp matchgroup=colortemplateVerb start=/helpfile/ end=/endhelpfile/ keepend contains=@colortemplatehelp

hi def link colortemplateArrow        Delimiter
hi def link colortemplateAttr         Label
hi def link colortemplateConst        PreProc
hi def link colortemplateConstant     Type
hi def link colortemplateComment      Comment
hi def link colortemplateDiscrName    Identifier
hi def link colortemplateFunction     Function
hi def link colortemplateRgbName      String
hi def link colortemplateSpecial      String
hi def link colortemplateHexColor     Constant
hi def link colortemplateHiGroup      Constant
hi def link colortemplateHiGroupDef   Keyword
hi def link colortemplateNumber       Number
hi def link colortemplateKey          Special
hi def link colortemplateKeyword      Keyword
hi def link colortemplateSpecial      Boolean
hi def link colortemplateTermCode     String
hi def link colortemplateTodo         Todo
hi def link colortemplateVariant      PreProc
hi def link colortemplateVerb         Title

b:current_syntax = "colortemplate"

# vim: nowrap et ts=2 sw=2
