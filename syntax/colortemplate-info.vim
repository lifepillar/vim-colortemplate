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

" Must be after syn match colortemplateInfoTitle
syn region colortemplateInfoCRM start=/{{{ Contrast Ratio/ end=/}}} Contrast Ratio/ contains=colortemplateInfoTitle,colortemplateInfoW3C,colortemplateInfoISO

hi def link colortemplateInfoISO Special
hi def link colortemplateInfoW3C Constant
hi def link colortemplateInfoTitle Title

