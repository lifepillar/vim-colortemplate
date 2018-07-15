" Name:        Colortemplate
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:current_syntax")
  finish
endif

syn case ignore
syn sync fromstart


syn match colortemplateInfoTitle /^{{{.*$/
syn match colortemplateInfoW3C /\D[0123]\.\d\+\|\D4\.[01234]\d\+/ contained
syn match colortemplateInfoW3C /\%<23c█/ contained
syn match colortemplateInfoISO /\D[012]\.\d\+/ contained
syn match colortemplateInfoISO /\%>23c█/ contained
syn match colortemplateInfoBright /\D\d\d\?\.\d\+\|\D1\%([01]\d\|2[01234]\)\.\d\+/ contained
syn match colortemplateInfoColDif /\D\d\d\?\.\d\+\|\D[1234]\d\d\.\d\+/ contained

" Must be after syn match colortemplateInfoTitle
syn region colortemplateInfoCRM start=/{{{ Contrast Ratio/ end=/}}} Contrast Ratio/ contains=colortemplateInfoTitle,colortemplateInfoW3C,colortemplateInfoISO
syn region colortemplateInfoBDM start=/{{{ Brightness Dif/ end=/}}} Brightness Dif/ contains=colortemplateInfoTitle,colortemplateInfoBright
syn region colortemplateInfoCDM start=/{{{ Color Diff/ end=/}}} Color Diff/ contains=colortemplateInfoTitle,colortemplateInfoColDif

hi def link colortemplateInfoBright Constant
hi def link colortemplateInfoColDif Constant
hi def link colortemplateInfoISO Special
hi def link colortemplateInfoW3C Constant
hi def link colortemplateInfoTitle Title

