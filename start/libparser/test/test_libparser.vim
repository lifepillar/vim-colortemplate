vim9script

import 'libparser.vim' as parser
import 'libtinytest.vim' as tt

const Eof       = parser.Eof
const Eps       = parser.Eps
const Err       = parser.Err
const fail      = parser.fail
const Lexeme    = parser.Lexeme
const Many      = parser.Many
const Map       = parser.Map
const OneOf     = parser.OneOf
const Optional  = parser.Optional
const PositiveLookAhead = parser.PositiveLookAhead
const NegativeLookAhead = parser.NegativeLookAhead
const Regex     = parser.Regex
const Seq  = parser.Seq
const Skip      = parser.Skip
const Text      = parser.Text

const Eol       = Regex('[\r\n]')
const Space     = Regex('\s*')
const Token     = Lexeme(Space)
const Integer   = Regex('\d\+')->Map((x) => str2nr(x))

def TT(token: string): func(dict<any>): dict<any>
  return Token(Text(token))
enddef

def RT(pattern: string): func(dict<any>): dict<any>
  return Token(Regex(pattern))
enddef

# Test consuming a new line
def Test_LP_ParseNewline()
  var ctx = { text: "012\n456", index: 3 }
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\n", result.value)
  assert_equal(4, ctx.index)
enddef

def Test_LP_ParseReturn()
  var ctx = { text: "012\r456", index: 3 }
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\r", result.value)
  assert_equal(4, ctx.index)
enddef

def g:Test_LP_NotEol()
  var ctx = { text: "012\n456", index: 2 }
  const result = Eol(ctx)
  assert_false(result.success)
  assert_equal(2, ctx.index)
enddef

def g:Test_LP_ParseEolAtEof()
  var ctx = { text: "012", linenr: 1, linebegin: 0, index: 3 }
  const result = Eol(ctx)
  assert_false(result.success)
  assert_equal(3, ctx.index)
enddef

def Test_LP_EmptyEof()
  const ctx = { text: "", index: 0 }
  const result = Eof(ctx)
  assert_true(result.success)
enddef

def Test_LP_ParseEof()
  const ctx = { text: "012", index: 3 }
  const result = Eof(ctx)
  assert_true(result.success)
enddef

def Test_LP_NotEof()
  const ctx = { text: "012", index: 2 }
  const result = Eof(ctx)
  assert_false(result.success)
enddef

