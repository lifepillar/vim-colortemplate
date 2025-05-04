vim9script

# Name:        Colortemplate
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     Vim license (see `:help license`)

import 'libpath.vim' as path
import autoload '../autoload/colortemplate.vim' as ctemplate
import autoload '../autoload/util.vim'          as util

if exists("b:did_ftplugin")
  finish
endif

b:did_ftplugin = 1

setlocal comments=:;
setlocal commentstring=;%s
setlocal formatoptions=cjloqr1
setlocal omnifunc=syntaxcomplete#Complete

def g:InitOutputDir()
  if empty(get(b:, 'colortemplate_outdir', ''))
    b:colortemplate_outdir = ''  # Ensure that the variable exists

    if empty(expand('%:p'))
      return
    endif

    var outdir = expand('%:p:h')

    if path.Basename(outdir) =~? '\m^\%(color\)\=templates\=$'
      outdir = path.Parent(outdir)
    endif

    ctemplate.SetOutputDir(outdir)
  endif
enddef

g:InitOutputDir()

if exists('b:undo_ftplugin')
  b:undo_ftplugin ..= '|'
else
  b:undo_ftplugin = ''
endif

b:undo_ftplugin ..= 'unlet! b:colortemplate_outdir|setl cms< com< fo< ofu<'

# if has('balloon_eval') || has('balloon_eval_term')
#   setlocal balloonexpr=colortemplate#syn#balloonexpr()
#   b:undo_ftplugin = "|setl balloonexpr<"
# endif

if !get(g:, 'colortemplate_no_mappings', get(g:, 'no_plugin_maps', 0))
  nnoremap <silent> <buffer> <c-l> <scriptcmd>ctemplate.toolbar.Show()<cr><c-l>
  nnoremap <silent> <buffer> ga    <scriptcmd>util.GetColorInfo(v:count1)<cr>
  nnoremap <silent> <buffer> gl    <scriptcmd>util.ToggleHighlightInfo()<cr>
  nnoremap <silent> <buffer> gx    <scriptcmd>util.ApproximateColor(v:count1)<cr>
  nnoremap <silent> <buffer> gy    <scriptcmd>util.NearbyColors(v:count1)<cr>
  if has('popupwin') && has('textprop')
    nnoremap <silent> <buffer> gs    <scriptcmd>call colortemplate#style#open()<cr>
  endif
endif

command! -buffer -nargs=? -bar -bang -complete=dir Colortemplate       silent ctemplate.Build(bufnr(), <q-args>, "<bang>")
command! -buffer -nargs=? -bar -bang -complete=dir ColortemplateAll    silent ctemplate.BuildAll(<q-args>, "<bang>")
command! -buffer -nargs=0 -bar                     ColortemplateCheck  ctemplate.Validate(bufnr())
command! -buffer -nargs=0                          ColortemplateOutdir ctemplate.AskOutputDir()
command! -buffer -nargs=0 -bar                     ColortemplateStats  ctemplate.Stats()
command! -buffer -nargs=0 -bar                     ColortemplateSource ctemplate.ViewSource(bufnr())
command! -buffer -nargs=0 -bar                     ColortemplateShow   ctemplate.ShowColorscheme(bufnr())
command! -buffer -nargs=0 -bar                     ColortemplateHide   ctemplate.HideColorscheme()
command! -buffer -nargs=0 -bar                     ColortemplateTest   ctemplate.ColorTest(bufnr())
command! -buffer -nargs=0 -bar                     ColortemplateHiTest ctemplate.HighlightTest(bufnr())

if has('popupwin') && has('textprop')
  command! -nargs=? -bar -complete=highlight ColortemplateStyle call colortemplate#style#open(<q-args>)
endif

augroup colortemplate
  autocmd!
  autocmd BufWritePost *.colortemplate g:InitOutputDir()
augroup END

if get(g:, 'colortemplate_toolbar', true) && has('menu')
  augroup colortemplate
    autocmd BufEnter,WinEnter *.colortemplate ctemplate.toolbar.Show()
    autocmd BufLeave,WinLeave *.colortemplate ctemplate.toolbar.Hide()
  augroup END
endif

ctemplate.toolbar.Show()

# vim: foldmethod=marker nowrap et ts=2 sw=2
