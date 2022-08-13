vim9script

# Name:        Colorscheme template
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     Vim license (see `:help license`)

if exists("b:did_ftplugin")
  finish
endif

b:did_ftplugin = 1

b:colortemplate_outdir = empty(expand('%:p:h')) ? getcwd() : expand('%:p:h')

if b:colortemplate_outdir =~? '\m\%(color\)\=templates\=$'
  b:colortemplate_outdir = fnamemodify(b:colortemplate_outdir, ':h')
endif

if get(g:, 'colortemplate_rtp', 1)
  execute 'set runtimepath^=' .. b:colortemplate_outdir
endif

setlocal commentstring=;%s
setlocal omnifunc=syntaxcomplete#Complete

if exists('b:undo_ftplugin')
  b:undo_ftplugin ..= '|'
else
  b:undo_ftplugin = ''
endif

b:undo_ftplugin ..= 'unlet! b:colortemplate_outdir|setl commentstring< omnifunc<'

if has('balloon_eval') || has('balloon_eval_term')
  setlocal balloonexpr=colortemplate#syn#balloonexpr()
  b:undo_ftplugin = "|setl balloonexpr<"
endif

if !get(g:, 'colortemplate_no_mappings', get(g:, 'no_plugin_maps', 0))
  nnoremap <silent> <buffer> ga    <scriptcmd>call colortemplate#getinfo(v:count1)<cr>
  nnoremap <silent> <buffer> <c-l> <scriptcmd>call colortemplate#toolbar#show()<cr><c-l>
  nnoremap <silent> <buffer> gl    <scriptcmd>call colortemplate#syn#toggle()<cr>
  nnoremap <silent> <buffer> gx    <scriptcmd>call colortemplate#approx_color(v:count1)<cr>
  nnoremap <silent> <buffer> gy    <scriptcmd>call colortemplate#nearby_colors(v:count1)<cr>
  if has('popupwin') && has('textprop')
    nnoremap <silent> <buffer> gs    <scriptcmd>call colortemplate#style#open()<cr>
  endif
endif

command! -buffer -nargs=? -bar -bang -complete=dir Colortemplate silent call colortemplate#make(<q-args>, "<bang>")
command! -buffer -nargs=? -bar -bang -complete=dir ColortemplateAll silent call colortemplate#build_dir(<q-args>, "<bang>")
command! -buffer -nargs=0 -bar                     ColortemplateCheck call colortemplate#validate()
command! -buffer -nargs=0                          ColortemplateOutdir call colortemplate#askoutdir()
command! -buffer -nargs=0 -bar                     ColortemplateStats call colortemplate#stats()

if has('popupwin') && has('textprop')
  command! -nargs=? -bar -complete=highlight ColortemplateStyle call colortemplate#style#open(<q-args>)
endif

if get(g:, 'colortemplate_toolbar', 1) && (has('patch-8.0.1123') && has('menu'))
  augroup colortemplate
    autocmd!
    autocmd BufEnter,WinEnter *.colortemplate call colortemplate#toolbar#show()
    autocmd BufLeave,WinLeave *.colortemplate call colortemplate#toolbar#hide()
  augroup END
endif

call colortemplate#toolbar#show()

# vim: foldmethod=marker nowrap et ts=2 sw=2
