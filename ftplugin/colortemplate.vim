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

setlocal commentstring=#%s
setlocal omnifunc=syntaxcomplete#Complete

if !get(g:, 'colortemplate_no_mappings', get(g:, 'no_plugin_maps', 0))
  nnoremap <silent> <buffer> ga :<c-u>call colortemplate#getinfo(v:count1)<cr>
  nnoremap <silent> <buffer> <c-l> :<c-u>call colortemplate#toolbar#show()<cr><c-l>
endif

command! -buffer -nargs=? -bar -bang -complete=dir Colortemplate call colortemplate#make(<q-args>, "<bang>")

call colortemplate#toolbar#show()

" vim: foldmethod=marker nowrap
