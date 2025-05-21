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
const Str                  = ra.Str
const Float                = ra.Float
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

def Test_RA_Perf__Lookup()
  var r = Rel.new('r', {A: Int, B: Int, C: Float}, [['A'], ['B'], ['C']])
  var n = 100000

  for i in range(n)
    r.Insert({A: i, B: 2 * i, C: i + 3.14})
  endfor

  tt.AssertBenchmark(() => {
    r.Lookup(['A'], [rand() % n])
  }, 'Lookup', {repeat: 5})
enddef

def Test_RA_Perf__GroupBy()
  var r = repeat([
    {A: 10, B: 'a', C: 'x', D: 1, E: 2, F: 3, G: 4, H: 'ok', I: 'hello'},
    {A: 20, B: 'b', C: 'y', D: 1, E: 2, F: 3, G: 4, H: 'ok', I: 'hello'},
    {A: 30, B: 'a', C: 'x', D: 1, E: 2, F: 3, G: 4, H: 'ok', I: 'hello'},
    {A: 40, B: 'a', C: 'x', D: 1, E: 2, F: 3, G: 4, H: 'ok', I: 'hello'},
    {A: 50, B: 'b', C: 'x', D: 1, E: 2, F: 3, G: 4, H: 'ok', I: 'hello'},
    {A: 60, B: 'b', C: 'y', D: 1, E: 2, F: 3, G: 4, H: 'ok', I: 'hello'},
    {A: 70, B: 'a', C: 'y', D: 1, E: 2, F: 3, G: 4, H: 'ok', I: 'hello'},
  ], 1000)

  tt.AssertBenchmark(() => {
    var result = ra.Query(r->ra.GroupBy(['B', 'C'], ra.Sum('A')))
  }, 'GroupBy', {repeat: 5})
enddef



tt.Run('_RA_Perf__')
