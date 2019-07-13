fun! s:init_toolbar()
  let g:colortemplate_toolbar_items = get(g:, 'colortemplate_toolbar_item', [
        \ 'Build!',
        \ 'BuildAll!',
        \ 'Show',
        \ 'Hide',
        \ 'Check',
        \ 'Stats',
        \ 'Source',
        \ 'HiTest',
        \ 'OutDir',
        \ ])

  let g:colortemplate_toolbar_actions = extend({
        \ 'Build!':    ':Colortemplate!<cr>',
        \ 'BuildAll!': ':ColortemplateAll!<cr>',
        \ 'Check':     ':ColortemplateCheck<cr>',
        \ 'Colortest': ':call colortemplate#colortest()<cr>',
        \ 'HiTest':    ':call colortemplate#highlighttest()<cr>',
        \ 'Hide':      ':call colortemplate#disable_colorscheme()<cr>',
        \ 'OutDir':    ':ColortemplateOutdir<cr>',
        \ 'Show':      ':call colortemplate#enable_colorscheme()<cr>',
        \ 'Source':    ':call colortemplate#view_source()<cr>',
        \ 'Stats':     ':ColortemplateStats<cr>',
        \ }, get(g:, 'colortemplate_toolbar_actions', {}))
endf

fun! colortemplate#toolbar#show()
  if get(g:, 'colortemplate_toolbar', 1) && (has('patch-8.0.1123') && has('menu')) " does it have window-toolbar?
    if getbufvar('%', '&ft') ==# 'colortemplate' && expand('%:t') !~# '\m^_'
      nunmenu WinBar
      if !exists('g:colortemplate_toolbar_items')
        call s:init_toolbar()
      endif
      let l:n = 1
      for l:entry in g:colortemplate_toolbar_items
        if has_key(g:colortemplate_toolbar_actions, l:entry)
          execute 'nnoremenu <silent> 1.'.string(l:n).' WinBar.'.escape(l:entry, '@\/ ')
                \ g:colortemplate_toolbar_actions[l:entry]
          let l:n += 1
        endif
      endfor
      nnoremenu 1.99 WinBar.✕ :nunmenu WinBar<cr>
    endif
  endif
  return ''
endf

fun! colortemplate#toolbar#hide()
  if getbufvar('%', '&ft') ==# 'colortemplate'
    nunmenu WinBar
  endif
endf

" vim: foldmethod=marker nowrap et ts=2 sw=2
