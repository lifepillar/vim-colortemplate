vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

import 'librelalg.vim'   as ra
import 'libtinytest.vim' as tt

def Test_RA_Version()
  assert_true(match(ra.version, '^\d\+\.\d\+\.\d\+') != -1)
enddef

# Aliases {{{
type Continuation          = ra.Continuation
type Rel                   = ra.Rel
type Relation              = ra.Relation
type Tuple                 = ra.Tuple

const AssertFails          = tt.AssertFails
const AntiEquiJoin         = ra.AntiEquiJoin
const AntiJoin             = ra.AntiJoin
const Avg                  = ra.Avg
const AvgBy                = ra.AvgBy
const Bool                 = ra.Bool
const Build                = ra.Build
const CoddDivide           = ra.CoddDivide
const Count                = ra.Count
const CountBy              = ra.CountBy
const CountDistinct        = ra.CountDistinct
const DictTransform        = ra.DictTransform
const Divide               = ra.Divide
const Extend               = ra.Extend
const EquiJoin             = ra.EquiJoin
const EquiJoinPred         = ra.EquiJoinPred
const FailedMsg            = ra.FailedMsg
const Filter               = ra.Filter
const Float                = ra.Float
const ForeignKey           = ra.ForeignKey
const Frame                = ra.Frame
const From                 = ra.From
const GroupBy              = ra.GroupBy
const KEY_NOT_FOUND        = ra.KEY_NOT_FOUND
const In                   = ra.In
const Int                  = ra.Int
const Intersect            = ra.Intersect
const Join                 = ra.Join
const LeftEquiJoin         = ra.LeftEquiJoin
const LeftNatJoin          = ra.LeftNatJoin
const ListAggregate        = ra.ListAggregate
const Max                  = ra.Max
const MaxBy                = ra.MaxBy
const Min                  = ra.Min
const MinBy                = ra.MinBy
const Minus                = ra.Minus
const NatJoin              = ra.NatJoin
const NotIn                = ra.NotIn
const Obj                  = ra.Obj
const PartitionBy          = ra.PartitionBy
const Product              = ra.Product
const Project              = ra.Project
const Query                = ra.Query
const RelEq                = ra.RelEq
const Recursive            = ra.Recursive
const References           = ra.References
const Rename               = ra.Rename
const Select               = ra.Select
const SemiJoin             = ra.SemiJoin
const Sort                 = ra.Sort
const SortBy               = ra.SortBy
const Split                = ra.Split
const Str                  = ra.Str
const StringAggregate      = ra.StringAggregate
const Sum                  = ra.Sum
const SumBy                = ra.SumBy
const Table                = ra.Table
const Transform            = ra.Transform
const Transaction          = ra.Transaction
const Union                = ra.Union
const Zip                  = ra.Zip
# }}}

def Test_RA_CreateEmptyRel()
  const M = Rel.new('M', {}, [[]])

  assert_equal('M', M.name)
  assert_equal({}, M.schema)
  assert_equal([], M.Instance())
  assert_equal([], M.attributes)
  assert_equal([], M.key_attributes)
  assert_equal([], M.descriptors)
  assert_equal(1, len(M.keys))
  assert_equal([], M.keys[0])

  const R1 = Rel.new('R', {A: Int, C: Float, B: Str}, [['A']])
  const R2 = Rel.new('R', {A: Int, C: Float, B: Str}, ['A'])
  const R3 = Rel.new('R', {A: Int, C: Float, B: Str}, 'A')

  for R in [R1, R2, R3]
    assert_equal('R', R.name)
    assert_equal({A: Int, B: Str, C: Float}, R.schema)
    assert_equal([], R.Instance())
    assert_equal(['A', 'B', 'C'], R.attributes)
    assert_equal(['A'], R.key_attributes)
    assert_equal(['B', 'C'], R.descriptors)
    assert_equal(1, len(R.keys))
    assert_equal(['A'], R.keys[0])
  endfor

  const S = Rel.new('S',
    {Z: Str, Y: Int, W: Float, X: Str},
    [['X', 'Y'], ['Z', 'Y']]
  )
  assert_equal('S', S.name)
  assert_equal({X: Str, Y: Int, W: Float, Z: Str}, S.schema)
  assert_equal([], S.Instance())
  assert_equal(['W', 'X', 'Y', 'Z'], S.attributes)
  assert_equal(['X', 'Y', 'Z'], S.key_attributes)
  assert_equal(['W'], S.descriptors)
  assert_equal(2, len(S.keys))
  assert_equal(['X', 'Y'], S.keys[0])
  assert_equal(['Z', 'Y'], S.keys[1])

  const T = Rel.new('T',
    {Z: Str, Y: Int, W: Float, X: Str},
    [['X', 'Y'], 'Z', ['Y']]
  )
  assert_equal('T', T.name)
  assert_equal({X: Str, Y: Int, W: Float, Z: Str}, T.schema)
  assert_equal([], T.Instance())
  assert_equal(['W', 'X', 'Y', 'Z'], T.attributes)
  assert_equal(['X', 'Y', 'Z'], T.key_attributes)
  assert_equal(['W'], T.descriptors)
  assert_equal(3, len(T.keys))
  assert_equal(['X', 'Y'], T.keys[0])
  assert_equal(['Z'], T.keys[1])
  assert_equal(['Y'], T.keys[2])

  const U = Rel.new('U',
    {A: Int, B: Int},
    ['B', 'A']  # One composite key
  )
  assert_equal('U', U.name)
  assert_equal({A: Int, B: Int}, U.schema)
  assert_equal([], U.Instance())
  assert_equal(['A', 'B'], U.attributes)
  assert_equal(['A', 'B'], U.key_attributes)
  assert_equal([], U.descriptors)
  assert_equal(1, len(U.keys))
  assert_equal(['B', 'A'], U.keys[0])

  const V = Rel.new('V',
    {A: Int, B: Int},
    [['B'], 'A']  # Two single-attribute keys
  )
  assert_equal('V', V.name)
  assert_equal({A: Int, B: Int}, V.schema)
  assert_equal([], V.Instance())
  assert_equal(['A', 'B'], V.attributes)
  assert_equal(['A', 'B'], V.key_attributes)
  assert_equal([], V.descriptors)
  assert_equal(2, len(V.keys))
  assert_equal(['B'], V.keys[0])
  assert_equal(['A'], V.keys[1])
enddef

def Test_RA_DuplicateKey()
  AssertFails(() => {
    Rel.new('R', {A: Int, B: Str}, [[], []])
  }, "Key [] already defined in relation R")

  AssertFails(() => {
    Rel.new('R', {A: Int, B: Str}, [['A'], ['B'], ['A']])
  }, "Key [A] already defined in relation R")

  var R = Rel.new('R', {A: Int, B: Str}, [['A'], ['B'], ['A', 'B'], ['B', 'A']])

  assert_equal([['A'], ['B'], ['A', 'B'], ['B', 'A']], R.keys)
enddef

def Test_RA_WrongKey()
  AssertFails(() => {
    Rel.new('R', {A: Int}, 'B')
  }, "B is not an attribute of relation R")
  AssertFails(() => {
    Rel.new('R', {A: Int}, 'B')
  }, "B is not an attribute of relation R")
enddef

def Test_RA_OnInsertCheck()
  var R = Rel.new('R', {A: Str, B: Int}, 'A')

  R.OnInsertCheck('Test constraint', (t) => t.B > 0)

  R.Insert({A: 'x', B: 1})

  AssertFails(() => {
    R.Insert({A: 'y', B: -1})
  }, "Test constraint failed")
enddef

def Test_RA_Insert()
  var R = Rel.new('R', {A: Int, B: Str, C: Bool, D: Float}, [['A', 'C']])

  R.Insert({A: 0, B: 'b0', C: true, D: 1.2})

  assert_equal(1, len(R.Instance()))

  R.Insert({A: 0, B: 'b1', C: false, D: 0.2})

  assert_equal(2, len(R.Instance()))
  assert_equal([
    {A: 0, B: 'b0', C: true,  D: 1.2},
    {A: 0, B: 'b1', C: false, D: 0.2}
  ], R.Instance())

  AssertFails(() => {
    R.Insert({A: 0, B: 'b2', C: true, D: 3.5})
  }, 'Duplicate key')

  AssertFails(() => {
    R.Insert({A: 9})
  }, 'Expected a tuple on schema {A: integer, B: string, C: boolean, D: float}: got {A: 9}')

  AssertFails(() => {
    R.Insert({A: false, B: 'b3', C: false, D: 7.0})
  }, "Expected a tuple on schema {A: integer, B: string, C: boolean, D: float}: got {A: false, B: 'b3', C: false, D: 7.0}")

  AssertFails(() => {
    R.Insert({A: 9, B: 9, C: false, D: 'tsk'})
  },  "Expected a tuple on schema {A: integer, B: string, C: boolean, D: float}: got {A: 9, B: 9, C: false, D: 'tsk'}")

  AssertFails(() => {
    R.Insert({A: 9, B: 'b3', C: 3.2, D: 'tsk'})
  },  "Expected a tuple on schema {A: integer, B: string, C: boolean, D: float}: got {A: 9, B: 'b3', C: 3.2, D: 'tsk'}")

  AssertFails(() => {
    R.Insert({A: 9, B: 'b3', C: false, D: 'tsk'})
  },  "Expected a tuple on schema {A: integer, B: string, C: boolean, D: float}: got {A: 9, B: 'b3', C: false, D: 'tsk'}")

  assert_equal(
    [{A: 0, B: 'b0', C: true, D: 1.2}, {A: 0, B: 'b1', C: false, D: 0.2}],
    R.Instance()
  )
enddef

def Test_RA_InsertMany()
  var RR = Rel.new('RR', {A: Int, B: Str, C: Bool, D: Float}, [['A', 'C']])
  const instance = [
    {A: 0, B: 'b0', C: true, D: 1.2},
    {A: 1, B: 'b1', C: true, D: 3.4},
  ]
  RR.InsertMany(instance)

  assert_equal(instance, RR.Instance())
enddef

def Test_RA_InsertManyFailedConstraint()
  var R = Rel.new('R', {A: Int, B: Str, C: Bool, D: Float}, [['A', 'C']])
  const instance = [
    {A: 0, B: 'b0', C: true, D: 1.2},
    {A: 1, B: 'b1', C: true, D: 3.4},
  ]
  R.InsertMany(instance)

  assert_equal(instance, R.Instance())

  AssertFails(() => {
    R.InsertMany([
      {A: 2, B: 'b2', C: false, D: 1.0},
      {A: 1, B: 'b3', C: true,  D: 3.4},
    ])
  }, "Duplicate key: {A: 1, C: true} already exists in R.")

  assert_equal(instance, R.Instance())
enddef

def Test_RA_InsertWithConstraint()
  var R = Rel.new('R', {A: Int}, 'A')

  R.OnInsertCheck('Max 3 tuples', (t) => len(R.Instance()) < 3)

  R.Insert({A: 1})
  R.Insert({A: 2})

  AssertFails(() => {
    R.Insert({A: 3})
  }, 'Max 3 tuples failed')
enddef

def Test_RA_InsertManyDuplicateKey()
  var RR = Rel.new('RR', {A: Int, B: Str, C: Bool, D: Float}, ['A', 'B', 'C'])

  AssertFails(() => {
    RR.InsertMany([
      {A: 0, B: 'b0', C: true, D: 1.2},
      {A: 0, B: 'b0', C: true, D: 0.4},
    ])
  }, "Duplicate key: {A: 0, B: 'b0', C: true} already exists in RR")

  assert_true(RR.IsEmpty())
enddef

