vim9script

# Name:        Colortemplate
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     MIT

if exists("b:did_ftplugin")
  finish
endif

b:did_ftplugin = 1

import 'libpath.vim' as path
import autoload '../autoload/colortemplate.vim'      as colortemplate
import autoload '../autoload/colortemplate/util.vim' as util

if exists('b:undo_ftplugin') && !empty(b:undo_ftplugin)
  b:undo_ftplugin ..= '|'
else
  b:undo_ftplugin = ''
endif

b:undo_ftplugin ..= 'unlet! b:colortemplate_outdir|setl cms< com< fo< ofu<'

setlocal comments=:;
setlocal commentstring=;%s
setlocal formatoptions=cjloqr1
setlocal omnifunc=syntaxcomplete#Complete

if has('balloon_eval') || has('balloon_eval_term')
  setlocal balloonexpr=colortemplate#util#BalloonExpr()
  b:undo_ftplugin = "|setl balloonexpr<"
endif

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

    colortemplate.SetOutputDir(outdir)
  endif
enddef

g:InitOutputDir()

if !get(g:, 'colortemplate_no_mappings', get(g:, 'no_plugin_maps', 0))
  nnoremap <silent> <buffer> <c-l> <scriptcmd>colortemplate.GetToolbar().Show()<cr><c-l>
  nnoremap <silent> <buffer> ga    <scriptcmd>util.GetColorInfo(v:count1)<cr>
  nnoremap <silent> <buffer> gl    <scriptcmd>util.ToggleHighlightInfo()<cr>
  nnoremap <silent> <buffer> gx    <scriptcmd>util.ApproximateColor(v:count1)<cr>
  nnoremap <silent> <buffer> gy    <scriptcmd>util.NearbyColors(v:count1)<cr>

  if exists(':StylePicker') > 0
    nnoremap <silent> <buffer> gs    <scriptcmd>StylePicker<cr>
  endif
endif

command! -buffer -nargs=? -bar -bang -complete=dir Colortemplate       silent colortemplate.Build(bufnr(), <q-args>, "<bang>")
command! -buffer -nargs=? -bar -bang -complete=dir ColortemplateAll    silent colortemplate.BuildAll(<q-args>, "<bang>")
command! -buffer -nargs=0 -bar                     ColortemplateCheck  colortemplate.Validate(bufnr())
command! -buffer -nargs=0                          ColortemplateOutdir colortemplate.AskOutputDir()
command! -buffer -nargs=0 -bar                     ColortemplateStats  colortemplate.Stats()
command! -buffer -nargs=0 -bar                     ColortemplateSource colortemplate.ViewSource(bufnr())
command! -buffer -nargs=0 -bar                     ColortemplateShow   colortemplate.ShowColorscheme(bufnr())
command! -buffer -nargs=0 -bar                     ColortemplateHide   colortemplate.HideColorscheme()
command! -buffer -nargs=0 -bar                     ColortemplateTest   colortemplate.ColorTest(bufnr())
command! -buffer -nargs=0 -bar                     ColortemplateHiTest colortemplate.HighlightTest(bufnr())

augroup colortemplate
  autocmd!
  autocmd BufWritePost *.colortemplate g:InitOutputDir()
augroup END

if get(g:, 'colortemplate_toolbar', true) && has('menu')
  augroup colortemplate
    autocmd BufEnter,WinEnter *.colortemplate colortemplate.GetToolbar().Show()
    autocmd BufLeave,WinLeave *.colortemplate colortemplate.GetToolbar().Hide()
  augroup END
endif

colortemplate.GetToolbar().Show()

# vim: foldmethod=marker nowrap et ts=2 sw=2
