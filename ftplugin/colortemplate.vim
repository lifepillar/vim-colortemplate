" Name:        Colorscheme template
" Author:      Lifepillar <lifepillar@lifepillar.me>
" Maintainer:  Lifepillar <lifepillar@lifepillar.me>
" License:     Vim license (see `:help license`)

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:undo_ftplugin = "setlocal commentstring< omnifunc< | unlet! b:colortemplate_outdir"
let b:undo_ftplugin = (exists('b:undo_ftplugin') ? b:undo_ftplugin . '|' : '') . s:undo_ftplugin

let b:colortemplate_outdir = empty(expand('%:p:h')) ? getcwd() : expand('%:p:h')
if b:colortemplate_outdir =~? '\m\%(color\)\=templates\=$'
  let b:colortemplate_outdir = fnamemodify(b:colortemplate_outdir, ':h')
endif
if get(g:, 'colortemplate_rtp', 1)
  execute 'set runtimepath^='.b:colortemplate_outdir
endif

setlocal commentstring=#%s
setlocal omnifunc=syntaxcomplete#Complete

if !get(g:, 'colortemplate_no_mappings', get(g:, 'no_plugin_maps', 0))
  nnoremap <silent> <buffer> ga    :<c-u>call colortemplate#getinfo(v:count1)<cr>
  nnoremap <silent> <buffer> <c-l> :<c-u>call colortemplate#toolbar#show()<cr><c-l>
  nnoremap <silent> <buffer> gx    :<c-u>call colortemplate#approx_color(v:count1)<cr>
  nnoremap <silent> <buffer> gy    :<c-u>call colortemplate#nearby_colors(v:count1)<cr>
endif

command! -buffer -nargs=? -bar -bang -complete=dir Colortemplate silent call colortemplate#make(<q-args>, "<bang>")
command! -buffer -nargs=? -bar -bang -complete=dir ColortemplateAll silent call colortemplate#build_dir(<q-args>, "<bang>")
command! -buffer -nargs=0 -bar                     ColortemplateCheck call colortemplate#validate()
command! -buffer -nargs=0                          ColortemplateOutdir call colortemplate#askoutdir()
command! -buffer -nargs=0 -bar                     ColortemplateStats call colortemplate#stats()

if has('patch-8.1.1705')
  command! -nargs=0 -bar ColortemplateStyle call colortemplate#style_popup#open()
endif

if get(g:, 'colortemplate_toolbar', 1) && (has('patch-8.0.1123') && has('menu')) " does it have window-toolbar?
  augroup colortemplate
    autocmd!
    autocmd BufEnter,WinEnter *.colortemplate call colortemplate#toolbar#show()
    autocmd BufLeave,WinLeave *.colortemplate call colortemplate#toolbar#hide()
  augroup END
endif

call colortemplate#toolbar#show()

" vim: foldmethod=marker nowrap et ts=2 sw=2
