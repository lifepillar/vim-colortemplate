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
syn match colortemplateInfoW3C /\D\zs\%([0123]\.\d\+\|4\.[01234]\d\+\)/ contained
syn match colortemplateInfoW3C /\%<23c█/ contained
syn match colortemplateInfoISO /\D\zs[012]\.\d\+/ contained
syn match colortemplateInfoISO /\%>23c█/ contained
syn match colortemplateInfoBright /\D\zs\%(\d\d\?\.\d\+\|1\%([01]\d\|2[01234]\)\.\d\+\)/ contained
syn match colortemplateInfoColDif /\D\zs\%(\d\d\?\.\d\+\|[1234]\d\d\.\d\+\)/ contained
syn match colortemplateInfoUsedBy /Used by.*$/ contained
syn match colortemplateInfoCR /CR:\zs[012]\.\d\+/ contained
syn match colortemplateInfoCB /CB:\zs\%(\d\d\?\.\d\+\|1\%([01]\d\|2[01234]\)\.\d\+\)/ contained
syn match colortemplateInfoCD /CD:\zs\%(\d\d\?\.\d\+\|[1234]\d\d\.\d\+\)/ contained

syn region colortemplateInfoDLT matchgroup=colortemplateInfoTitle start=/^{{{ Color Sim.*$/ end=/^}}} Color Sim.*$/ contains=colortemplateInfoTitle,colortemplateInfoDelta keepend
syn region colortemplateInfoCRM matchgroup=colortemplateInfoTitle start=/^{{{ Contrast.*$/ end=/^}}} Contrast.*$/ contains=colortemplateInfoTitle,colortemplateInfoW3C,colortemplateInfoISO keepend
syn region colortemplateInfoCRT matchgroup=colortemplateInfoTitle start=/^{{{ Critical.*$/ end=/^}}} Critical.*$/ contains=colortemplateInfoTitle,colortemplateInfoUsedBy,colortemplateInfoCR,colortemplateInfoCD,colortemplateInfoCB keepend
syn region colortemplateInfoBDM matchgroup=colortemplateInfoTitle start=/^{{{ Brightness.*$/ end=/^}}} Brightness.*$/ contains=colortemplateInfoTitle,colortemplateInfoBright keepend
syn region colortemplateInfoCDM matchgroup=colortemplateInfoTitle start=/^{{{ Color Diff.*$/ end=/^}}} Color Diff.*$/ contains=colortemplateInfoTitle,colortemplateInfoColDif keepend

hi def link colortemplateInfoDelta Keyword
hi def link colortemplateInfoBright Keyword
hi def link colortemplateInfoColDif Keyword
hi def link colortemplateInfoISO Special
hi def link colortemplateInfoCR colortemplateInfoISO
hi def link colortemplateInfoCB colortemplateInfoBright
hi def link colortemplateInfoCD colortemplateInfoColDif
hi def link colortemplateInfoW3C Keyword
hi def link colortemplateInfoTitle Title
hi def link colortemplateInfoUsedBy Comment

" vim: nowrap et ts=2 sw=2
