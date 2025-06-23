vim9script

import 'libpath.vim'                                as path
import 'libtinytest.vim'                            as tt
import '../autoload/colortemplate.vim'              as colortemplate
import '../import/colortemplate/generator/vim.vim'  as vimgenerator

# Helper functions {{{
const TESTDIR = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const COLDIR  = path.Join(TESTDIR, 'colors')
const DOCDIR  = path.Join(TESTDIR, 'doc')
const EXPDIR  = path.Join(TESTDIR, 'expected')

def Verify(name: string)
  var output            = path.Join(COLDIR, $'{name}.vim')
  var expected_output   = path.Join(EXPDIR, $'{name}.vim')
  var helpfile          = path.Join(DOCDIR, $'{name}.txt')
  var expected_helpfile = path.Join(EXPDIR, $'{name}.txt')

  var fail: bool = assert_equalfile(expected_output, output)

  if filereadable(helpfile)
    fail = fail || assert_equalfile(expected_helpfile, helpfile)
  endif

  if !fail
    delete(output)
    delete(helpfile)
  endif
enddef

def AssertBuild(name: string)
  var template = path.Join(TESTDIR, 'templates', name .. '.colortemplate')

  execute 'split' template

  var bufnr = bufnr("%")
  var success: bool

  try
    success = colortemplate.Build(bufnr('%'), TESTDIR, '!', {backend: 'vim'})
  finally
    execute $':{bufnr}bwipe'
  endtry

  assert_true(success, 'Template failed to build.')

  Verify(name)
enddef
# }}}

def Test_VimGenerator_1()
  AssertBuild('test1')
enddef

def Test_VimGenerator_5()
  AssertBuild('test5')
enddef

def Test_VimGenerator_7()
  AssertBuild('test7')
enddef

def Test_VimGenerator_22()
  AssertBuild('test22')
enddef

def Test_VimGenerator_24()
  AssertBuild('test24')
enddef

def Test_VimGenerator_27()
  AssertBuild('test27')
enddef

def Test_VimGenerator_28()
  AssertBuild('test28')
enddef

def Test_VimGenerator_29()
  AssertBuild('test29')
enddef

def Test_VimGenerator_30()
  AssertBuild('test30')
enddef

def Test_VimGenerator_34()
  AssertBuild('test34')
enddef

def Test_VimGenerator_37()
  AssertBuild('test37')
enddef

def Test_VimGenerator_38()
  AssertBuild('test38a')
enddef

def Test_VimGenerator_39()
  AssertBuild('test39a')
enddef

def Test_VimGenerator_41()
  AssertBuild('test41')
enddef

def Test_VimGenerator_42()
  AssertBuild('test42')
enddef

def Test_VimGenerator_44()
  AssertBuild('test44a')
enddef

def Test_VimGenerator_46()
  AssertBuild('test46a')
enddef

def Test_VimGenerator_48()
  AssertBuild('test48a')
enddef

def Test_VimGenerator_49()
  AssertBuild('test49a')
enddef

def Test_VimGenerator_50()
  AssertBuild('test50')
enddef

def Test_VimGenerator_51()
  AssertBuild('test51')
enddef

def Test_VimGenerator_52()
  AssertBuild('test52')
enddef

def Test_VimGenerator_53()
  AssertBuild('test53')
enddef

def Test_VimGenerator_65()
  AssertBuild('test65')
enddef

def Test_VimGenerator_68a()
  AssertBuild('test68a')
enddef

def Test_VimGenerator_69()
  AssertBuild('test69')
enddef

def Test_VimGenerator_70()
  AssertBuild('test70')
enddef

def Test_VimGenerator_71()
  AssertBuild('test71')
enddef

def Test_VimGenerator_72()
  AssertBuild('test72')
enddef

def Test_VimGenerator_73()
  AssertBuild('test73')
enddef

def Test_VimGenerator_74()
  AssertBuild('test74')
enddef

# See: https://github.com/lifepillar/vim-colortemplate/issues/36
# When defining a base 256 color as 0 (code for terminal black) with Color and
# then setting a highlight to it, it used to be ignored.
def Test_VimGenerator_77()
  AssertBuild('test77')
enddef

def Test_VimGenerator_78()
  AssertBuild('test78')
enddef

def Test_VimGenerator_79()
  AssertBuild('test79')
enddef

def Test_VimGenerator_82()
  AssertBuild('test82')
enddef

def Test_VimGenerator_84()
  AssertBuild('test84')
enddef

def Test_VimGenerator_85()
  AssertBuild('test85')
enddef

def Test_VimGenerator_86()
  AssertBuild('test86')
enddef

def Test_VimGenerator_88()
  AssertBuild('test88')
enddef

def Test_VimGenerator_89()
  AssertBuild('test89')
enddef

def Test_VimGenerator_93()
  AssertBuild('test-93')
enddef

def Test_VimGenerator_94()
  AssertBuild('test94')
enddef


var results = tt.Run('_VimGenerator_')

delete(COLDIR, "d")
delete(DOCDIR, "d")