def Test_RA_Update()
  var R = Rel.new('R', {A: Int, B: Str, C: Bool, D: Str}, [['A'], ['B', 'C']])

  R.InsertMany([
    {A: 0, B: 'x', C: true,  D: 'd1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
  ])

  R.Update((t) => t.A == 0, (t) => {
    t.D = 'new-d1'
  })
  R.Update((t) => t.A == 1, (t) => {
    t.D = 'new-d2'
  })

  const expected = [
    {A: 0, B: 'x', C: true, D: 'new-d1'},
    {A: 1, B: 'x', C: false, D: 'new-d2'},
  ]

  assert_true(RelEq(expected, R.Instance()))

  AssertFails(() => {
    R.Update((t) => t.A == 0, (t) => {
      t.C = false
      t.D = ''
    })
    echo R.Index(['B', 'C'])
  }, "Duplicate key: {B: 'x', C: false}")

  assert_true(RelEq(expected, R.Instance()))

  R.Update((t) => t.A == 0, (t) => {
    t.D = 'dd'
  })

  assert_true(RelEq([
    {A: 0, B: 'x', C: true,  D: 'dd'},
    {A: 1, B: 'x', C: false, D: 'new-d2'},
  ], R.Instance()))

  R.Update((t) => t.A == 2, (t) => {
    t.B = 'y'
  })

  assert_true(RelEq([
    {A: 0, B: 'x', C: true,  D: 'dd'},
    {A: 1, B: 'x', C: false, D: 'new-d2'},
  ], R.Instance()))

  R.Update((t) => true, (t) => {
    t.B = 'y'
  })

  assert_true(RelEq([
    {A: 0, B: 'y', C: true,  D: 'dd'},
    {A: 1, B: 'y', C: false, D: 'new-d2'},
  ], R.Instance()))
enddef

def Test_RA_UpdateDiscriminator()
  var HiGroup = Rel.new('Highlight Group', {
    HiGroupName: Str,
    DiscrName:   Str,
    IsLinked:    Bool,
  }, 'HiGroupName')

  HiGroup.Insert({
    HiGroupName: 'Normal',
    DiscrName:   '',
    IsLinked:    false,
  })

  HiGroup.Update((t) => t.HiGroupName == 'Normal', (t) => {
    t.DiscrName = 'foobar'
    t.IsLinked = true
  })

  const expected = [{
    HiGroupName: 'Normal',
    DiscrName:   'foobar',
    IsLinked:    true,
  }]

  assert_equal(expected, HiGroup.Instance())
enddef

def Test_RA_Upsert()
  var R = Rel.new('R', {A: Int, B: Str, C: Bool, D: Str}, [['A'], ['B', 'C']])

  R.InsertMany([
    {A: 0, B: 'x', C: true, D: 'd1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
  ])

  R.Upsert({A: 2, B: 'y', C: true, D: 'd3'})     # Insert new tuple
  R.Upsert({A: 0, B: 'x', C: true, D: 'new-d1'}) # Update tuple
  R.Upsert({A: 0, B: 'x', C: true, D: 'new-d1'}) # No-op
  R.Upsert({A: 2, B: 'y', C: true, D: 'd3'})     # No-op

  const expected = [
    {A: 0, B: 'x', C: true, D: 'new-d1'},
    {A: 1, B: 'x', C: false, D: 'd2'},
    {A: 2, B: 'y', C: true, D: 'd3'},
  ]

  assert_true(RelEq(expected, R))

  # It is possible to update any key except the primary key (the first key)
  R.Upsert({A: 2, B: 'z', C: false, D: 'd3'})

  # Of course, that should not result in the violation of uniqueness
  AssertFails(() => {
    R.Upsert({A: 0, B: 'x', C: false, D: 'd'})
  }, "Duplicate key: {B: 'x', C: false}")
enddef

def Test_RA_Delete()
  var R = Rel.new('R', {A: Int, B: Str}, ['A'])

  R.InsertMany([
    {A: 0, B: 'X'},
    {A: 1, B: 'Y'},
    {A: 2, B: 'Z'},
    {A: 3, B: 'Y'},
    {A: 4, B: 'Z'},
  ])

  const expected1 = [
    {A: 1, B: 'Y'},
    {A: 2, B: 'Z'},
    {A: 3, B: 'Y'},
    {A: 4, B: 'Z'},
  ]
  const expected2 = [
    {A: 1, B: 'Y'},
    {A: 4, B: 'Z'},
  ]

  R.Delete((t) => t.B == 'X')

  assert_equal(expected1, R.Instance())

  R.Delete((t) => t.A == 2 || t.A == 3)

  assert_equal(expected2, R.Instance())

  R.Delete()

  assert_equal([], R.Instance())
enddef

def Test_RA_DeleteConstraint()
  var R = Rel.new('R', {A: Int, B: Str}, ['A'])
  var CardinalityCheck = (t: Tuple): bool => {
    if len(R.Instance()) <= 2
      FailedMsg('Too few tuples.')
      return false
    endif
    return true
  }

  R.OnInsertCheck('Cardinality constraint', CardinalityCheck)
  R.OnDeleteCheck('Cardinality constraint', CardinalityCheck)

  const instance = [
    {A: 0, B: 'X'},
    {A: 1, B: 'Y'},
  ]

  AssertFails(() => {
    R.InsertMany(instance)
  }, 'Too few tuples')

  Transaction(() => {
    R.InsertMany(instance)
    R.Insert({A: 2, B: 'W'})
  })

  assert_equal(3, len(R.Instance()))

  AssertFails(() => {
    R.Delete((t) => t.A == 0)
  }, "Too few tuples")

  assert_true(RelEq(instance + [{A: 2, B: 'W'}], R.Instance()))
enddef

def Test_RA_ReferentialIntegrityDelete()
  var R = Rel.new('R', {A: Int}, ['A'])
  var S = Rel.new('S', {X: Str, Y: Int}, ['X'])
  ForeignKey(S, ['Y'])->References(R, {key: ['A'], verb: 'flocks with'})
  R.Insert({A: 2})
  S.Insert({X: 'a', Y: 2})

  AssertFails(() => {
    R.Delete()
  }, "S flocks with R: cannot delete {A: 2} from R because it is referenced by {X: 'a', Y: 2} in S")

  S.Delete()
  R.Delete()

  assert_true(R.IsEmpty())
enddef

def Test_RA_WrongForeignKeyDefinitions()
  var R = Rel.new('R', {A: Str},         'A')
  var S = Rel.new('S', {B: Int, C: Str}, 'B')

  AssertFails(() => {
    ForeignKey(S, ['B', 'C'])->References(R, {key: ['A']})
  }, "Foreign key size mismatch: S[B, C] -> R[A]")

  AssertFails(() => {
    ForeignKey(S, ['A'])->References(R)
  }, "Wrong foreign key: S[A]. A is not an attribute of S")

enddef

def Test_RA_ReferentialIntegrityInsertUpdate()
  var R = Rel.new('R', {A: Str},         'A')
  var S = Rel.new('S', {B: Int, C: Str}, 'B')

  ForeignKey(S, 'C')->References(R, {verb: 'smurfs'})

  R.InsertMany([
    {A: 'ab'},
    {A: 'tm'},
  ])
  S.InsertMany([
    {B: 10, C: 'tm'},
    {B: 20, C: 'tm'},
    {B: 30, C: 'ab'},
  ])

  AssertFails(() => {
    S.Insert({B: 40, C: 'xy'})
  }, "S smurfs R: {C: 'xy'} not found in R[A]")

  S.Update((t) => t.B == 20, (t) => {
    t.C = 'ab'
  })

  AssertFails(() => {
    S.Update((t) => t.B == 30, (t) => {
      t.C = 'wz'
    })
  }, "S smurfs R: {C: 'wz'} not found in R[A]")

  const expected = [
    {B: 10, C: 'tm'},
    {B: 20, C: 'ab'},
    {B: 30, C: 'ab'},
  ]
  assert_equal(expected, S.Instance())
enddef

def Test_RA_ForeignKeySameAttrs()
  var RR = Rel.new('R', {A: Str}, 'A')
  var SS = Rel.new('S', {B: Int, A: Str}, 'B')

  ForeignKey(SS, 'A')->References(RR)

  RR.InsertMany([{A: 'ab'}, {A: 'tm'}])
  SS.Insert({B: 10, A: 'tm'})
  SS.Insert({B: 20, A: 'tm'})
  SS.Insert({B: 30, A: 'ab'})

  AssertFails(() => {
    SS.Insert({B: 40, A: 'xy'})
  }, "{A: 'xy'} not found in R[A]")
enddef

def Test_RA_ForeignKeySyntacticSugar()
  def FK(verbphrase: string): func(list<any>, Rel, any)
    return (fk: list<any>, R: Rel, key: any) => {
      return ForeignKey(fk[0], fk[1])->References(R, {key: key, verb: verbphrase})
    }
  enddef

  var Tag    = Rel.new('Tag', {Name: Str, Buffer: Int}, 'Name')
  var Buffer = Rel.new('Buffer', {Bufnr: Int, Name: Str}, 'Bufnr')
  var Tags   = FK('must annotate a')

  [Tag, 'Buffer']->Tags(Buffer, 'Bufnr')

  Buffer.InsertMany([{Bufnr: 1, Name: 'b1'}, {Bufnr: 2, Name: 'b2'}])
  Tag.Insert({Name: 't1', Buffer: 1})
  Tag.Insert({Name: 't2', Buffer: 1})
  Tag.Insert({Name: 't3', Buffer: 2})

  AssertFails(() => {
    Tag.Insert({Name: 't4', Buffer: 3})
  }, 'Tag must annotate a Buffer')
enddef

def Test_RA_CheckConstraint()
  var RR = Rel.new('R', {A: Int, B: Int}, 'A')

  RR.OnInsertCheck('test', (t) => {
    if t.B <= 0
      FailedMsg($'B must be positive: got {t.B}')
      return false
    endif

   return true
  })

  var t0 = {A: 1, B: 2}

  RR.Insert(t0)

  assert_equal([t0], RR.Instance())

  AssertFails(() => {
    RR.Insert({A: 2, B: -3})
  }, "B must be positive: got -3")

  assert_equal([t0], RR.Instance())

  RR.Update((t) => t.A == 1, (t) => {
    t.B = 3
  })

  assert_equal([{A: 1, B: 3}], RR.Instance())

  AssertFails(() => {
    RR.Update((t) => t.A == 1, (t) => {
      t.B = -2
    })
  }, "B must be positive: got -2")

  assert_equal([{A: 1, B: 3}], RR.Instance())

  RR.Delete()

  assert_true(RR.IsEmpty())
enddef

def Test_RA_DeleteInsertUpdate()
  var R = Rel.new('R', {A: Int}, 'A')

  R.Insert({A: 1})

  Transaction(() => {
    R.Insert({A: 2})
    R.Delete((t) => t.A == 1)
    R.Update((t) => t.A == 2, (t) => {
      t.A = 1
    })
  })

  R.Insert({A: 2})

  assert_equal([{A: 1}, {A: 2}], R.Instance())
enddef

def Test_RA_Index()
  const key = ['A', 'B']
  const keyStr = string(key)
  var R = Rel.new('R', {A: Int, B: Str}, key)

  assert_equal([['A', 'B']], R.keys)

  const I = R.Index(key)

  assert_equal(v:t_object, type(I))
  assert_equal('object<Index>', typename(I))
  assert_true(I.IsEmpty(), 'Index must be initially empty')

  const t0 = {A: 9, B: 'veni'}
  const t1 = {A: 3, B: 'vici'}
  const t2 = {A: 9, B: 'vidi'}

  R.InsertMany([t0, t1, t2])

  var s0 = I.Search([9, 'veni'])
  var s1 = I.Search([9, 'vidi'])
  var s2 = I.Search([3, 'vici'])
  assert_true(s0 == [t0])
  assert_true(s1 == [t2])
  assert_true(s2 == [t1])
  assert_true(s0[0] is t0)
  assert_true(s1[0] is t2)
  assert_true(s2[0] is t1)
  assert_true(empty(I.Search([0, ''])))

  R.Delete((t) => t.A == 9 && t.B == 'veni')

  assert_true(empty(I.Search([9, 'veni'])))
  assert_true(I.Search([9, 'vidi']) == [t2])
  assert_true(I.Search([3, 'vici']) == [t1])

  R.Delete((t) => t.B == 'vici')

  assert_true(empty(I.Search([9, 'veni'])))
  assert_true(I.Search([9, 'vidi']) == [t2])
  assert_true(empty(I.Search([3, 'vici'])))

  R.Delete()

  assert_true(empty(I.Search([9, 'veni'])))
  assert_true(empty(I.Search([9, 'vidi'])))
  assert_true(empty(I.Search([3, 'vici'])))
  assert_true(I.IsEmpty())
enddef

def Test_RA_In()
  const R = Rel.new('R', {A: Str, B: Int}, [['A']])
  R.InsertMany([
    {A: 'a', B: 1},
    {A: 'b', B: 1},
    {A: 'c', B: 2},
  ])

  const t1 = {A: 'a', B: 1}
  const t2 = {A: 'a', B: 2}
  assert_true(t1->In(R), "t1 is not in R")
  assert_true(!t2->In(R), "t2 is in R")
  assert_true(!t1->NotIn(R), "not (not t1 is not in R)")
  assert_true(t2->NotIn(R), "not (t2 is not in R)")
enddef

def Test_RA_Scan()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const result1 = Query(From(R))
  const result2 = Query(From(R.Instance()))

  const expected = instance

  assert_equal(expected, result1)
  assert_equal(expected, result2)
  assert_equal(instance, R.Instance())
enddef

def Test_RA_FilteredScan()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const expected = [{A: 2, B: 0.0, C: false, D: 'tuple2'}]
  const result = Query(R->Select((t) => !t.C && t.B >= 0))

  assert_equal(expected, result)
  assert_equal(instance, R.Instance())
enddef

def Test_RA_Sort()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, [['A']])
  const r = R.Instance()

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const Cmp = (t1, t2) => t1.B == t2.B ? 0 : t1.B > t2.B ? 1 : -1

  const expected = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  assert_equal(expected, From(r)->Sort(Cmp))
  assert_equal(expected, From(r)->SortBy('B'))
  assert_equal(R.Instance(), r)
  assert_equal(instance, R.Instance())
enddef

def Test_RA_SortByAscDesc()
  var R = Rel.new('R', {A: Int, B: Float, C: Bool, D: Str}, 'A')
  const r = R.Instance()

  const instance = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]
  R.InsertMany(instance)

  const expected1 = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  const expected2 = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]

  const expected3 = [
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  const expected4 = [
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
  ]

  const expected5 = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
  ]

  const expected6 = [
    {A: 1, B:  2.5, C: true,  D: 'tuple1'},
    {A: 2, B:  0.0, C: false, D: 'tuple2'},
    {A: 3, B: -1.0, C: false, D: 'tuple3'},
  ]

  assert_equal(expected1, From(r)->SortBy(['B'], ['i']))
  assert_equal(expected2, From(r)->SortBy('B', ['d']))
  assert_equal(expected3, From(r)->SortBy(['C', 'B'], ['i', 'd']))
  assert_equal(expected4, From(r)->SortBy(['C', 'B'], ['i', 'i']))
  assert_equal(expected5, From(r)->SortBy(['C', 'B'], ['d', 'i']))
  assert_equal(expected6, From(r)->SortBy(['C', 'B'], ['d', 'd']))
  assert_equal(R.Instance(), r)
  assert_equal(instance, R.Instance())
