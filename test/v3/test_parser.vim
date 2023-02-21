vim9script

import 'libtinytest.vim' as tt
import 'librelalg.vim' as ra
import '../../autoload/v3/parser.vim' as parser
import '../../autoload/v3/colorscheme.vim'

const Parse = parser.Parse
const Metadata = colorscheme.Metadata
const Database = colorscheme.Database

def Test_Parser_Background()
  const res = Parse("Background: dark")

  assert_equal(v:t_dict, type(res))
  assert_equal(['dark', 'light', 'meta', 'result'], sort(keys(res)))

  const result: parser.Result = res.result
  const meta:   Metadata      = res.meta

  assert_true(result.success)
  assert_true(meta.backgrounds.dark)
  assert_false(meta.backgrounds.light)
enddef

def Test_Parser_LinkedGroup()
  const res = Parse("Background: dark Variants: 256\nDefine/256 -> Conditional")
  const result: parser.Result = res.result
  const meta:   Metadata      = res.meta
  const dbase:  Database      = res.dark

  assert_true(result.success)
  assert_true(meta.backgrounds.dark)
  assert_false(meta.backgrounds.light)
  assert_equal(['256'], meta.variants)

  const r = ra.Query(dbase.LinkedGroup->ra.Select((t) => t.HiGroupName == 'Define'))

  assert_equal('Conditional', r[0]['TargetGroup'])
enddef


tt.Run('_Parser_')
