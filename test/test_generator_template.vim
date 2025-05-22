vim9script

import 'libpath.vim'                                    as path
import 'libtinytest.vim'                                as tt
import '../autoload/colortemplate.vim'                  as colortemplate
import '../import/colortemplate/generator/template.vim' as templategenerator

# Helper functions {{{
const TESTDIR = fnamemodify(resolve(expand('<sfile>:p')), ':h')
const OUTDIR  = path.Join(TESTDIR, 'out')
const EXPDIR  = path.Join(TESTDIR, 'expected')

def Verify(name: string)
  var output   = path.Join(OUTDIR, $'{name}.colortemplate')
  var expected = path.Join(EXPDIR, $'{name}.colortemplate')

  assert_true(path.Exists(output),   $'Output not found at {output}')
  assert_true(path.Exists(expected), $'Expected output not found at {expected}')

  var fail = assert_equalfile(expected, output)

  if !fail
    delete(output)
  endif
enddef

def AssertGenerateTemplate(name: string)
  var template = path.Join(TESTDIR, 'templates', name .. '.colortemplate')

  execute 'split' template

  var bufnr = bufnr("%")
  var success = colortemplate.Build(bufnr, OUTDIR, '!', {
    generator: templategenerator.Generator.new(),
    filesuffix: '.colortemplate'
  })

  assert_true(success, 'Template unexpectedly failed to build.')

  execute $':{bufnr}bwipe'

  Verify(name)
enddef
# }}}

def Test_Template_Generator_001()
  AssertGenerateTemplate('test001')
enddef

def Test_Template_Generator_002()
  AssertGenerateTemplate('test002')
enddef


tt.Run('_Template_')

delete(OUTDIR, "d") # Delete if empty