enddef

def Test_RA_Rename()
  var R = Rel.new('R', {A: Str, B: Float, C: Int}, 'A')
  const r = R.Instance()

  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80},
  ]
  R.InsertMany(instance)

  const expected = [
    {X: 'a1', B: 4.0, W: 40},
    {X: 'a2', B: 2.0, W: 80},
  ]

  assert_equal(instance, From(R)->Rename({})->Build())
  assert_equal(expected, From(R)->Rename({A: 'X', C: 'W'})->Build())
  assert_equal(instance, r)
enddef

def Test_RA_Select()
  var R = Rel.new('R', {A: Str, B: Float, C: Int}, [['A']])
  const r = R.Instance()

  const instance = [
    {A: 'a1', B: 4.0, C: 40},
    {A: 'a2', B: 2.0, C: 80},
    {A: 'a3', B: 9.0, C: 10},
    {A: 'a4', B: 5.0, C: 80},
    {A: 'a5', B: 4.0, C: 20},
  ]
  R.InsertMany(instance)

  const expected1 = [
    {A: 'a1', B: 4.0, C: 40},
  ]
  const expected2 = [
    {A: 'a5', B: 4.0, C: 20},
  ]

  assert_equal(expected1, Query(From(r)->Select((t) => t.C == 40)))
  assert_equal(expected2, Query(From(r)->Select((t) => t.B <= 4.0 && t.A == 'a5')))
  assert_equal([], Query(From(r)->Select((t) => t.B > 9.0)))
  assert_equal(instance, r)
enddef

def Test_RA_Project()
  var R = Rel.new('R', {A: Str, B: Bool, C: Int}, 'A')
  const r = R.Instance()

  const instance = [
    {A: 'a1', B: true,  C: 40},
    {A: 'a2', B: false, C: 80},
    {A: 'a3', B: true,  C: 40},
    {A: 'a4', B: true,  C: 80},
    {A: 'a5', B: false, C: 20},
  ]
  R.InsertMany(instance)

  const expected1 = [
    {A: 'a1'},
    {A: 'a2'},
    {A: 'a3'},
    {A: 'a4'},
    {A: 'a5'},
  ]
  const expected2 = [
    {B: false},
    {B: true}
  ]
  const expected3 = [
    {B: false, C: 20},
    {B: false, C: 80},
    {B: true,  C: 40},
    {B: true,  C: 80},
  ]

  assert_equal([], Query(From([])->Project('X')))
  assert_equal([], Query(From([])->Project([])))
  assert_equal([{}], Query(From([{}])->Project([])))
  assert_equal([{}], Query(From(r)->Project([])))
  assert_equal(expected1, From(r)->Project('A')->SortBy('A'))
  assert_equal(expected2, From(r)->Project('B')->SortBy('B'))
  assert_equal(expected3, From(r)->Project(['B', 'C'])->SortBy(['B', 'C']))
  assert_equal(instance, r)
enddef

def Test_RA_EquiJoinPred()
  var Pred = EquiJoinPred(['X'], ['Y'])

  assert_true(Pred({X: 1, W: 2}, {Y: 1, Z: 3}), "Equi-join predicate 1 failed")
  assert_false(Pred({X: 2, W: 2}, {Y: 1, Z: 3}), "Equi-join predicate 2 succeeded")

  Pred = EquiJoinPred(['X', 'Y'], ['W', 'Z'])

  assert_true(Pred({X: 1, Y: 2}, {W: 1, Z: 2}), "Equi-join predicate 3 failed")
  assert_false(Pred({X: 3, Y: 4}, {W: 3, Z: 5}), "Equi-join predicate 4 succeeded")
enddef

def Test_RA_EquiJoinPredSameAttrs()
  var Pred = EquiJoinPred(['X'])

  assert_true(Pred({X: 1, W: 2}, {X: 1, Z: 3}), "Equi-join predicate 1 failed")
  assert_false(Pred({X: 2, W: 2}, {X: 1, Z: 3}), "Equi-join predicate 2 succeeded")

  Pred = EquiJoinPred(['X', 'Y'])

  assert_true(Pred({X: 1, Y: 2}, {X: 1, Y: 2}), "Equi-join predicate 3 failed")
  assert_false(Pred({X: 3, Y: 4}, {X: 3, Y: 5}), "Equi-join predicate 4 succeeded")
enddef

def Test_RA_Join()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.Instance()

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0},
  ]
  S.InsertMany(instanceS)


  const expected1 = [
    {A: 1, B: 'one', s_B: 'one', C: 1},
    {A: 2, B: 'one', s_B: 'one', C: 1},
  ]
  const expected2 = [
    {A: 1, r_B: 'one', B: 'one', C: 1},
    {A: 2, r_B: 'one', B: 'one', C: 1},
  ]
  const expected3 = [
    {A: 0, B: 'zero',  s_B: 'one',   C: 1},
    {A: 0, B: 'zero',  s_B: 'three', C: 0},
    {A: 1, B: 'one',   s_B: 'one',   C: 1},
  ]
  const expected4 = [
    {A: 0, r_B: 'zero', B: 'three', C: 0},
    {A: 0, r_B: 'zero', B: 'one',   C: 1},
    {A: 1, r_B: 'one',  B: 'one',   C: 1},
  ]
  const expected5 = [
    {B: 'one',   C: 1, s_B: 'three', s_C: 0},
    {B: 'three', C: 0, s_B: 'three', s_C: 0},
  ]

  const expected6 = [
    {B: 'one',   C: 1, _B: 'three', _C: 0},
    {B: 'three', C: 0, _B: 'three', _C: 0},
  ]


  assert_equal(expected1, R->Join(S, (rt, st) => rt.B == st.B, {prefix: 's_'})->SortBy('A'))
  assert_equal(expected2, S->Join(R, (st, rt) => rt.B == st.B, {prefix: 'r_'})->SortBy('A'))
  assert_equal(expected3, R->Join(S, (rt, st) => rt.A <= st.C, {prefix: 's_'})->SortBy(['A', 'B']))
  assert_equal(expected4, S->Join(R, (st, rt) => rt.A <= st.C, {prefix: 'r_'})->SortBy(['C', 'A']))
  assert_equal(expected5, S->Join(S, (s1, s2) => s1.C >= s2.C && s2.C == 0, {prefix: 's_'})->SortBy('B'))
  assert_equal(expected6, S->Join(S, (s1, s2) => s1.C >= s2.C && s2.C == 0)->SortBy('B'))

  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_NatJoin()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.Instance()

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0},
  ]
  S.InsertMany(instanceS)

  var T = Rel.new('T', {D: Int}, [['D']])
  const t = T.Instance()

  const instanceT = [
    {D: 8},
    {D: 9},
  ]
  T.InsertMany(instanceT)

  var U = Rel.new('U', {A: Int, B: Str}, [['A', 'B']])
  const u = U.Instance()

  const instanceU = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  U.InsertMany(instanceU)

  const expected1 = [
    {A: 1, B: 'one', C: 1},
    {A: 2, B: 'one', C: 1},
  ]
  const expected2 = [
    {B: 'one',   C: 1, D: 8},
    {B: 'one',   C: 1, D: 9},
    {B: 'three', C: 0, D: 8},
    {B: 'three', C: 0, D: 9},
  ]

  assert_equal(expected1, Query(From(R)->NatJoin(S)))
  assert_equal(expected1, Query(From(S)->NatJoin(R)))
  assert_equal(expected2, Query(From(S)->NatJoin(T)))
  assert_equal(r, Query(From(R)->NatJoin(R)))
  assert_equal([{A: 1, B: 'one'}], Query(From(R)->NatJoin(U)))
  assert_equal([{A: 1, B: 'one'}], Query(From(U)->NatJoin(R)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
  assert_equal(instanceT, t)
  assert_equal(instanceU, u)
enddef

def Test_RA_EquiJoin()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.Instance()

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0},
  ]
  S.InsertMany(instanceS)


  const expected1 = [
    {A: 1, B: 'one', s_B: 'one', C: 1},
    {A: 2, B: 'one', s_B: 'one', C: 1},
  ]
  const expected2 = [
    {A: 1, r_B: 'one', B: 'one', C: 1},
    {A: 2, r_B: 'one', B: 'one', C: 1},
  ]
  const expected3 = [
    {A: 0, B: 'zero', s_B: 'three', C: 0},
    {A: 1, B: 'one',  s_B: 'one',   C: 1},
  ]
  const expected4 = [
    {A: 0, r_B: 'zero', B: 'three', C: 0},
    {A: 1, r_B: 'one',  B: 'one',   C: 1},
  ]


  assert_equal(expected1, From(R)->EquiJoin(S, {on: 'B', prefix: 's_'})->SortBy('A'))
  assert_equal(expected2, From(S)->EquiJoin(R, {on: 'B', prefix: 'r_'})->SortBy('A'))
  assert_equal(expected3, From(R)->EquiJoin(S, {onleft: 'A', onright: 'C', prefix: 's_'})->SortBy('A'))
  assert_equal(expected4, From(S)->EquiJoin(R, {onleft: 'C', onright: 'A', prefix: 'r_'})->SortBy('A'))

  assert_equal(instanceR, r)
  assert_equal(instanceS, s)

  assert_true(RelEq(
    Query(Product(S, R)),
    Query(EquiJoin(S, R)) # Behaves like a Cartesian product
  ))

  assert_true(RelEq(
    Query(Product(R, R)),
    Query(EquiJoin(R, R))
  ))
enddef

