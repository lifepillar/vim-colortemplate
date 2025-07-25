vim9script

# Name:         Test 302
# Author:       me

set background=dark

hi clear
g:colors_name = 'test302'

const t_Co = has('gui_running') ? 16777216 : str2nr(&t_Co)
const tgc = has('termguicolors') && &termguicolors

const plugin = get(g:, 'foo_opt', 0)


if has('gui_running') || tgc
  if plugin == 1
    hi! link Target Search
  endif
endif

if tgc || t_Co >= 256
  if plugin == 1
    hi! link Target Search
  endif
  finish
endif

# vim: et ts=8 sw=2 sts=2
