vim9script
# Source me to run the tests!

import 'libtinytest.vim' as tt

const TESTDIR = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const LOGFILE = TESTDIR .. '/test.log'

# Test files
tt.dryrun = true
source <sfile>:h/test_colorscheme.vim
source <sfile>:h/test_parser.vim
source <sfile>:h/test_generator.vim
tt.dryrun = false

# Runner!
const success = tt.Run(get(g:, 'test', ''))

# Cleanup
if get(g:, 'autotest', 0)
  if success
    delete(LOGFILE)
    qall!
  else
    execute "write" LOGFILE
    cquit
  endif
endif

# vim: nowrap et ts=2 sw=2
