" Name:        Colorscheme template
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:undo_ftplugin = "setlocal commentstring< omnifunc< | unlet! b:colortemplate_wd"
let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . '|' : '') . s:undo_ftplugin

let b:colortemplate_wd = empty(expand('%:p:h')) ? getcwd() : expand('%:p:h')
if b:colortemplate_wd =~? '\m\%(color\)\=templates\=$'
  let b:colortemplate_wd = fnamemodify(b:colortemplate_wd, ':h')
endif

" TODO: map ctrl-l to show the toolbar

setlocal commentstring=#%s
setlocal omnifunc=syntaxcomplete#Complete

command! -buffer -nargs=? -bar -bang -complete=dir Colortemplate call colortemplate#make(<q-args>, "<bang>")

call colortemplate#toolbar#show()

" vim: foldmethod=marker nowrap
