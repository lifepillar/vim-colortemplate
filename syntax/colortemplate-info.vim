" Name:        Colortemplate
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:current_syntax")
  finish
endif

syn case ignore
syn sync fromstart


syn match colortemplateInfoTitle /^\%({{{\|}}}\).*$/
syn match colortemplateInfoDelta /\[delta=\%(\d\d\.\d\+\|[3456789]\.\d\+\|2\.[456789]\d*\)\]/ contained
syn match colortemplateInfoW3C /\D[0123]\.\d\+\|\D4\.[01234]\d\+/ contained
syn match colortemplateInfoW3C /\%<23c█/ contained
syn match colortemplateInfoISO /\D[012]\.\d\+/ contained
syn match colortemplateInfoISO /\%>23c█/ contained
syn match colortemplateInfoBright /\D\d\d\?\.\d\+\|\D1\%([01]\d\|2[01234]\)\.\d\+/ contained
syn match colortemplateInfoColDif /\D\d\d\?\.\d\+\|\D[1234]\d\d\.\d\+/ contained

syn region colortemplateInfoDLT matchgroup=colortemplateInfoTitle start=/^{{{ Color Sim.*$/ end=/^}}} Color Sim.*$/ contains=colortemplateInfoTitle,colortemplateInfoDelta keepend
syn region colortemplateInfoCRM matchgroup=colortemplateInfoTitle start=/^{{{ Contrast.*$/ end=/^}}} Contrast.*$/ contains=colortemplateInfoTitle,colortemplateInfoW3C,colortemplateInfoISO keepend
syn region colortemplateInfoBDM matchgroup=colortemplateInfoTitle start=/^{{{ Brightness.*$/ end=/^}}} Brightness.*$/ contains=colortemplateInfoTitle,colortemplateInfoBright keepend
syn region colortemplateInfoCDM matchgroup=colortemplateInfoTitle start=/^{{{ Color Diff.*$/ end=/^}}} Color Diff.*$/ contains=colortemplateInfoTitle,colortemplateInfoColDif keepend

hi def link colortemplateInfoDelta Special
hi def link colortemplateInfoBright Special
hi def link colortemplateInfoColDif Special
hi def link colortemplateInfoISO WarningMsg
hi def link colortemplateInfoW3C Special
hi def link colortemplateInfoTitle Title