def Test_RA_Product()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
    ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {C: Int}, [['C']])
  const s = S.Instance()

  const instanceS = [
    {C: 10},
    {C: 90},
  ]
  S.InsertMany(instanceS)

  assert_equal([], Query(From([])->Product([])))
  assert_equal([], Query(From(R)->Product([])))
  assert_equal([], Query(From([])->Product(R)))
  assert_equal(r, Query(From(R)->Product([{}])))

  const expected = [
    {A: 0, B: 'zero', C: 10},
    {A: 0, B: 'zero', C: 90},
    {A: 1, B: 'one',  C: 10},
    {A: 1, B: 'one',  C: 90},
    {A: 2, B: 'two',  C: 10},
    {A: 2, B: 'two',  C: 90},
  ]

  assert_equal(expected, From(R)->Product(S)->SortBy(['A', 'C']))
  assert_equal(expected, From(S)->Product(R)->SortBy(['A', 'C']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_SelfProduct()
  const r = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
  ]
  const expected = [
    {A: 0, B: 'zero', _A: 0, _B: 'zero'},
    {A: 0, B: 'zero', _A: 1, _B: 'one'},
    {A: 1, B: 'one',  _A: 0, _B: 'zero'},
    {A: 1, B: 'one',  _A: 1, _B: 'one'},
  ]

  assert_equal(expected, Query(Product(r, r)))
enddef

def Test_RA_Intersect()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.Instance()

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  S.InsertMany(instanceS)

  assert_equal([{A: 1, B: 'one'}], Query(From(R)->Intersect(S)))
  assert_equal([{A: 1, B: 'one'}], Query(From(S)->Intersect(R)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Minus()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.Instance()

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ]
  S.InsertMany(instanceS)

  const expected1 = [
    {A: 0, B: 'zero'},
    {A: 2, B: 'one'},
  ]
  const expected2 = [
    {A: 0, B: 'many'},
    {A: 2, B: 'two'},
  ]

  assert_equal(expected1, From(R)->Minus(S)->SortBy('A'))
  assert_equal(expected2, From(S)->Minus(R)->SortBy('A'))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_Union()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {A: Int, B: Str}, [['A', 'B']])
  const s = S.Instance()

  const instanceS = [
    {A: 0, B: 'many'},
    {A: 1, B: 'one'},
    {A: 3, B: 'one'},
  ]
  S.InsertMany(instanceS)

  const expected = [
    {A: 0, B: 'many'},
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
    {A: 3, B: 'one'},
  ]

  assert_equal(expected, From(R)->Union(S)->SortBy(['A', 'B']))
  assert_equal(expected, Union(S, R)->SortBy(['A', 'B']))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
  assert_equal(expected, R->Union(Select(S, (t) => true)->SortBy(['A', 'B'])))
enddef

def Test_RA_SemiJoin()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.Instance()

  const instanceS = [
    {B: 'one', C: 1},
    {B: 'three', C: 0}
  ]
  S.InsertMany(instanceS)

  const expected1 = [
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  const expected2 = [
    {B: 'one', C: 1},
  ]
  const expected3 = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
  ]
  const expected4 = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]
  const expected5 = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]

  assert_equal(expected1, From(R)->SemiJoin(S, (rt, st) => rt.B == st.B)->SortBy('A'))
  assert_equal(expected2, Query(From(S)->SemiJoin(R, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, From(R)->SemiJoin(S, (rt, st) => rt.A <= st.C)->SortBy('A'))
  assert_equal(expected4, From(S)->SemiJoin(R, (st, rt) => rt.A <= st.C)->SortBy('B'))
  assert_equal(expected5, Query(From(S)->SemiJoin(S, (s1, s2) => s1.C >= s2.C && s2.C == 0)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_AntiJoin()
  var R = Rel.new('R', {A: Int, B: Str}, [['A']])
  const r = R.Instance()

  const instanceR = [
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'one'},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Str, C: Int}, [['C']])
  const s = S.Instance()

  const instanceS = [
    {B: 'one',   C: 1},
    {B: 'three', C: 0},
  ]
  S.InsertMany(instanceS)

  const expected1 = [
    {A: 0, B: 'zero'},
  ]
  const expected2 = [
    {B: 'three', C: 0},
  ]
  const expected3 = [
    {A: 2, B: 'one'},
  ]
  const expected4 = []
  const expected5 = [
    {B: 'three', C: 0},
  ]

  assert_equal(expected1, Query(From(R)->AntiJoin(S, (rt, st) => rt.B == st.B)))
  assert_equal(expected2, Query(From(S)->AntiJoin(R, (st, rt) => rt.B == st.B)))
  assert_equal(expected3, SortBy(From(R)->AntiJoin(S, (rt, st) => rt.A <= st.C), 'A'))
  assert_equal(expected4, SortBy(From(S)->AntiJoin(R, (st, rt) => rt.A <= st.C), 'B'))
  assert_equal(expected5, Query(From(S)->AntiJoin(S, (s1, s2) => s1.C > s2.C)))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_AntiEquiJoin()
  var R = Rel.new('R', {A: Int, B: Int}, 'A')
  var r = R.Instance()

  var instanceR = [
    {A: 0, B: 1},
    {A: 1, B: 2},
    {A: 2, B: 1},
  ]
  R.InsertMany(instanceR)

  var S = Rel.new('S', {B: Int, C: Int}, 'C')
  var s = S.Instance()

  var instanceS = [
    {B: 3, C: 1},
    {B: 1, C: 0},
  ]
  S.InsertMany(instanceS)

  const expected1 = [
    {A: 1, B: 2},
  ]
  const expected2 = [
    {B: 3, C: 1},
  ]
  const expected3 = [
    {A: 0, B: 1},
    {A: 2, B: 1},
  ]
  const expected4 = [
    {A: 2, B: 1},
  ]

  assert_equal(expected1, Query(From(R)->AntiEquiJoin(S, {on: 'B'})))
  assert_equal(expected1, Query(From(R)->AntiEquiJoin(S, {onleft: 'B', onright: 'C'})))
  assert_equal(expected2, Query(From(S)->AntiEquiJoin(R, {on: 'B'})))
  assert_equal(expected2, Query(From(S)->AntiEquiJoin(R, {onleft: 'B', onright: 'A'})))
  assert_equal(expected2, Query(From(S)->AntiEquiJoin(R, {onleft: 'B', onright: 'A'})))
  assert_equal(expected3, Query(From(R)->AntiEquiJoin(S, {onleft: 'A', onright: 'B'})))
  assert_equal(expected4, Query(From(R)->AntiEquiJoin(S, {onleft: 'A', onright: 'C'})))
  assert_equal([],        Query(From(S)->AntiEquiJoin(R, {onleft: 'C', onright: 'A'})))
  assert_equal(instanceR, r)
  assert_equal(instanceS, s)
enddef

def Test_RA_AntiJoinEmptyOperand()
  const r = [{A: 1}]
  const s = []
  const result = Query(AntiJoin(r, s, (t, u) => t.A == u.A))

  assert_equal(r, result)
enddef

def Test_RA_LeftNatJoin()
  var Buffer = Rel.new('Buffer', {
      BufId:   Int,
      BufName:  Str,
    },
    [['BufId'], ['BufName']]
  )

  var Tag = Rel.new('Tag', {
      BufId:   Int,
      TagName: Str,
      Line:    Int,
      Column:  Int,
    },
    [['BufId', 'TagName']]
  )

  Buffer.InsertMany([
    {BufId: 1, BufName: 'foo'},
    {BufId: 2, BufName: 'bar'},
    {BufId: 3, BufName: 'xyz'},
  ])

  Tag.InsertMany([
    {BufId: 1, TagName: 'abc', Line: 3,  Column: 9},
    {BufId: 1, TagName: 'xyz', Line: 4,  Column: 1},
    {BufId: 1, TagName: 'lll', Line: 4,  Column: 8},
    {BufId: 2, TagName: 'abc', Line: 14, Column: 15},
  ])

  const summary = Query(Tag->GroupBy('BufId')->Count({name: 'num_tags'}))
  const result = Query(From(Buffer)->LeftNatJoin(summary, {filler: [{'num_tags': 0}]}))
  const expected = [
    {BufId: 1, BufName: 'foo', num_tags: 3},
    {BufId: 2, BufName: 'bar', num_tags: 1},
    {BufId: 3, BufName: 'xyz', num_tags: 0},
  ]

  assert_true(RelEq(result, expected))
enddef

def Test_RA_LeftEquiJoin()
  var r = [
    {A: 1, B: 'x'},
    {A: 2, B: 'x'},
    {A: 3, B: 'y'},
    {A: 4, B: 'z'},
    {A: 5, B: 'w'},
  ]
  var s = [
    {C: 'x', A: 10},
    {C: 'z', A: 20},
    {C: 'z', A: 30},
  ]
  var result = Query(LeftEquiJoin(r, s, {onleft: 'B', onright: 'C', filler: [{C: 'NA', A: 0}]}))
  const expected = [
    {A: 1, B: 'x', C:  'x', _A: 10},
    {A: 2, B: 'x', C:  'x', _A: 10},
    {A: 3, B: 'y', C: 'NA', _A:  0},
    {A: 4, B: 'z', C:  'z', _A: 20},
    {A: 4, B: 'z', C:  'z', _A: 30},
    {A: 5, B: 'w', C: 'NA', _A:  0},
  ]

  assert_equal(expected, result)
enddef

def Test_RA_LeftEquiJoinFastPath()
  var R = Rel.new('R', {A: Int, B: Str}, 'A')

  R.InsertMany([
    {A: 0, B: 'zero'},
    {A: 1, B: 'one'},
    {A: 2, B: 'two'},
  ])

  var S = Rel.new('S', {A: Int, C: Float}, 'A')

  S.InsertMany([
    {A: 1, C: 1.0},
    {A: 0, C: 0.0},
    {A: 3, C: 3.0},
  ])

  var result = Query(LeftEquiJoin(R, S, {on: 'A', filler: [{A: -1, C: -1.0}]}))
  const expected = [
    {A: 0, B: 'zero', _A:  0, C:  0.0},
    {A: 1, B: 'one',  _A:  1, C:  1.0},
    {A: 2, B: 'two',  _A: -1, C: -1.0},
  ]

  assert_equal(expected, result)
  assert_true(RelEq(result, expected))
enddef

def Test_RA_LeftEquiJoinChained()
  var r = [
    {A: 0},
    {A: 1},
    {A: 2},
  ]
  var s0 = [
    {A: 0, B: 'x'},
    {A: 1, B: 'y'},
  ]
  var s1 = [
    {A: 2, C: 'z'},
  ]
  var R0 = r->LeftEquiJoin(s0, {on: 'A', filler: [{A: -1, B: ''}], prefix: 's0_'})

  const expected0 = [
    {A: 0, B: 'x', s0_A:  0},
    {A: 1, B: 'y', s0_A:  1},
    {A: 2, B: '',  s0_A: -1},
  ]

  assert_equal(expected0, R0->SortBy('A'))

  var R1 = R0->LeftEquiJoin(s1, {on: 'A', filler: [{A: -2, C: ''}], prefix: 's1_'})

  const expected1 = [
    {A: 0, B: 'x', s0_A:  0, C: '',  s1_A: -2},
    {A: 1, B: 'y', s0_A:  1, C: '',  s1_A: -2},
    {A: 2, B: '',  s0_A: -1, C: 'z', s1_A:  2},
  ]

  assert_equal(expected1, R1->SortBy('A'))
enddef

def Test_RA_Lookup()
  var R = Rel.new('R', {A: Int, B: Str}, 'A')
  R.InsertMany([{A: 1, B: 'x'}, {A: 3, B: 'y'}, {A: 5, B: 'z'}])

  assert_equal({A: 1, B: 'x'}, R.Lookup(['A'], [1]))
  assert_equal({A: 3, B: 'y'}, R.Lookup(['A'], [3]))
  assert_equal({A: 5, B: 'z'}, R.Lookup(['A'], [5]))

  AssertFails(() => {
    R.Lookup(['X'], [1])
  }, 'not a key of R')
enddef

def Test_RA_Extend()
  var R = Rel.new('R', {A: Int}, [['A']])

  R.InsertMany([{A: 1}, {A: 3}, {A: 5}])

  const expected = [
    {A: 1, B: 2,  C: 'ok'},
    {A: 3, B: 6,  C: 'ok'},
    {A: 5, B: 10, C: 'ok'},
  ]
  var result = Query(
    R->Extend((t) => {
      return {B: t.A * 2, C: 'ok'}
    })
  )

  assert_equal(expected, result)

  const expected2 = [
    {A: 2, C: 0},
    {A: 4, C: 2},
    {A: 6, C: 4},
  ]
  var result2 = Query(
    R->Extend((t) => {
      return {A: t.A + 1, C: t.A - 1}
    }, {force: true})
  )

  assert_equal(expected, result)

  tt.AssertFails(() => {
    Query(
      R->Extend((t) => {
        return {A: t.A + 1, C: t.A - 1}
      })
    )
  }, 'Key already exists: A')
enddef

def Test_RA_Max()
  var R = Rel.new('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.Instance()

  assert_equal([{max: null}], Query(R->Max('A')))
  assert_equal([{max: null}], Query(R->Max('B')))
  assert_equal([{max: null}], Query(R->Max('C')))
  assert_equal([{maximum: null}], Query(R->Max('D', {name: 'maximum'})))

  const instance = [
    {A: 0, B: "X", C: 10.0, D:  true},
    {A: 1, B: "Z", C:  2.5, D:  true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D:  true},
    {A: 4, B: "Z", C:  2.5, D:  true},
  ]
  R.InsertMany(instance)

  assert_equal([{max:    4}], Query(R->Max('A')))
  assert_equal([{max:  'Z'}], Query(R->Max('B')))
  assert_equal([{max: 10.0}], Query(R->Max('C')))
  assert_equal([{max: true}], Query(R->Max('D')))

  assert_equal(instance, r)
enddef

def Test_RA_Min()
  var R = Rel.new('R', {A: Int, B: Str, C: Float, D: Bool}, [['A']])
  const r = R.Instance()

  assert_equal([{min: null}], Query(R->Min('A')))
  assert_equal([{min: null}], Query(R->Min('B')))
  assert_equal([{min: null}], Query(R->Min('C')))
  assert_equal([{minimum: null}], Query(R->Min('D', {name: 'minimum'})))

  const instance = [
    {A: 0, B: "X", C: 10.0, D:  true},
    {A: 1, B: "Z", C:  2.5, D:  true},
    {A: 2, B: "Y", C: -3.0, D: false},
    {A: 3, B: "X", C:  1.5, D:  true},
    {A: 4, B: "Z", C:  2.5, D:  true},
  ]
  R.InsertMany(instance)

  assert_equal([{min: 0}],     Query(R->Min('A')))
  assert_equal([{min: 'X'}],   Query(R->Min('B')))
  assert_equal([{min: -3.0}],  Query(R->Min('C')))
  assert_equal([{min: false}], Query(R->Min('D')))
  assert_equal(instance, r)
enddef

def Test_RA_Sum()
  var R = Rel.new('R', {A: Int, B: Float}, [['A']])
  const r = R.Instance()

  assert_equal([{sum: 0.0}], Query(R->Sum('A')))
  assert_equal([{sum: 0.0}], Query(R->Sum('B')))

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5},
  ]
  R.InsertMany(instance)

  assert_equal([{sum: 10.0}], Query(R->Sum('A')))
  assert_equal([{sum: 13.5}], Query(R->Sum('B')))
  assert_equal(instance, r)
enddef

def Test_RA_Avg()
  var R = Rel.new('R', {A: Int, B: Float}, [['A']])
  const r = R.Instance()

  assert_equal([{avg: null}], Query(R->Avg('A')))
  assert_equal([{mean: null}], Query(R->Avg('B', {name: 'mean'})))

  const instance = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 2, B: -3.0},
    {A: 3, B:  1.5},
    {A: 4, B:  2.5},
  ]
  R.InsertMany(instance)

  assert_equal([{avg: 2.0}], Query(R->Avg('A')))
  assert_equal([{avg: 2.7}], Query(R->Avg('B')))
  assert_equal(instance, r)
