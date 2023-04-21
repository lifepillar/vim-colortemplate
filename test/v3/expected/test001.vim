vim9script

# Name:         Test 001
# Authors:      No One

set background=dark

hi clear
g:colors_name = 'test001'

const t_Co = exists('&t_Co') && !has('gui_running') ? (str2nr(&t_Co) ?? 0) : -1

g:terminal_ansi_colors = []

hi Normal guifg=#fafafa guibg=#333333 guisp=NONE gui=NONE cterm=NONE

# vim: nowrap et sw=2
