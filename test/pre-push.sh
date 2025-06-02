#!/bin/sh
echo 'Running tests...'
vim --not-a-term --clean -n                             \
  --cmd 'set rtp+=~/.vim/pack/deve/start/colortemplate' \
  -c 'let g:autotest=1'                                 \
  -c 'source%'                                          \
  $HOME/.vim/pack/devel/start/colortemplate/test/runtests.vim >/dev/null 2>&1