enddef

def Test_RA_Count()
  const r = [
    {id: 0, A: 0, B: 10.0},
    {id: 1, A: 2, B:  2.5},
    {id: 2, A: 2, B: -3.0},
    {id: 3, A: 2, B:  1.5},
    {id: 4, A: 4, B:  2.5},
    {id: 5, A: 4, B:  2.5},
  ]

  assert_equal([{count: 0}], Query([]->Count()))
  assert_equal([{n: 6}], Query(r->Count({name: 'n'})))
enddef

def Test_RA_CountDistinct()
  const r = [
    {id: 0, A: 0, B: 10.0},
    {id: 1, A: 2, B:  2.5},
    {id: 2, A: 2, B: -3.0},
    {id: 3, A: 2, B:  1.5},
    {id: 4, A: 4, B:  2.5},
    {id: 5, A: 4, B:  2.5},
  ]

  assert_equal([{count: 0}], Query([]->CountDistinct('A')))
  assert_equal([{count: 3}], Query(r->CountDistinct('A')))
  assert_equal([{n: 4}], Query(r->CountDistinct('B', {name: 'n'})))
enddef

def Test_RA_ListAggregate()
  const r = [
    {id: 0, A: 0, B: 10.0},
    {id: 1, A: 2, B:  2.5},
    {id: 2, A: 2, B: -3.0},
    {id: 3, A: 2, B:  1.5},
    {id: 4, A: 4, B:  2.5},
    {id: 5, A: 4, B:  2.5},
  ]
  const expected = [
    {A: 0, B: [10.0]},
    {A: 2, B: [2.5, -3.0, 1.5]},
    {A: 4, B: [2.5, 2.5]},
  ]

  assert_equal([{A: []}], Query([]->ListAggregate('A')), '01')
  assert_equal([{A: [0, 2, 2, 2, 4, 4]}], Query(r->ListAggregate('A')), '02')
  assert_equal([{B: [10.0, 2.5, -3.0, 1.5, 2.5, 2.5]}], Query(r->ListAggregate('B', {})), '03')
  assert_equal(
    [{values: [-3.0, 1.5, 2.5, 2.5, 2.5, 10.0]}],
    Query(r->ListAggregate('B', {how: 'f', name: 'values'})),
    '04'
  )

  var grouping = r->GroupBy('A')

  assert_equal(['A'], grouping.attributes)
  assert_equal({
    0: [
      {id: 0, A: 0, B: 10.0},
    ],
    2: [
      {id: 1, A: 2, B:  2.5},
      {id: 2, A: 2, B: -3.0},
      {id: 3, A: 2, B:  1.5},
    ],
    4: [
      {id: 4, A: 4, B:  2.5},
      {id: 5, A: 4, B:  2.5},
    ],
  }, grouping.groups)

  assert_equal(expected, r->GroupBy(['A'])->ListAggregate('B')->SortBy('A'), '05')
enddef

def Test_RA_ListAggregateUnique()
  const r = [
    {id: 0, A: 0, B: 10.0},
    {id: 1, A: 2, B:  2.5},
    {id: 2, A: 2, B: -3.0},
    {id: 3, A: 2, B:  2.5},
    {id: 4, A: 4, B:  3.5},
    {id: 5, A: 4, B:  3.5},
  ]
  const expected1 = [
    {A: 0, B: [10.0]},
    {A: 2, B: [-3.0, 2.5, 2.5]},
    {A: 4, B: [3.5, 3.5]},
  ]
  const expected2 = [
    {A: 0, B: [10.0]},
    {A: 2, B: [-3.0, 2.5]},
    {A: 4, B: [3.5]},
  ]

  assert_equal(expected1, r->GroupBy('A')->ListAggregate('B', {how: 'f'})->SortBy('A'))
  assert_equal(expected2, r->GroupBy('A')->ListAggregate('B', {how: 'f', unique: true})->SortBy('A'))
enddef

def Test_RA_StringAggregate()
  const r = [
    {id: 0, A: 0, B: 'a'},
    {id: 1, A: 2, B: 'c'},
    {id: 2, A: 2, B: 'f'},
    {id: 3, A: 2, B: 'p'},
    {id: 4, A: 4, B: 'b'},
    {id: 5, A: 4, B: 'm'},
  ]

  assert_equal([{A: ''}], Query([]->StringAggregate('A')))
  assert_equal([{A: '0.2.2.2.4.4'}], Query(r->StringAggregate('A', {sep: '.'})))
  assert_equal(
    [{values: 'a, b, c, f, m, p'}],
    Query(r->StringAggregate('B', {sep: ', ', how: '', name: 'values'}))
  )

  var result = r
    ->GroupBy('A')
    ->StringAggregate('B', {sep: ',', how: (x, y) => x == y ? 0 : x > y ? -1 : 1})
    ->SortBy('A')

  const expected = [
    {A: 0, B: 'a'},
    {A: 2, B: 'p,f,c'},
    {A: 4, B: 'm,b'},
  ]

  assert_equal(expected, result)
enddef

def Test_RA_StringAggregate_Unique()
  const r = [
    {id: 0, A: 0, B: 'a'},
    {id: 1, A: 2, B: 'a'},
    {id: 2, A: 2, B: 'a'},
    {id: 3, A: 2, B: 'p'},
    {id: 4, A: 4, B: 'b'},
    {id: 5, A: 4, B: 'b'},
  ]
  const expected1 = [
    {A: 0, B: 'a'},
    {A: 2, B: 'a,a,p'},
    {A: 4, B: 'b,b'},
  ]
  const expected2 = [
    {A: 0, B: 'a'},
    {A: 2, B: 'a,p'},
    {A: 4, B: 'b'},
  ]
  const result1 = r->GroupBy('A')->StringAggregate('B', {sep: ',', how: 'i'})->SortBy('A')
  const result2 = r->GroupBy('A')->StringAggregate('B', {sep: ',', how: 'i', unique: true})->SortBy('A')

  assert_equal(expected1, result1)
  assert_equal(expected2, result2)
enddef

def Test_RA_SumBy()
  assert_equal([{sum: 0}],   From([])->SumBy([], 'A'))
  assert_equal([{summa: 0}], From([])->SumBy([], 'B', 'summa'))
  assert_equal([],           From([])->SumBy(['A'], 'A'))
  assert_equal([],           From([])->SumBy('B', 'A', 'summa'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{sum: 8}],   From(r)->SumBy([], 'A'))
  assert_equal(13.5, From(r)->SumBy([], 'B')[0].sum)
  assert_equal([
    {A: 0, sum: 10.0},
    {A: 1, sum: -0.5},
    {A: 3, sum:  4.0},
  ], From(r)->SumBy(['A'], 'B'))
enddef

def Test_RA_CountBy()
  assert_equal([{count: 0}], From([])->CountBy([]))
  assert_equal([{count: 0}], From([])->CountBy([], 'A'))
  assert_equal([{cnt: 0}],   From([])->CountBy([], 'B', 'cnt'))
  assert_equal([],           From([])->CountBy(['A'], 'A'))
  assert_equal([],           From([])->CountBy(['B'], 'A', 'cnt'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{count: 5}], From(r)->CountBy([]))
  assert_equal([{count: 3}], From(r)->CountBy([], 'A'))
  assert_equal([{count: 4}], From(r)->CountBy([], 'B'))
  assert_equal([
    {A: 0, cnt: 1},
    {A: 1, cnt: 2},
    {A: 3, cnt: 2},
  ], From(r)->CountBy(['A'], null_string, 'cnt'))
  assert_equal([
    {A: 0, cnt: 1},
    {A: 1, cnt: 2},
    {A: 3, cnt: 2},
  ], From(r)->CountBy('A', 'B', 'cnt'))
enddef

def Test_RA_MaxBy()
  assert_equal([], From([])->MaxBy([], 'A'))
  assert_equal([], From([])->MaxBy([], 'B'))
  assert_equal([], From([])->MaxBy(['A'], 'A'))
  assert_equal([], From([])->MaxBy('B', 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{max: 3}],    From(r)->MaxBy([], 'A'))
  assert_equal([{max: 10.0}], From(r)->MaxBy([], 'B'))
  assert_equal([
    {A: 0, maximum: 10.0},
    {A: 1, maximum:  2.5},
    {A: 3, maximum:  2.5},
  ], From(r)->MaxBy(['A'], 'B', 'maximum'))
enddef

def Test_RA_MinBy()
  assert_equal([], []->MinBy([], 'A'))
  assert_equal([], []->MinBy([], 'B'))
  assert_equal([], []->MinBy(['A'], 'A'))
  assert_equal([], []->MinBy('B', 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{min: 0}],    From(r)->MinBy([], 'A'))
  assert_equal([{min: -3.0}], From(r)->MinBy([], 'B'))
  assert_equal([
    {A: 0, minimum: 10.0},
    {A: 1, minimum: -3.0},
    {A: 3, minimum:  1.5},
  ], From(r)->MinBy(['A'], 'B', 'minimum'))
enddef

