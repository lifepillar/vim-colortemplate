vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

import 'libparser.vim' as parser
import 'libtinytest.vim' as tt

const Context      = parser.Context
const Eof          = parser.Eof
const Eol          = parser.Eol
const Eps          = parser.Eps
const FAIL         = parser.FAIL
const Lab          = parser.Lab
const Lexeme       = parser.Lexeme
const Many         = parser.Many
const Map          = parser.Map
const OneOf        = parser.OneOf
const Opt          = parser.Opt
const LookAhead    = parser.LookAhead
const NegLookAhead = parser.NegLookAhead
const Regex        = parser.Regex
const Seq          = parser.Seq
const Skip         = parser.Skip
const Text         = parser.Text
const R            = parser.R
const Space        = parser.Space
const T            = parser.T
const Token        = parser.Token
const Integer      = Regex('\d\+')->Map((x) => str2nr(x))

def Test_LP_ParseNewline()
  var ctx = Context("012\n456", 3)
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\n", result.value)
  assert_equal(4, ctx.index)
enddef

def Test_LP_ParseReturn()
  var ctx = Context("012\r456", 3)
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\r", result.value)
  assert_equal(4, ctx.index)
enddef

def g:Test_LP_NotEol()
  var ctx = Context("012\n456", 2)
  const result = Eol(ctx)
  assert_false(result.success)
  assert_false(result.label is FAIL)
  assert_equal(2, ctx.index)
enddef

def g:Test_LP_ParseEolAtEof()
  var ctx = Context("012", 3)
  const result = Eol(ctx)
  assert_false(result.success)
  assert_false(result.label is FAIL)
  assert_equal(3, ctx.index)
enddef

