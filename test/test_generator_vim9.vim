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
  var template = path.Join(TESTDIR, 'templates', name .. '.colortemplate')

  execute 'split' template

  var bufnr = bufnr("%")
  var success = colortemplate.Build(bufnr('%'), TESTDIR, '!', {
    generator: vim9generator.Generator.new(),
  })

  assert_true(success, 'Template unexpectedly failed to build.')

  execute $':{bufnr}bwipe'

  Verify(name)
enddef
# }}}

def Test_Vim9Generator_001()
  AssertBuild('test001')
enddef

def Test_Vim9Generator_002()
  AssertBuild('test002')
enddef

def Test_Vim9Generator_003()
  AssertBuild('test003')
enddef
def Test_Vim9Generator_004()
  AssertBuild('test004')
enddef

var results = tt.Run('_Vim9Generator_')

delete(COLDIR, "d") # Delete if empty
delete(DOCDIR, "rf")
