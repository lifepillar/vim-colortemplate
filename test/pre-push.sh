#!/bin/sh
echo 'Running tests...'
vim --not-a-term --clean -n                           \
  --cmd 'set rtp+=~/.vim/pack/my/start/colortemplate' \
  -c 'let g:autotest=1'                               \
  -c 'source%'                                        \
  $HOME/.vim/pack/my/start/colortemplate/test/runtests_v2.vim >/dev/null 2>&1