def Test_RA_AvgBy()
  assert_equal([], From([])->AvgBy([], 'A'))
  assert_equal([], From([])->AvgBy([], 'B'))
  assert_equal([], From([])->AvgBy(['A'], 'A'))
  assert_equal([], From([])->AvgBy('B', 'A'))

  const r = [
    {A: 0, B: 10.0},
    {A: 1, B:  2.5},
    {A: 1, B: -3.0},
    {A: 3, B:  1.5},
    {A: 3, B:  2.5},
  ]

  assert_equal([{avg: 1.6}], From(r)->AvgBy([], 'A'))
  assert_equal([{avg: 2.7}], From(r)->AvgBy([], 'B'))
  assert_equal([
    {A: 0, average: 10.0},
    {A: 1, average: -0.25},
    {A: 3, average:  2.0},
  ], From(r)->AvgBy(['A'], 'B', 'average'))
enddef

def Test_RA_Frame()
  var R = Rel.new('R', {A: Int, B: Str, C: Str}, [['A']])
  R.InsertMany([
    {A: 10, B: 'a', C: 'x'},
    {A: 20, B: 'b', C: 'y'},
    {A: 30, B: 'a', C: 'x'},
    {A: 40, B: 'a', C: 'x'},
    {A: 50, B: 'b', C: 'x'},
    {A: 60, B: 'b', C: 'y'},
    {A: 70, B: 'a', C: 'y'},
  ])

  var result = Query(
    From(R)->Extend((t) => {
      return {fid: t.A / 30}
    })
  )
  var expected = [
    {A: 10, B: 'a', C: 'x', fid: 0},
    {A: 20, B: 'b', C: 'y', fid: 0},
    {A: 30, B: 'a', C: 'x', fid: 1},
    {A: 40, B: 'a', C: 'x', fid: 1},
    {A: 50, B: 'b', C: 'x', fid: 1},
    {A: 60, B: 'b', C: 'y', fid: 2},
    {A: 70, B: 'a', C: 'y', fid: 2},
  ]
  assert_true(RelEq(expected, result), '01')

  result = Query(From(R)->Frame(['B', 'C']))
  expected = [
    {A: 10, B: 'a', C: 'x', fid: 0},
    {A: 20, B: 'b', C: 'y', fid: 1},
    {A: 30, B: 'a', C: 'x', fid: 0},
    {A: 40, B: 'a', C: 'x', fid: 0},
    {A: 50, B: 'b', C: 'x', fid: 2},
    {A: 60, B: 'b', C: 'y', fid: 1},
    {A: 70, B: 'a', C: 'y', fid: 3},
  ]
  assert_true(RelEq(expected, result), '02')
  assert_equal(expected, result)

  result = Query(R->Frame('B', {name: 'foo'}))
  expected = [
    {A: 10, B: 'a', C: 'x', foo: 0},
    {A: 20, B: 'b', C: 'y', foo: 1},
    {A: 30, B: 'a', C: 'x', foo: 0},
    {A: 40, B: 'a', C: 'x', foo: 0},
    {A: 50, B: 'b', C: 'x', foo: 1},
    {A: 60, B: 'b', C: 'y', foo: 1},
    {A: 70, B: 'a', C: 'y', foo: 0},
  ]
  assert_true(RelEq(expected, result), '03')
  assert_true(RelEq(Query(Project(expected, ['A', 'B', 'C'])), R.Instance()), '04')

  result = Query(R->Frame('B', {name: 'foo', inplace: true}))

  assert_true(RelEq(expected, result), '05')
  assert_true(RelEq(expected, R.Instance()), '06')
enddef

