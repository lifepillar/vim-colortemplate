#!/bin/sh
echo 'Running tests...'
vim --not-a-term -N -u NONE -n                           \
  --cmd 'set rtp+=~/.vim/pack/devel/start/colortemplate' \
  --cmd 'set rtp+=~/.vim/pack/devel/start/libcolor'      \
  --cmd 'set rtp+=~/.vim/pack/devel/start/libparser'     \
  --cmd 'set rtp+=~/.vim/pack/devel/start/libpath'       \
  --cmd 'set rtp+=~/.vim/pack/devel/start/librelalg'     \
  --cmd 'set rtp+=~/.vim/pack/devel/start/libtinytest'   \
  --cmd 'set rtp+=~/.vim/pack/devel/start/libversion'    \
  -c 'filetype plugin on'                                \
  -c 'syntax on'                                         \
  -c 'let g:autotest=1'                                  \
  -c 'source%'                                           \
  $HOME/.vim/pack/devel/start/colortemplate/test/runtests.vim >/dev/null 2>&1

