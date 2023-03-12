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
var result: dict<any>


tt.Run('_Generator_')

