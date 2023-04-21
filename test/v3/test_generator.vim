vim9script

import 'libpath.vim'     as path
import 'libtinytest.vim' as tt
import '../../autoload/v3/colortemplate.vim' as ctemplate

# Helper functions {{{
const TESTDIR = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const COLDIR  = path.Join(TESTDIR, 'colors')
const DOCDIR  = path.Join(TESTDIR, 'doc')
const EXPDIR  = path.Join(TESTDIR, 'expected')

def Verify(name: string)
  const theme = printf('%s/%s.vim', COLDIR, name)
  const fail = assert_equalfile(printf('%s/%s.vim', EXPDIR, name), theme)

  if !fail
    delete(theme)
  endif
enddef

def AssertBuild(name: string)
  const template = path.Join(TESTDIR, name .. '.colortemplate')
  echo template
  execute 'edit' template
  ctemplate.Build(bufnr('%'))
  # assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  Verify(name)
  execute 'bwipe' template
enddef
# }}}

def Test_GE_Omit()
  AssertBuild('test001')
enddef


tt.Run('_GE_')

delete(COLDIR, "d") # Delete if empty
delete(DOCDIR, "rf")
