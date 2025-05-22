vim9script

import 'libpath.vim'                               as path
import 'libtinytest.vim'                           as tt
import '../autoload/colortemplate.vim'             as colortemplate
import '../import/colortemplate/generator/vim.vim' as vim9generator

# Helper functions {{{
const TESTDIR = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const COLDIR  = path.Join(TESTDIR, 'colors')
const DOCDIR  = path.Join(TESTDIR, 'doc')
const EXPDIR  = path.Join(TESTDIR, 'expected')

var generator = vim9generator.Generator.new()

generator.SetLanguage('viml')


def Verify(name: string)
  var output   = path.Join(COLDIR, $'{name}.vim')
  var expected = path.Join(EXPDIR, $'{name}.vim')

  assert_true(path.Exists(output),   $'Output not found at {output}')
  assert_true(path.Exists(expected), $'Expected output not found at {expected}')

  var fail = assert_equalfile(expected, output)

  if !fail
    delete(output)
  endif
enddef

def AssertBuild(name: string)
  var template = path.Join(TESTDIR, 'templates', name .. '.txt')

  execute 'split' template

  var bufnr = bufnr("%")
  var success = colortemplate.Build(bufnr('%'), TESTDIR, '!', {generator: generator})

  assert_true(success, 'Template failed to build.')

  execute $':{bufnr}bwipe'

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

def Test_VimLGenerator_30()
  AssertBuild('test30')

  var helpfile = path.Join(DOCDIR, 'test30.txt')

  assert_true(path.Exists(helpfile))
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

def Test_VimLGenerator_41()
  AssertBuild('test41')
enddef

def Test_VimLGenerator_42()
  AssertBuild('test42')
enddef

def Test_VimLGenerator_43()
  AssertBuild('test43')
enddef

def Test_VimLGenerator_44()
  AssertBuild('test44a')
enddef

def Test_VimLGenerator_46()
  AssertBuild('test46a')
enddef

def Test_VimLGenerator_50b()
  AssertBuild('test50b')
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

def Test_VimLGenerator_70()
  AssertBuild('test70')
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

def Test_VimLGenerator_93()
  AssertBuild('test-93')
enddef

def Test_VimLGenerator_94()
  AssertBuild('test94')
enddef


var results = tt.Run('_VimLGenerator_')

delete(COLDIR, "d") # Delete if empty
delete(DOCDIR, "rf")