def Test_LP_ParseEmptyText001()
  var ctx = { text: "hello world", index: 0 }
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseEmptyText002()
  var ctx = { text: "hello world", index: 1 }
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseText001()
  var ctx = { text: "hello world", index: 0 }
  const result = Text("hello")(ctx)
  assert_true(result.success)
  assert_equal("hello", result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseText002()
  const text = "hello world"
  var ctx = { text: text, index: 6 }
  const result = Text("world")(ctx)
  assert_true(result.success)
  assert_equal("world", result.value)
  assert_equal(len(text), ctx.index)
enddef

def Test_LP_ParseText003()
  const text = "hello world"
  var ctx = { text: text, index: 6 }
  const result = Text("hello")(ctx)
  assert_false(result.success)
  assert_equal(6, ctx.index)
enddef

def Test_LP_ParseRegex001()
  const text = "x012abc"
  var ctx = { text: text, index: 1 }
  const result = Regex('\d\+')(ctx)
  assert_true(result.success)
  assert_equal("012", result.value)
  assert_equal(4, ctx.index)
enddef

def Test_LP_ParseRegex002()
  const text = "x012abc"
  var ctx = { text: text, index: 0 }
  const result = Regex('\d\+')(ctx)
  assert_false(result.success)
  assert_equal(fail, result.label)
  assert_true(result.label is fail)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOneOf001()
  var ctx = { text: "A: v", index: 0 }
  const result = OneOf(Text("A"), Text("B"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseOneOf002()
  var ctx = { text: "A: v", index: 0 }
  const result = OneOf(Text("B"), Text("A"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseOneOf003()
  var ctx = { text: "A:v", index: 0 }
  const Parse = OneOf(Text("B"), Text("C"))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is fail)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOneOf004()
  var ctx = { text: "A:v", index: 0 }
  const Parse = OneOf(Text("B"), Seq(Text("A"), Text("=")))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is fail)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOptional001()
  var ctx = { text: "AB: v", index: 0 }
  const result = Optional(Text('AB'))(ctx)
  assert_true(result.success)
  assert_equal("AB", result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseOptional002()
  var ctx = { text: "AB: v", index: 0 }
  const result = Optional(Text('AC'))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOptional003()
  var ctx = { text: "abcd", index: 0 }
  const Parse = Optional(Seq(Text('abc'), Text('x')))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseMany001()
  var ctx = { text: "xyxyxyz", index: 0 }
  const result = Many(Text("xy"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "xy", "xy"], result.value)
  assert_equal(6, ctx.index)
enddef

def Test_LP_ParseMany002()
  var ctx = { text: "xyxyxyz", index: 0 }
  const result = Many(Text("xz"))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseManyInfiniteLoop()
  var ctx = { text: "xyxyxyz", index: 0 }
  const result = Many(Text(""))(ctx)
  assert_false(result.success)
  assert_equal("no infinite loop", result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseSequence001()
  var ctx = { text: "xyabuv", index: 0 }
  const result = Seq(Text("xy"), Text("abu"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "abu"], result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseSequence002()
  var ctx = { text: "xyabuv", index: 0 }
  const Parse = Seq(Text("xy"), Text("buv"))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is fail)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseSequence003()
  var ctx = { text: "X=:", index: 0 }
  const Parse = Seq(TT('X'), Err(TT(':'), ':'))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal(':', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseAndSkip()
  var ctx = { text: "a", index: 0 }
  const result = Skip(Text("a"))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_LookAhead001()
  var ctx = { text: "A: v", index: 0 }
  const Parse = PositiveLookAhead(Regex('.*:'))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_LookAhead002()
  var ctx = { text: "A.v", index: 0 }
  const Parse = Seq(PositiveLookAhead(Regex('.*\.')), Text('A.'))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(['A.'], result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_LookAhead003()
  var ctx = { text: "A\nB:w", index: 0 }
  const Parse = OneOf(
    Seq(PositiveLookAhead(Regex('[^\n]*:')), Text('B')),
    Text('A')
  )
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseAndMap()
  var ctx = { text: "xyabuuuuv", index: 0 }
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
  var ctx = { text: "xyabuuuuv", index: 0 }
  def F(L: list<string>): number
    return len(L[2]) + 38
  enddef
  const Parser = Seq(Text("x"), Text("yab"), Regex('v\+'))
  const result = Map(Parser, F)(ctx)
  assert_false(result.success)
  assert_true(result.label is fail)
  assert_equal(0, ctx.index)
enddef

def Test_LP_LabelledParser()
  var ctx = { text: 'A: v', index: 0 }
  const Parse = OneOf(Seq(Text('A'), Err(Text(';'), 'semicolon')), Eps)
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal('semicolon', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_Lexeme()
  var ctx = { text: "; x", index: 0 }
  const Skipper = Lexeme(Regex('.*$'))
  const CommentParser = Skipper(Text(";"))
  const result = CommentParser(ctx)
  assert_true(result.success)
  assert_equal(";", result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_ParseSpace001()
  var ctx = { text: " \t\nx", index: 0 }
  const result = Space(ctx)
  assert_true(result.success)
  assert_equal(" \t", result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseSpace002()
  var ctx = { text: "a", index: 0 }
  const result = Space(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseToken()
  var ctx = { text: "hello  \tworld  ", index: 0 }
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
  var ctx = { text: 'xyz42', index: 3 }
  const result = Integer(ctx)
  assert_true(result.success)
  assert_equal(42, result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseInteger002()
  var ctx = { text: 'xyz42', index: 2 }
  const result = Integer(ctx)
  assert_false(result.success)
  assert_true(result.label is fail)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseExpectedColon001()
  var ctx = { text: "Author=:", index: 0 }
  const S = Seq(OneOf(TT('Author'), TT('XYZ')), Skip(TT(':')))
  const Parser = Many(OneOf(S, TT("Tsk")))
  const result = Parser(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseExpectedColon002()
  var ctx = { text: "Author=:", index: 0 }
  const Dir = OneOf(TT('Foo'), Seq(TT('Author'), Err(TT(':'), 'colon')))
  const Parser = Many(OneOf(Dir, TT("Tsk")))
  const result = Parser(ctx)
  assert_false(result.success)
  assert_equal('colon', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseExpectedColon003()
  var ctx = { text: "X:=", index: 0 }
  const Parser = OneOf(Text('Y'), Seq(Text('X'), Err(Text(':'), 'colon')))
  const result = Parser(ctx)
  assert_true(result.success)
  assert_equal(['X', ':'], result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ManyWithOptionalInfiniteLoop()
  var ctx = { text: "\n", index: 0 }
  const Parse = Many(Optional(Eol))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal('no infinite loop', result.label)
  assert_equal(0, ctx.index)
enddef

tt.Run('_LP_')
