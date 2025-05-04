vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

import 'librelalg.vim'   as ra
import 'libtinytest.vim' as tt

# Aliases {{{
type Rel                   = ra.Rel
type Relation              = ra.Relation
type Tuple                 = ra.Tuple

const Int                  = ra.Int
const Recursive            = ra.Recursive
const RelEq                = ra.RelEq
const Select               = ra.Select
const Transaction          = ra.Transaction
const Transform            = ra.Transform
# }}}


def Test_RA_Perf__RecursiveCount()
  var N        = 100
  var expected = mapnew(range(N + 1), (_, i) => {
    return {n: i}
  })
  var result: Relation

  def RunQuery()
    result = Recursive(
      [{n: 0}],
      (R) => Transform(
      Select(R, (t) => t.n < N), (t) => {
        return {n: t.n + 1}
      }),
      true
    )
  enddef

  tt.AssertBenchmark(
    RunQuery,
    $'Recursive count from 0 to {N}',
    {
      repeat: 5,
      severity: {
      'Wow!': 0.0,
      '✓':    0.4,
      '✗':    0.5,
      }
    })

  assert_true(RelEq(expected, result))
enddef



def Test_RA_Perf__T1()
  var r0 = Rel.new('r0', {Node: Int, Next: Int}, [['Node']])
  var i = 0
  var I = () => {
    Transaction(() => {
      for _ in range(50000)
        r0.Insert({Node: i, Next: 2})
        ++i
      endfor
    })
  }
  tt.AssertBenchmark(I, 'Insert', {repeat: 5})
enddef

def Test_RA_Perf__Insert()
  var r0 = Rel.new('r0', {Node: Int, Next: Int}, [['Node']])
  var i = 0
  var I = () => {
    r0.Insert({Node: i, Next: 2})
    ++i
  }
  tt.AssertBenchmark(I, 'Insert', {repeat: 5})
enddef


tt.Run('_RA_Perf__')
