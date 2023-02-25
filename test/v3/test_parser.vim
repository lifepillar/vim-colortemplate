vim9script

import 'libtinytest.vim' as tt
import 'librelalg.vim' as ra
import '../../autoload/v3/parser.vim' as parser
import '../../autoload/v3/colorscheme.vim'

const Parse = parser.Parse
const Metadata = colorscheme.Metadata
const Database = colorscheme.Database

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
var parserInput: string

def Test_Parser_Background()
  const res = Parse("Background: dark")

  assert_equal(v:t_dict, type(res))
  assert_equal(['dark', 'light', 'meta', 'result'], sort(keys(res)))

  const result: parser.Result = res.result
  const meta:   Metadata      = res.meta

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(meta.backgrounds.dark)
  assert_false(meta.backgrounds.light)
enddef

def Test_Parser_NoDefaultLinkedGroup()
  const template =<< trim END
    Background: dark
    Variants:   256
    Define/256 -> Conditional
  END

  const res = Parse(join(template, "\n"))
  const result: parser.Result = res.result

  assert_false(result.success)
  assert_match('must override an existing Hi Group', result.label)
enddef

def Test_Parser_LinkedGroup()
  const template =<< trim END
    Background: dark
    Variants:   gui 256 16 8 0
    Define     -> Identifier
    Define/256 -> Conditional
  END

  const res = Parse(join(template, "\n"))
  const result: parser.Result = res.result
  const meta:   Metadata      = res.meta
  const dbase:  Database      = res.dark

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(meta.backgrounds.dark)
  assert_false(meta.backgrounds.light)
  assert_equal(['gui', '256', '16', '8', '0'], meta.variants)

  const r = ra.Query(
    dbase.LinkedGroup
    ->ra.Select((t) => t.HiGroupName == 'Define')
  )

  assert_equal(1, len(r))
  assert_equal('Identifier', r[0]['TargetGroup'])

  const s = ra.Query(
    dbase.LinkedGroupOverride
    ->ra.Select((t) => t.HiGroupName == 'Define')
  )
  assert_equal(1, len(s))
  assert_equal('Conditional', s[0]['TargetGroup'])
  assert_equal('256',         s[0]['Variant'])
enddef

def Test_Parser_VariantDiscriminatorOverride()
  const template =<< trim END
    Background: dark
    Variants:   gui termgui 256 8
    Color:      white #fafafa 231 White
    Normal white white
    Normal /termgui/256/8 +transp_bg 1 white none
  END
  const res = Parse(join(template, "\n"))
  const result: parser.Result = res.result

  assert_equal('', result.label)
  assert_true(result.success)
enddef


tt.Run('_Parser_')
