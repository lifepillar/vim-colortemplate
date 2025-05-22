vim9script

# Name:         Test 302
# Author:       me

set background=dark

hi clear
g:colors_name = 'test302'

const plugin = get(g:, 'foo_opt', 0)


if has('gui_running') || (has('termguicolors') && &termguicolors)
  if plugin == 1
    hi! link Target Search
  endif
endif

if str2nr(&t_Co) >= 256
  if plugin == 1
    hi! link Target Search
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
