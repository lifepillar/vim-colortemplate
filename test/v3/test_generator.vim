vim9script

import 'libtinytest.vim'                 as tt
import '../../autoload/v3/parser.vim'    as parser
import '../../autoload/v3/generator.vim' as generator

const Parse    = parser.Parse
const Generate = generator.Generate

# assert_fails() logs exceptions in messages. This function is quiet.
def AssertFails(what: string, expectedError: string): void
  try
    execute what
    assert_false(1, printf("'%s' should have failed, but succeeded", what))
  catch
    assert_exception(expectedError)
  endtry
enddef

# These are defined at the script level for using with AssertFails().
# See also: https://github.com/vim/vim/issues/6868
var parseResult: dict<any>

def Test_Generator_MissingDefaultDef()
  const template =<< trim END
  Full name: X
  Short name: x
  Author: me
  Background: dark
  Variants: gui
  Debug+bar 3 -> Error
  END

  parseResult = Parse(join(template, "\n"))

  AssertFails(
    "Generate(parseResult.meta, {'dark': parseResult.dark})",
    "Missing dark default definition for Debug"
  )
enddef


tt.Run('_Generator_')

