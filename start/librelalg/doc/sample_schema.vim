vim9script

import 'librelalg.vim' as ra

type  Rel        = ra.Rel
const Bool       = ra.Bool
const Int        = ra.Int
const Query      = ra.Query
const Sort       = ra.Sort
const Str        = ra.Str
const ForeignKey = ra.ForeignKey
const References = ra.References
const Table      = ra.Table

var Buffer = Rel.new('Buffer', {
  BufId:   Int,
  BufName: Str,
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

Tag.OnInsertCheck('Line must be positive', (t) => t.Line > 0)
Tag.OnInsertCheck('Column must be positive', (t) => t.Column > 0)

ForeignKey(Tag, 'BufId')
  ->References(Buffer, {key: 'BufId', verb: 'must appear in a valid'})

Buffer.InsertMany([
  {BufId: 1, BufName: 'foo'},
  {BufId: 2, BufName: 'bar'},
  {BufId: 3, BufName: 'xyz'},
])

Tag.InsertMany([
  {BufId: 1, TagName: 'kkk', Line: 1,  Column: 5},
  {BufId: 1, TagName: 'zzz', Line: 2,  Column: 1},
  {BufId: 1, TagName: 'abc', Line: 3,  Column: 9},
  {BufId: 1, TagName: 'xyz', Line: 4,  Column: 1},
  {BufId: 1, TagName: 'lll', Line: 4,  Column: 8},
  {BufId: 2, TagName: 'abc', Line: 14, Column: 15},
  {BufId: 3, TagName: 'abc', Line: 6,  Column: 3},
])
Tag.Upsert({BufId: 1, TagName: 'abc', Line: 7, Column: 12})
Tag.Delete((t) => t.Line < 2)

echo ra.Table(Buffer)
echo ra.Table(Tag)