def Test_RA_GroupBy()
  var R = Rel.new('R', {id: Int, name: Str, balance: Float, class: Str}, 'id')
  const r = R.Instance()

  const instance = [
    {id: 0, name: "A", balance: 10.0, class: "X"},
    {id: 1, name: "A", balance:  3.5, class: "X"},
    {id: 2, name: "B", balance: -3.0, class: "X"},
    {id: 3, name: "A", balance:  1.5, class: "Y"},
    {id: 4, name: "B", balance:  2.5, class: "X"},
  ]
  R.InsertMany(instance)

  var result = r
    ->GroupBy(['name'])
    ->Sum('balance', {name: 'total'})
    ->SortBy('name')

  var expected = [
    {name: 'A', total: 15.0},
    {name: 'B', total: -0.5},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name')->Max('balance')->SortBy('name')

  expected = [
    {name: 'A', max: 10.0},
    {name: 'B', max: 2.5},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name')->Min('balance')->SortBy('name')

  expected = [
    {name: 'A', min: 1.5},
    {name: 'B', min: -3.0},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name')->Avg('balance')->SortBy('name')

  expected = [
    {name: 'A', avg: 5.0},
    {name: 'B', avg: -0.25},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name')->Count()->SortBy('name')

  expected = [
    {name: 'A', count: 3},
    {name: 'B', count: 2},
  ]

  assert_equal(expected, result)

  result = r->GroupBy('name')->CountDistinct('class', {name: 'num_class'})->SortBy('name')

  expected = [
    {name: 'A', num_class: 2},
    {name: 'B', num_class: 1},
  ]

  assert_equal(expected, result)

  assert_equal(instance, r)
enddef

def Test_RA_CoddDivide()
  var Subscription = Rel.new('Subscription',
    {student: Str, date: Str, course: Str},
    [['student', 'course']]
  )
  const subscription = Subscription.Instance()
  const subscription_instance = [
    {student: '123', date: '2019-12-05', course:        'Databases'},
    {student: '283', date: '2019-12-05', course:        'Databases'},
    {student: '123', date: '2020-12-05', course: 'Computer Science'},
    {student: '123', date: '2021-12-05', course:          'Algebra'},
    {student: '283', date: '2021-12-05', course:          'Algebra'},
    {student: '375', date: '2015-01-06', course:        'Databases'},
    {student: '283', date: '2020-12-05', course: 'Computer Science'},
    {student: '303', date: '2020-12-05', course: 'Computer Science'},
  ]
  Subscription.InsertMany(subscription_instance)

  var Session = Rel.new('Session', {date: Str, course: Str}, [['date', 'course']])
  const result1 = Query(From(Subscription)->CoddDivide(Session))
  const expected1 = [
    {student: '123'},
    {student: '283'},
    {student: '375'},
    {student: '303'},
  ]

  assert_equal(expected1, result1)

  # If the divisor is an empty *derived* relation, the divisor carries no
  # information about its schema. Short of explicitly providing a schema,
  # the choice is arbitrary: we assume that the schema is empty.
  const result2 = Query(From(Subscription)->CoddDivide([]))
  const expected2 = subscription_instance
  # The schema can be given explicitly, though (for this special case only)
  const result3 = Query(From(Subscription)->CoddDivide([], ['date', 'course']))
  const expected3 = expected1

  assert_equal(expected2, result2)
  assert_equal(expected3, result3)

  const session = Session.Instance()
  const session_instance = [
    {date: '2019-12-05', course:        'Databases'},
    {date: '2020-12-05', course: 'Computer Science'},
    {date: '2021-12-05', course:          'Algebra'},
  ]
  Session.InsertMany(session_instance)

  # Which students are subscribed to all the courses?
  const result4 = From(Subscription)->CoddDivide(Session)->SortBy('student')
  const expected4 = [
    {'student': '123'},
    {'student': '283'},
  ]
  assert_equal(expected4, result4)

  # Todd's division must return the same result
  const result5 = From(Subscription)->Divide(Session)->SortBy('student')
  const expected5 = [
    {'student': '123'},
    {'student': '283'},
  ]
  assert_equal(expected5, result5)

  assert_equal(subscription_instance, subscription)
  assert_equal(session_instance, session)
enddef

def Test_RA_Divide()
  const SP = [  # Supplier S# supplies part P#
    {'S#': 1, 'P#': 10},
    {'S#': 1, 'P#': 20},
    {'S#': 1, 'P#': 30},
    {'S#': 2, 'P#': 10},
    {'S#': 2, 'P#': 20},
    {'S#': 3, 'P#': 20},
    {'S#': 3, 'P#': 40},
  ]
  const PJ = [  # Part P# is used in project J#
    {'P#': 10, 'J#': 100},
    {'P#': 20, 'J#': 100},
    {'P#': 20, 'J#': 200},
    {'P#': 30, 'J#': 200},
    {'P#': 20, 'J#': 300},
    {'P#': 40, 'J#': 300},
  ]
  # Find the pairs {S,J} such that
  # supplier S supplies all the parts used in project J:
  const result = Query(From(SP)->Divide(PJ))
  const expected = [
    {'S#': 1, 'J#': 100},
    {'S#': 1, 'J#': 200},
    {'S#': 2, 'J#': 100},
    {'S#': 3, 'J#': 300},
  ]
  assert_true(RelEq(expected, result),
    printf("Expected %s, but got %s", expected, result))

  # Find the pairs {J,S} such that
  # project J uses all the parts supplied by supplier S
  const result2 = Query(From(PJ)->Divide(SP))
  const expected2 = [
    {'J#': 100, 'S#': 2},
    {'J#': 300, 'S#': 3},
  ]

  assert_true(RelEq(expected2, result2),
    printf("Expected %s, but got %s", expected2, result2))

  const PJEmpty = Rel.new('PJ', {'P#': Int, 'J#': Int}, [['J#', 'P#']])

  assert_equal([], Query(From(SP)->Divide(PJEmpty)))
  assert_equal([], Query(From(SP)->Divide([])))
enddef

def Test_RA_EmptyKey()
  var RR = Rel.new('RR', {'A': Int, 'B': Str}, [[]])

  AssertFails(() => {
    RR.Insert({})
  }, "Expected a tuple on schema {A: integer, B: string}: got {} instead")

  RR.Insert({A: 1, B: 'x'})

  assert_equal([{A: 1, B: 'x'}], RR.Instance())

  AssertFails(() => {
    RR.Insert({A: 2, B: 'y'})
  }, "Duplicate key")

  RR.Delete()
  RR.Insert({A: 2, B: 'y'})

  assert_equal([{A: 2, B: 'y'}], RR.Instance())
enddef

def Test_RA_DivideEdgeCases()
  # For further edge cases, see Test_RA_DeeDum()
  assert_equal([],       Query(From([{X: 1}])->Divide([])))
  assert_equal([],       Query(From([{X: 1, Y: 2}])->Divide([])))
  assert_equal([],       Query(From([])->Divide([{Y: 1}])))
  assert_equal([],       Query(From([])->Divide([{Y: 1, Z: 2}])))
  assert_equal([{}],     Query(From([{Y: 1}])->Divide([{Y: 1}])))
  assert_equal([{}],     Query(From([{Y: 1}, {Y: 2}])->Divide([{Y: 1}])))
  assert_equal([{Z: 2}], Query(From([{Y: 1}])->Divide([{Y: 1, Z: 2}])))
  assert_equal([{Z: 2}], Query(From([{Y: 1}, {Y: 2}])->Divide([{Y: 1, Z: 2}])))
enddef

def Test_RA_DeeDum()
  var RR = Rel.new('Dee', {}, [[]])
  assert_equal(0, len(RR.Instance()))
  AssertFails(() => {
    RR.Insert({A: 0})
  }, "Expected a tuple on schema {}")

  RR.Insert({})

  assert_equal(1, len(RR.Instance()))
  AssertFails(() => {
    RR.Insert({})
  }, "Duplicate key")

  var Dum = Rel.new('Dum', {}, [[]])
  var Dee = RR
  const dum = Dum.Instance()
  const dee = Dee.Instance()
  const r   = [{A: 1}, {A: 2}]

  assert_equal([],   From(r)->NatJoin(dum)->Build(),           "r ⨝ dum")
  assert_equal(r,    From(r)->NatJoin(dee)->Build(),           "r ⨝ dee")
  assert_equal([],   From(dum)->NatJoin(r)->Build(),           "dum ⨝ r")
  assert_equal(r,    From(dee)->NatJoin(r)->Build(),           "dee ⨝ r")

  assert_equal([],   From(dum)->NatJoin(dum)->Build(),         "dum ⨝ dum")
  assert_equal([],   From(dum)->NatJoin(dee)->Build(),         "dum ⨝ dee")
  assert_equal([],   From(dee)->NatJoin(dum)->Build(),         "dee ⨝ dum")
  assert_equal([{}], From(dee)->NatJoin(dee)->Build(),         "dee ⨝ dee")

  assert_equal([],           From(dum)->Select((t) => true)->Build(),              "σ[true](dum)")
  assert_equal([],           From(dum)->Select((t) => false)->Build(),             "σ[false](dum)")
  assert_equal([{}],         From(dee)->Select((t) => true)->Build(),              "σ[true](dee)")
  assert_equal([],           From(dee)->Select((t) => false)->Build(),             "σ[false](dee)")

  assert_equal([],           From(dum)->Project([])->Build(),                      "π[](dum)")
  assert_equal([{}],         From(dee)->Project([])->Build(),                      "π[](dee)")

  assert_equal([],           From(dum)->Product(dum)->Build(),                     "dum × dum")
  assert_equal([],           From(dum)->Product(dee)->Build(),                     "dum × dee")
  assert_equal([],           From(dee)->Product(dum)->Build(),                     "dee × dum")
  assert_equal([{}],         From(dee)->Product(dee)->Build(),                     "dee × dee")

  assert_equal([],           From(dum)->Intersect(dum)->Build(),                   "dum ∩ dum")
  assert_equal([],           From(dum)->Intersect(dee)->Build(),                   "dum ∩ dee")
  assert_equal([],           From(dee)->Intersect(dum)->Build(),                   "dee ∩ dum")
  assert_equal([{}],         From(dee)->Intersect(dee)->Build(),                   "dee ∩ dee")

  assert_equal([],           From(dum)->Minus(dum)->Build(),                       "dum - dum")
  assert_equal([],           From(dum)->Minus(dee)->Build(),                       "dum - dee")
  assert_equal([{}],         From(dee)->Minus(dum)->Build(),                       "dee - dum")
  assert_equal([],           From(dee)->Minus(dee)->Build(),                       "dee - dee")

  assert_equal([],           From(dum)->SemiJoin(dum, (t1, t2) => true)->Build(),  "dum ⋉ dum")
  assert_equal([],           From(dum)->SemiJoin(dee, (t1, t2) => true)->Build(),  "dum ⋉ dee")
  assert_equal([],           From(dee)->SemiJoin(dum, (t1, t2) => true)->Build(),  "dee ⋉ dum")
  assert_equal([{}],         From(dee)->SemiJoin(dee, (t1, t2) => true)->Build(),  "dee ⋉ dee")

  assert_equal([],           From(dum)->AntiJoin(dum, (t1, t2) => true)->Build(),  "dum ▷ dum")
  assert_equal([],           From(dum)->AntiJoin(dee, (t1, t2) => true)->Build(),  "dum ▷ dee")
  assert_equal([{}],         From(dee)->AntiJoin(dum, (t1, t2) => true)->Build(),  "dee ▷ dum")
  assert_equal([],           From(dee)->AntiJoin(dee, (t1, t2) => true)->Build(),  "dee ▷ dee")

  assert_equal([],           From(dum)->GroupBy([])->Count({name: 'agg'})->Build(), "dum group by []")
  assert_equal([{'agg': 1}], From(dee)->GroupBy([])->Count({name: 'agg'})->Build(), "dee group by []")

  assert_equal([],           From(dum)->CoddDivide(dum)->Build(),           "dum ÷ dum")
  assert_equal([],           From(dum)->CoddDivide(dee)->Build(),           "dum ÷ dee")
  assert_equal([{}],         From(dee)->CoddDivide(dum)->Build(),           "dee ÷ dum")
  assert_equal([{}],         From(dee)->CoddDivide(dee)->Build(),           "dee ÷ dee")

  assert_equal([],           From(dum)->Divide(dum)->Build(),               "dum ÷ dum")
  assert_equal([],           From(dum)->Divide(dee)->Build(),               "dum ÷ dee")
  # Todd's division returns [] whenever the divisor is empty
  assert_equal([],           From(dee)->Divide(dum)->Build(),               "dee ÷ dum")
  assert_equal([{}],         From(dee)->Divide(dee)->Build(),               "dee ÷ dee")
enddef

def Test_RA_Transform()
  const r = [{X: 3, Y: 6}, {X: 5, Y: 2}]
  const expected1 = [18, 10]

  assert_equal(expected1, Transform(r, (t) => t.X * t.Y))

  const s = [{when: "now", where: "here", how: "fast"}]
  const expected2 = ["nowhere"]

  assert_equal(expected2, Transform(s, (t) => t.when .. t.where))
enddef

def Test_RA_TransformSkipTuples()
  const r = [{X: 2}, {X: 1}, {X: 3}, {X: 0}, {X: 5}]
  const expected = [1, 3, 5]

  assert_equal(
    expected,
    Transform(r, (t) => t.X % 2 == 0 ? null : t.X)
  )

  const s = [{X: 1}, {X: 3}]
  assert_equal([], Transform(s, (t) => t.X % 2 == 0 ? t.X : null))
enddef

def Test_RA_TransformSkipNonPositive()
  const r = [{X: 2}, {X: -1}, {X: 3}, {X: 0}]
  const expected = [2, 3]

  assert_equal(
    expected,
    Transform(r, (t) => t.X <= 0 ? null : t.X)
  )
enddef

def Test_RA_DictTransform()
  const s = [
    {X: 'a', Y: 6},
    {X: 'b', Y: 2},
    {X: 'a', Y: -1}
  ]
  const expected1 = {a: [6, -1], b: [2]}
  const expected2 = {a: [6, -1], b: 2}

  assert_equal(expected1, DictTransform(s, (t) => ({[t.X]: t.Y})))
  assert_equal(expected2, DictTransform(s, (t) => ({[t.X]: t.Y}), true))

  const r = [
    {X: 'a', Y: 6},
    {X: 'b', Y: 2}
  ]
  const expected3 = {a: [6], b: [2]}
  const expected4 = {a: 6, b: 2}

  assert_equal(expected3, DictTransform(r, (t) => ({[t.X]: t.Y})))
  assert_equal(expected4, DictTransform(r, (t) => ({[t.X]: t.Y}), true))
enddef

def Test_RA_TransformReturnsList()
  const r = [{X: 3, Y: 6}, {X: 5, Y: 4}]
  const expected1 = [6, 18, 9, 10, 12, 9]

  assert_equal(expected1, Transform(r, (t) => [t.X * 2, t.Y * 3, t.X + t.Y]))

  const expected2 = [[9], [9]]

  assert_equal(expected2, Transform(r, (t) => [[t.X + t.Y]]))
enddef

def Test_RA_Split()
  const r = [{A: 1}, {A: 3}, {A: 5}, {A: 2}, {A: 7}]
  const expected1 = [{A: 1}, {A: 2}, {A: 3}]
  const expected2 = [{A: 5}, {A: 7}]
  const [result1, result2] = r->Split((t) => t.A <= 4)

  assert_true(RelEq(expected1, result1))
  assert_true(RelEq(expected2, result2))
enddef

def Test_RA_PartitionBy()
  var R = Rel.new('R', {id: Int, name: Str, balance: Float, class: Str}, 'id')
  const r = R.Instance()

  const instance = [
    {id: 0, name: "a", balance: 10.0, class: "x"},
    {id: 1, name: "a", balance:  3.5, class: "x"},
    {id: 2, name: "b", balance: -3.0, class: "x"},
    {id: 3, name: "a", balance:  1.5, class: "y"},
    {id: 4, name: "b", balance:  2.5, class: "x"},
  ]
  R.InsertMany(instance)

  const result1 = r->PartitionBy('name')
  const expected1 = {
    a: [
      {id: 0, name: "a", balance: 10.0, class: "x"},
      {id: 1, name: "a", balance:  3.5, class: "x"},
      {id: 3, name: "a", balance:  1.5, class: "y"},
    ],
    b: [
      {id: 2, name: "b", balance: -3.0, class: "x"},
      {id: 4, name: "b", balance:  2.5, class: "x"},
    ],
  }

  assert_equal(expected1, result1)

  const result2 = r->PartitionBy(['name', 'class'])
  const expected2 = {
    a: {
      x: [
        {id: 0, name: "a", balance: 10.0, class: "x"},
        {id: 1, name: "a", balance:  3.5, class: "x"},
      ],
      y: [
        {id: 3, name: "a", balance:  1.5, class: "y"},
      ]
    },
    b: {
      x: [
        {id: 2, name: "b", balance: -3.0, class: "x"},
        {id: 4, name: "b", balance:  2.5, class: "x"},
      ],
    }
  }

  assert_equal(expected2, result2)

  const result3 = r->PartitionBy(['name', 'class'], {flat: true})
  const expected3 = {
    "['a', 'x']": [
      {id: 0, name: "a", balance: 10.0, class: "x"},
      {id: 1, name: "a", balance:  3.5, class: "x"},
    ],
    "['a', 'y']": [
      {id: 3, name: "a", balance:  1.5, class: "y"},
    ],
    "['b', 'x']": [
      {id: 2, name: "b", balance: -3.0, class: "x"},
      {id: 4, name: "b", balance:  2.5, class: "x"},
    ],
  }

  assert_equal(expected3, result3)
enddef

def Test_RA_Zip()
  assert_equal({A: 7, B: 'v'}, Zip(['A', 'B'], [7, 'v']))
  # If the second list is longer than the first items in excess are ignored:
  assert_equal({X: 9}, Zip(['X'], [9, 8, 7]))
enddef

def Test_RA_Filter()
  var R = Rel.new('R', {A: Int, B: Int}, [['A']])

  R.InsertMany([
    {A: 0, B: 10},
    {A: 2, B: 30},
    {A: 1, B: 20},
    {A: 3, B: 40},
  ])

  const expected = [{A: 2, B: 30}, {A: 3, B: 40}]
  assert_equal(expected, R->Filter((t) => t.B > 20))

  const expected2 = [{A: 2, B: 30}]
  assert_equal(expected2, Filter(expected, (t) => t.A == 2))
enddef

def Test_RA_Table()
  var R = Rel.new("R", {AAAAAAAAA: Int, B: Str}, [["AAAAAAAAA"]])

  var expectedTable =<< END
 Empty Instance
================
END

  assert_equal(expectedTable, split(Table(R, {name: 'Empty Instance', sep: '='}), "\n"))

  R.InsertMany([
    {AAAAAAAAA: 1, B: 'XYWZ'},
    {AAAAAAAAA: 2, B: 'ABC'},
  ])

  expectedTable =<< END
 R
────────────────
    B AAAAAAAAA
────────────────
 XYWZ         1
  ABC         2
END

  assert_equal(expectedTable, split(Table(R), "\n"))

  expectedTable =<< END
 Very Long Table Name
──────────────────────
          B AAAAAAAAA
──────────────────────
       XYWZ         1
        ABC         2
END

  assert_equal(expectedTable, split(Table(R, {name: 'Very Long Table Name'}), "\n"))

  expectedTable =<< END
 R
────────────────────────────────
            B         AAAAAAAAA
────────────────────────────────
         XYWZ                 1
          ABC                 2
END

  assert_equal(expectedTable, split(Table(R, {gap: 9}), "\n"))
enddef


def Test_RA_PrettyPrintUnicode()
  var R = Rel.new("R", {'🙂☀︎': Int, '✔︎✖︎': Str}, [['✔︎✖︎']])

  R.InsertMany([
    {'🙂☀︎': 9, '✔︎✖︎': '⌘'},
    {'🙂☀︎': 99, '✔︎✖︎': '►◀︎└┴┴┴┘'},
  ])

  const expectedTable =<< END
 R
─────────────
      ✔︎✖︎ 🙂☀︎
─────────────
       ⌘   9
 ►◀︎└┴┴┴┘  99
END

  assert_equal(expectedTable, split(Table(R), "\n"))
enddef

def Test_RA_TableColumns()
  const r = [{A: 9, B: 1}, {A: 11, B: 5}]

  var expected =<< END
 Test
──────
 B  A
──────
 1  9
 5 11
END

  assert_equal(expected, split(Table(r, {name: 'Test', columns: ['B', 'A']}), "\n"))

  expected =<< END
───
 B
───
 1
 5
END

  assert_equal(expected, split(Table(r, {columns: ['B']}), "\n"))

  expected =<< END
────
  A
────
  9
 11
END

  assert_equal(expected, split(Table(r, {columns: 'A'}), "\n"))
enddef

def Test_RA_TransitiveClosure()
  var Node = Rel.new('Node', {NodeNo: Int}, ['NodeNo'])
  var Edge = Rel.new('Edge', {From: Int, To: Int}, ['From', 'To'])

  ForeignKey(Edge, 'From')->References(Node, {key: 'NodeNo'})
  ForeignKey(Edge, 'To')->References(Node) # References primary key (i.e., first key) by default

  Node.InsertMany([
    {NodeNo: 1},
    {NodeNo: 2},
    {NodeNo: 3},
    {NodeNo: 4},
    {NodeNo: 5},
    {NodeNo: 6},
  ])
  Edge.InsertMany([
    {From: 1, To: 2},
    {From: 2, To: 3},
    {From: 3, To: 4},
    {From: 4, To: 5},
    {From: 5, To: 6},
  ])

  var expected = [
    {From: 1, To: 2},
    {From: 2, To: 3},
    {From: 3, To: 4},
    {From: 4, To: 5},
    {From: 5, To: 6},
    {From: 1, To: 3},
    {From: 2, To: 4},
    {From: 3, To: 5},
    {From: 4, To: 6},
    {From: 1, To: 4},
    {From: 2, To: 5},
    {From: 3, To: 6},
    {From: 1, To: 5},
    {From: 2, To: 6},
    {From: 1, To: 6},
  ]

  var Path = (R: any): any => {
    return NatJoin(Rename(R, {To: '_'}), Rename(Edge, {From: '_'}))->Project(['From', 'To'])
  }

  var result = Recursive(Edge, Path)

  assert_true(RelEq(expected, result))
enddef

def Test_RA_TransitiveClosureOfCyclicGraph()
  var Node = Rel.new('Node', {NodeNo: Int}, ['NodeNo'])
  var Edge = Rel.new('Edge', {From: Int, To: Int}, ['From', 'To'])

  ForeignKey(Edge, 'From')->References(Node)
  ForeignKey(Edge, 'To')->References(Node)

  Node.InsertMany([
    {NodeNo: 1},
    {NodeNo: 2},
    {NodeNo: 3},
    {NodeNo: 4},
    {NodeNo: 5},
    {NodeNo: 6},
  ])
  Edge.InsertMany([
    {From: 1, To: 2},
    {From: 2, To: 3},
    {From: 3, To: 4},
    {From: 4, To: 2},
    {From: 5, To: 5},
  ])

  var expected = [
    {From: 1, To: 2},
    {From: 1, To: 3},
    {From: 1, To: 4},
    {From: 2, To: 2},
    {From: 2, To: 3},
    {From: 2, To: 4},
    {From: 3, To: 2},
    {From: 3, To: 3},
    {From: 3, To: 4},
    {From: 4, To: 2},
    {From: 4, To: 3},
    {From: 4, To: 4},
    {From: 5, To: 5},
  ]

  var Path = (R: Relation): Continuation => NatJoin(
    Rename(R,    {To: 'X'}),
    Rename(Edge, {From: 'X'})
  )->Project(['From', 'To'])

  var result = Recursive(Edge, Path)

  assert_true(RelEq(expected, result))
enddef


class View
  var name: string
endclass

def Test_RA_RelationWithObjects()
  var ViewRel = Rel.new('View', {View: Obj, NextView: Obj}, [['View'], ['NextView']])

  # ForeignKey(ViewRel, 'NextView', ViewRel, 'View')

  var v1 = View.new('v1')
  var v2 = View.new('v2')
  var v3 = View.new('v3')

  ViewRel.InsertMany([
    {View: v1, NextView: v2},
    {View: v2, NextView: v3},
    {View: v3, NextView: v1},
  ])

  var result = Query(Select(ViewRel, (t) => t.View is v2))

  assert_equal(1, len(result))
  assert_equal('v2', (<View>result[0].View).name)
enddef


def Test_RA_Transaction()
  var r0 = Rel.new('r0', {A: Int}, 'A')
  var s0 = Rel.new('s0', {B: Int}, 'B')

  Transaction(() => {
    r0.Insert({A: 10})
    s0.Insert({B: 10})
    r0.Insert({A: 20})
    s0.Insert({B: 30})
    s0.Insert({B: 40})
    r0.Delete((t) => t.A < 15)
  })

  assert_equal(1, len(r0.Instance()))
  assert_equal(3, len(s0.Instance()))
enddef

def Test_RA_Next()
  var Edge = Rel.new('Edge', {Node: Int, Next: Int}, [['Node'], ['Next']])

  ForeignKey(Edge, 'Next')->References(Edge, {key: 'Node'})
  Edge.Insert({Node: 1, Next: 1})

  assert_equal([{Node: 1, Next: 1}], Edge.Instance())

  Transaction(() => {
    Edge.Delete((t) => t.Node == 1)
    Edge.Insert({Node: 1, Next: 2})
    Edge.Insert({Node: 2, Next: 1})
  })

  assert_equal([
    {Node: 1, Next: 2},
    {Node: 2, Next: 1},
  ], Edge.Instance())
enddef

def Test_RA_CircularPath()
  var Node = Rel.new('Node', {Node: Int}, 'Node')
  var Edge = Rel.new('Edge', {Node: Int, Next: Int}, [['Node'], ['Next']])

  ForeignKey(Edge, 'Node')->References(Node)
  ForeignKey(Edge, 'Next')->References(Node)

  Node.Insert({Node: 1})
  Edge.Insert({Node: 1, Next: 1})

  Transaction(() => {
    Node.Insert({Node: 2})
    Edge.Delete((t) => t.Node == 1)
    Edge.Insert({Node: 2, Next: 1})
    # What if you do a Select() here?
    Edge.Insert({Node: 1, Next: 2}) # Integrity restored
  })

  Transaction(() => {
    Node.Insert({Node: 3})
    Edge.Delete((t) => t.Next == 1)
    Edge.Insert({Node: 3, Next: 1})
    Edge.Insert({Node: 2, Next: 3})
  })

  var expected = [
    {Node: 1, Next: 2},
    {Node: 2, Next: 3},
    {Node: 3, Next: 1},
  ]

  assert_true(RelEq(expected, Edge.Instance()))
enddef

def Test_RA_Hierarchy()
  var H = Rel.new('Hierarchy', {Node: Int, Parent: Int}, [['Node']])

  ForeignKey(H, 'Parent')->References(H)

  H.Insert({Node: 1, Parent: 1})

  Transaction(() => {
    H.Insert({Node: 2, Parent: 1})
    H.Insert({Node: 3, Parent: 2})
    H.Insert({Node: 4, Parent: 2})
  })

  assert_true(RelEq([
    {Node: 1, Parent: 1},
    {Node: 2, Parent: 1},
    {Node: 3, Parent: 2},
    {Node: 4, Parent: 2},
  ], H.Instance()))
enddef

def Test_RA_ViewHierarchy()
  var BaseView  = Rel.new('View', {View: Int, IsLeaf: Bool, Parent: Int}, [['View']])
  var Container = Rel.new('Container', {View: Int}, 'View')
  var LeafView  = Rel.new('LeafView',  {View: Int}, 'View')

  BaseView.Insert({View: 0, IsLeaf: false, Parent: 0})
  Container.Insert({View: 0})

  ForeignKey(BaseView,  'Parent')->References(Container)
  ForeignKey(Container, 'View')->References(BaseView)
  ForeignKey(LeafView,  'View')->References(BaseView)

  Transaction(() => {
    BaseView.InsertMany([
      {View: 1, Parent:  0, IsLeaf: false},
      {View: 2, Parent:  1, IsLeaf: false},
      {View: 3, Parent:  2, IsLeaf: true},
      {View: 4, Parent:  2, IsLeaf: true},
    ])
    Container.InsertMany([
      {View: 1},
      {View: 2},
    ])
    LeafView.InsertMany([
      {View: 3},
      {View: 4},
    ])
  })

  Transaction(() => {
    LeafView.Delete()
    Container.Delete((t) => t.View > 0)
    BaseView.Delete((t) => t.View > 0)
  })

  assert_equal([{View: 0, IsLeaf: false, Parent: 0}], BaseView.Instance())
  assert_equal([{View: 0}], Container.Instance())
  assert_equal([], LeafView.Instance())
enddef

def Test_RA_BreweryConstraints()
  var Brewery = Rel.new('Brewery',
    {Name: Str, City: Str, Country: Str},
    'Name'
  )
  var Beer = Rel.new('Beer',
    {Name: Str, BrewedBy: Str, AlcPerc: Float},
    'Name'
  )
  var Drinker = Rel.new('Drinker',
    {Name: Str, Beer: Str, QtyBought: Int, QtyDrunk: Int},
    ['Name', 'Beer']
  )

  Beer.OnInsertCheck('I1', (t) => t.AlcPerc > 0)
  ForeignKey(Beer, 'BrewedBy')->References(Brewery, {verb: 'is brewed by'})
  ForeignKey(Drinker, 'Beer')->References(Beer, {verb: 'drinks'})
  Drinker.OnInsertCheck('I4', (t) => t.QtyDrunk <= t.QtyBought)

  # NOTE: this info is made up.
  var brewery = [
    {Name: "Furious Ale", City: "Hasselt",    Country: "Belgium"},
    {Name: "Crown & Son", City: "Anderlecht", Country: "Belgium"},
    {Name: "Drunk Fools", City: "Dalkeith", Country:   "Scotland"},
  ]
  var beer = [
    {Name: "Pegs's Light",  BrewedBy: "Furious Ale", AlcPerc: 2.30},
    {Name: "Korona Strong", BrewedBy: "Crown & Son", AlcPerc: 4.00},
  ]
  var drinker = [
    {Name: "Ken", Beer: "Pegs's Light",  QtyBought: 10, QtyDrunk: 10},
    {Name: "Ken", Beer: "Korona Strong", QtyBought: 5,  QtyDrunk:  0},
  ]

  Brewery.InsertMany(brewery)
  Beer.InsertMany(beer)
  Drinker.InsertMany(drinker)

  AssertFails(() => {
    Beer.Insert({Name: "Negative Hops", BrewedBy: "Drunk Fools", AlcPerc: -1.10})
  }, 'I1')

  Transaction(() => {
    Beer.Insert({Name: "Negative Hops", BrewedBy: "Drunk Fools", AlcPerc: -1.10})
    Beer.Delete((t) => t.AlcPerc <= 0.0)
  })

  AssertFails(() => {
    Beer.Insert({Name: "Hops", BrewedBy: "Drunk Ghosts", AlcPerc: 5.10})
  }, 'Beer is brewed by Brewery')

  AssertFails(() => {
    Brewery.Delete((t) => t.Name == "Crown & Son")
  }, 'Beer is brewed by Brewery')

  Brewery.Delete((t) => t.Name == "Drunk Fools")

  AssertFails(() => {
    Brewery.InsertMany([
      {Name: "Drunk Fools", City: "Dalkeith", Country:   "Scotland"},
      {Name: "Crown & Son", City: "Anderlecht", Country: "Belgium"},
    ])
  }, "Duplicate key: {Name: 'Crown & Son'}")

  AssertFails(() => {
    Drinker.Update((t) => t.Name == "Ken", (t) => {
      t.QtyDrunk = 6
    })
  }, 'I4')

  Drinker.Update((t) => t.Name == "Ken", (t) => {
    t.QtyDrunk = 5
  })

  assert_true(RelEq(beer, Beer.Instance()))
enddef


def Test_RA_TransactionInsertDelete()
  var R = Rel.new('R', {A: Int, B: Int}, 'A')

  R.Insert({A: 1, B: 10})

  Transaction(() => {
    R.Insert({A: 1, B: 11})  # Temporarily violates key constraint
    R.Delete((t) => t.B == 11)
  })

  assert_equal([{A: 1, B: 10}], R.Instance())

  Transaction(() => {
    R.Insert({A: 1, B: 10})
    R.Insert({A: 1, B: 11})
    R.Delete((t) => t.B == 10)
  })

  assert_equal([{A: 1, B: 11}], R.Instance())

  AssertFails(() => {
    Transaction(() => {
      R.Insert({A: 1, B: 12})
      R.Insert({A: 1, B: 13})
      R.Delete((t) => t.B == 13)
    })
  }, 'Duplicate key')

  assert_equal([{A: 1, B: 11}], R.Instance())

  Transaction(() => {
    R.Insert({A: 1, B: 12})
    R.Delete((t) => t.A == 1)
  })

  assert_equal([], R.Instance())
enddef


tt.Run('_RA_')
