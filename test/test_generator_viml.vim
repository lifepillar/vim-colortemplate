vim9script

import 'libpath.vim'                                as path
import 'libtinytest.vim'                            as tt
import '../autoload/colortemplate.vim'              as colortemplate
import '../import/colortemplate/generator/viml.vim' as vimlgenerator

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
  var template = path.Join(TESTDIR, 'templates', name .. '.txt')

  execute 'split' template

  var bufnr = bufnr("%")
  var success: bool

  try
    success = colortemplate.Build(bufnr('%'), TESTDIR, '!', {backend: 'viml'})
  finally
    execute $':{bufnr}bwipe'
  endtry

  assert_true(success, 'Template failed to build.')

  Verify(name)
enddef
# }}}

def Test_VimLGenerator_1()
  AssertBuild('test1')
enddef

def Test_VimLGenerator_5()
  AssertBuild('test5')
enddef

def Test_VimLGenerator_7()
  AssertBuild('test7')
enddef

def Test_VimLGenerator_22()
  AssertBuild('test22')
enddef

def Test_VimLGenerator_24()
  AssertBuild('test24')
enddef

def Test_VimLGenerator_27()
  AssertBuild('test27')
enddef

def Test_VimLGenerator_28()
  AssertBuild('test28')
enddef

def Test_VimLGenerator_29()
  AssertBuild('test29')
enddef

def Test_VimLGenerator_30()
  AssertBuild('test30')
enddef

def Test_VimLGenerator_34()
  AssertBuild('test34')
enddef

def Test_VimLGenerator_37()
  AssertBuild('test37')
enddef

def Test_VimLGenerator_38()
  AssertBuild('test38a')
enddef

def Test_VimLGenerator_39()
  AssertBuild('test39a')
enddef

def Test_VimLGenerator_41()
  AssertBuild('test41')
enddef

def Test_VimLGenerator_42()
  AssertBuild('test42')
enddef

def Test_VimLGenerator_44()
  AssertBuild('test44a')
enddef

def Test_VimLGenerator_46()
  AssertBuild('test46a')
enddef

def Test_VimLGenerator_48()
  AssertBuild('test48a')
enddef

def Test_VimLGenerator_49()
  AssertBuild('test49a')
enddef

def Test_VimLGenerator_50()
  AssertBuild('test50')
enddef

def Test_VimLGenerator_51()
  AssertBuild('test51')
enddef

def Test_VimLGenerator_52()
  AssertBuild('test52')
enddef

def Test_VimLGenerator_53()
  AssertBuild('test53')
enddef

def Test_VimLGenerator_65()
  AssertBuild('test65')
enddef

def Test_VimLGenerator_68a()
  AssertBuild('test68a')
enddef

def Test_VimLGenerator_69()
  AssertBuild('test69')
enddef

def Test_VimLGenerator_70()
  AssertBuild('test70')
enddef

def Test_VimLGenerator_71()
  AssertBuild('test71')
enddef

def Test_VimLGenerator_72()
  AssertBuild('test72')
enddef

def Test_VimLGenerator_73()
  AssertBuild('test73')
enddef

def Test_VimLGenerator_74()
  AssertBuild('test74')
enddef

# See: https://github.com/lifepillar/vim-colortemplate/issues/36
# When defining a base 256 color as 0 (code for terminal black) with Color and
# then setting a highlight to it, it used to be ignored.
def Test_VimLGenerator_77()
  AssertBuild('test77')
enddef

def Test_VimLGenerator_78()
  AssertBuild('test78')
enddef

def Test_VimLGenerator_79()
  AssertBuild('test79')
enddef

def Test_VimLGenerator_82()
  AssertBuild('test82')
enddef

def Test_VimLGenerator_84()
  AssertBuild('test84')
enddef

def Test_VimLGenerator_85()
  AssertBuild('test85')
enddef

def Test_VimLGenerator_86()
  AssertBuild('test86')
enddef

def Test_VimLGenerator_88()
  AssertBuild('test88')
enddef

def Test_VimLGenerator_89()
  AssertBuild('test89')
enddef

def Test_VimLGenerator_93()
  AssertBuild('test-93')
enddef

def Test_VimLGenerator_94()
  AssertBuild('test94')
enddef


var results = tt.Run('_VimLGenerator_')

delete(COLDIR, "d")
delete(DOCDIR, "d")