def Test_LP_EmptyEof()
  const ctx = Context("", 0)
  const result = Eof(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseEof()
  var ctx = Context("012", 3)
  const result = Eof(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_NotEof()
  var ctx = Context("012", 2)
  const result = Eof(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseEmptyText001()
  var ctx = Context("abc", 0)
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseEmptyText002()
  var ctx = Context("abc", 1)
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseEps001()
  var ctx = Context("", 1)
  const result = Eps(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseEps002()
  var ctx = Context("abc", 1)
  const result = Eps(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseText001()
  var ctx = Context("hello world", 0)
  const result = Text("hello")(ctx)
  assert_true(result.success)
  assert_equal("hello", result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseText002()
  const text = "hello world"
  var ctx = Context(text, 6)
  const result = Text("world")(ctx)
  assert_true(result.success)
  assert_equal("world", result.value)
  assert_equal(len(text), ctx.index)
enddef

def Test_LP_ParseText003()
  const text = "hello world"
  var ctx = Context(text, 6)
  const result = Text("hello")(ctx)
  assert_false(result.success)
  assert_equal(6, ctx.index)
enddef

def Test_LP_ParseRegex001()
  const text = "x012abc"
  var ctx = Context(text, 1)
  const result = Regex('\d\+')(ctx)
  assert_true(result.success)
  assert_equal("012", result.value)
  assert_equal(4, ctx.index)
enddef

def Test_LP_ParseRegex002()
  const text = "x012abc"
  var ctx = Context(text, 0)
  const result = Regex('\d\+')(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOneOf001()
  var ctx = Context("A: v")
  const result = OneOf(Text("A"), Text("B"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseOneOf002()
  var ctx = Context("A: v")
  const result = OneOf(Text("B"), Text("A"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseOneOf003()
  var ctx = Context("A:v")
  const Parse = OneOf(Text("B"), Text("C"))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOneOf004()
  var ctx = Context("A:v")
  const Parse = OneOf(Text("B"), Seq(Text("A"), Text("=")))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOptional001()
  var ctx = Context("AB: v")
  const result = Opt(Text('AB'))(ctx)
  assert_true(result.success)
  assert_equal("AB", result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseOptional002()
  var ctx = Context("AB: v")
  const result = Opt(Text('AC'))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOptional003()
  var ctx = Context("abcd")
  const Parse = Opt(Seq(Text('abc'), Text('x')))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseMany001()
  var ctx = Context("xyxyxyz")
  const result = Many(Text("xy"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "xy", "xy"], result.value)
  assert_equal(6, ctx.index)
enddef

def Test_LP_ParseMany002()
  var ctx = Context("xyxyxyz")
  const result = Many(Text("xz"))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseManyInfiniteLoop()
  var ctx = Context("xyxyxyz")
  const result = Many(Text(""))(ctx)
  assert_false(result.success)
  assert_equal("no infinite loop", result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseSequence001()
  var ctx = Context("xyabuv")
  const result = Seq(Text("xy"), Text("abu"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "abu"], result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseSequence002()
  var ctx = Context("xyabuv")
  const Parse = Seq(Text("xy"), Text("buv"))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseSequence003()
  var ctx = Context("X=:")
  const Parse = Seq(T('X'), Lab(T(':'), ':'))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal(':', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseAndSkip()
  var ctx = Context("a")
  const result = Skip(Text("a"))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_LookAhead001()
  var ctx = Context("A: v")
  const Parse = LookAhead(Regex('.*:'))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_LookAhead002()
  var ctx = Context("A.v")
  const Parse = Seq(LookAhead(Regex('.*\.')), Text('A.'))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(['A.'], result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_LookAhead003()
  var ctx = Context("A\nB:w")
  const Parse = OneOf(
    Seq(LookAhead(Regex('[^\n]*:')), Text('B')),
    Text('A')
  )
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseAndMap()
  var ctx = Context("xyabuuuuv")
  def F(L: list<string>): number
    return len(L[2]) + 38
  enddef
  const Parser = Seq(Text("x"), Text("yab"), Regex("u*"))
  const result = Map(Parser, F)(ctx)
  assert_true(result.success)
  assert_equal(42, result.value)
  assert_equal(8, ctx.index)
enddef

def Test_LP_ParseAndMapFails()
  var ctx = Context("xyabuuuuv")
  def F(L: list<string>): number
    return len(L[2]) + 38
  enddef
  const Parser = Seq(Text("x"), Text("yab"), Regex('v\+'))
  const result = Map(Parser, F)(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_LabelledParser()
  var ctx = Context('A: v')
  const Parse = OneOf(Seq(Text('A'), Lab(Text(';'), 'semicolon')), Eps)
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal('semicolon', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_Lexeme()
  var ctx = Context("; x")
  const Skipper = Lexeme(Regex('.*$'))
  const CommentParser = Skipper(Text(";"))
  const result = CommentParser(ctx)
  assert_true(result.success)
  assert_equal(";", result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_ParseSpace001()
  var ctx = Context(" \t\nx")
  const result = Space(ctx)
  assert_true(result.success)
  assert_equal(" \t\n", result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_ParseSpace002()
  var ctx = Context("a")
  const result = Space(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseToken()
  var ctx = Context("hello  \tworld  ")
  const result = Token(Text("hello"))(ctx)
  assert_true(result.success)
  assert_equal("hello", result.value)
  assert_equal(8, ctx.index)
  const result2 = Token(Text("world"))(ctx)
  assert_true(result2.success)
  assert_equal("world", result2.value)
  assert_equal(15, ctx.index)
enddef

def Test_LP_ParseInteger001()
  var ctx = Context('xyz42', 3)
  const result = Integer(ctx)
  assert_true(result.success)
  assert_equal(42, result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseInteger002()
  var ctx = Context('xyz42', 2)
  const result = Integer(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseExpectedColon001()
  var ctx = Context("Author=:")
  const S = Seq(OneOf(T('Author'), T('XYZ')), Skip(T(':')))
  const Parser = Many(OneOf(S, T("Tsk")))
  const result = Parser(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseExpectedColon002()
  var ctx = Context("Author=:")
  const Dir = OneOf(T('Foo'), Seq(T('Author'), Lab(T(':'), 'colon')))
  const Parser = Many(OneOf(Dir, T("Tsk")))
  const result = Parser(ctx)
  assert_false(result.success)
  assert_equal('colon', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseExpectedColon003()
  var ctx = Context("X:=")
  const Parser = OneOf(Text('Y'), Seq(Text('X'), Lab(Text(':'), 'colon')))
  const result = Parser(ctx)
  assert_true(result.success)
  assert_equal(['X', ':'], result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ManyWithOptionalInfiniteLoop()
  var ctx = Context("\n")
  const Parse = Many(Opt(Eol))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal('no infinite loop', result.label)
  assert_equal(0, ctx.index)
enddef

tt.Run('_LP_')
