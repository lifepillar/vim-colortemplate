vim9script
# Source me to run the tests!

import 'libtinytest.vim' as tt

# Constants and helper functions {{{
const TESTDIR = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const COLDIR  = TESTDIR .. '/colors'
const DOCDIR  = TESTDIR .. '/doc'
const EXPDIR  = TESTDIR .. '/expected'
const LOGFILE = TESTDIR .. '/test.log'
const EPS     = 0.000001

def Round(num: number, digits: number): number
  return str2float(printf('%.0' .. a:digits .. 'f', num))
enddef

def Verify(f: string)
  const colscheme = printf('%s/%s.vim', COLDIR, f)
  const fail = assert_equalfile(printf('%s/%s.vim', EXPDIR, f), colscheme)
  if !fail
    delete(colscheme)
  endif
enddef

def AssertBuild(name: string)
  const template = a:name .. '.txt'
  execute 'edit' template
  Colortemplate!
  assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  Verify(name)
  execute 'bwipe' template
enddef
# }}}

# Test files
source <sfile>:h/test_colorscheme.vim
source <sfile>:h/test_parser.vim
source <sfile>:h/test_generator.vim

# Runner!
const success = tt.Run(get(g:, 'test', 'CT'))

# Cleanup {{{
delete(COLDIR, "d") # Delete if empty
delete(DOCDIR, "rf")

if get(g:, 'autotest', 0)
  if success
    delete(LOGFILE)
    qall!
  else
    execute "write" LOGFILE
    cquit
  endif
endif
# }}}

# vim: nowrap et ts=2 sw=2
