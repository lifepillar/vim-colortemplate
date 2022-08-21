vim9script

import '../../import/libparser.vim' as parser

const Eof       = parser.Eof
const Label     = parser.Label
const Lexeme    = parser.Lexeme
const LookAhead = parser.LookAhead
const Many      = parser.Many
const Map       = parser.Map
const OneOf     = parser.OneOf
const Optional  = parser.Optional
const Regex     = parser.Regex
const Sequence  = parser.Sequence
const Skip      = parser.Skip
const Text      = parser.Text

const Eol       = Regex('[\r\n]', 'end of line')
const Space     = Regex('\s*', 'whitespace')
const Token     = Lexeme(Space)
const Integer   = Regex('\d\+', 'integer')->Map((x) => str2nr(x))

def TT(token: string): func(dict<any>): dict<any>
  return Token(Text(token))
enddef

def RT(pattern: string, expected: string): func(dict<any>): dict<any>
  return Token(Regex(pattern, expected))
enddef

# Test consuming a new line
def! g:Test_CT_ParseNewline()
  var ctx = { text: "012\n456", index: 3 }
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\n", result.value)
  assert_equal(4, ctx.index)
enddef

def! g:Test_CT_ParseReturn()
  var ctx = { text: "012\r456", index: 3 }
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\r", result.value)
  assert_equal(4, ctx.index)
enddef

def g:Test_CT_NotEol()
  var ctx = { text: "012\n456", index: 2 }
  const result = Eol(ctx)
  assert_false(result.success)
  assert_equal(2, ctx.index)
enddef

def g:Test_CT_ParseEolAtEof()
  var ctx = { text: "012", linenr: 1, linebegin: 0, index: 3 }
  const result = Eol(ctx)
  assert_false(result.success)
  assert_equal(3, ctx.index)
enddef

def! g:Test_CT_EmptyEof()
  const ctx = { text: "", index: 0 }
  const result = Eof(ctx)
  assert_true(result.success)
enddef

def! g:Test_CT_ParseEof()
  const ctx = { text: "012", index: 3 }
  const result = Eof(ctx)
  assert_true(result.success)
enddef

def! g:Test_CT_NotEof()
  const ctx = { text: "012", index: 2 }
  const result = Eof(ctx)
  assert_false(result.success)
enddef

def! g:Test_CT_ParseEmptyText001()
  var ctx = { text: "hello world", index: 0 }
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_ParseEmptyText002()
  var ctx = { text: "hello world", index: 1 }
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_ParseText001()
  var ctx = { text: "hello world", index: 0 }
  const result = Text("hello")(ctx)
  assert_true(result.success)
  assert_equal("hello", result.value)
  assert_equal(5, ctx.index)
enddef

def! g:Test_CT_ParseText002()
  const text = "hello world"
  var ctx = { text: text, index: 6 }
  const result = Text("world")(ctx)
  assert_true(result.success)
  assert_equal("world", result.value)
  assert_equal(len(text), ctx.index)
enddef

def! g:Test_CT_ParseText002()
  const text = "hello world"
  var ctx = { text: text, index: 6 }
  const result = Text("hello")(ctx)
  assert_false(result.success)
  assert_equal(6, ctx.index)
enddef

def! g:Test_CT_ParseRegex001()
  const text = "x012abc"
  var ctx = { text: text, index: 1 }
  const result = Regex('\d\+', "number")(ctx)
  assert_true(result.success)
  assert_equal("012", result.value)
  assert_equal(4, ctx.index)
enddef

def! g:Test_CT_ParseRegex002()
  const text = "x012abc"
  var ctx = { text: text, index: 0 }
  const result = Regex('\d\+', "number")(ctx)
  assert_false(result.success)
  assert_equal("number", result.expected)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_ParseOneOf001()
  var ctx = { text: "A: v", index: 0 }
  const result = OneOf(Text("A"), Text("B"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_ParseOneOf002()
  var ctx = { text: "A: v", index: 0 }
  const result = OneOf(Text("B"), Text("A"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_ParseOneOf003()
  var ctx = { text: "A:v", index: 0 }
  const result = Label(OneOf(Text("B"), Text("C")), "OneOf failed")(ctx)
  assert_false(result.success)
  assert_equal("OneOf failed", result.expected)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_ParseOneOf004()
  var ctx = { text: "A:v", index: 0 }
  const result = OneOf(Text("B"), Sequence(Text("A"), Text("=")))(ctx)
  assert_false(result.success)
  assert_equal("=", result.expected)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_ParseOptional001()
  var ctx = { text: "AB: v", index: 0 }
  const result = Optional(Text('AB'))(ctx)
  assert_true(result.success)
  assert_equal("AB", result.value)
  assert_equal(2, ctx.index)
enddef

def! g:Test_CT_ParseOptional001()
  var ctx = { text: "AB: v", index: 0 }
  const result = Optional(Text('AC'))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_ParseMany001()
  var ctx = { text: "xyxyxyz", index: 0 }
  const result = Many(Text("xy"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "xy", "xy"], result.value)
  assert_equal(6, ctx.index)
enddef

def! g:Test_CT_ParseMany002()
  var ctx = { text: "xyxyxyz", index: 0 }
  const result = Many(Text("xz"))(ctx)
  assert_true(result.success)
  assert_equal([], result.value)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_ParseManyInfiniteLoop()
  var ctx = { text: "xyxyxyz", index: 0 }
  const result = Many(Text(""))(ctx)
  assert_false(result.success)
  assert_equal("no infinite loop", result.expected)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_ParseSequence001()
  var ctx = { text: "xyabuv", index: 0 }
  const result = Sequence(Text("xy"), Text("abu"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "abu"], result.value)
  assert_equal(5, ctx.index)
enddef

def! g:Test_CT_ParseSequence002()
  var ctx = { text: "xyabuv", index: 0 }
  const result = Sequence(Text("xy"), Text("buv"))(ctx)
  assert_false(result.success)
  assert_equal("buv", result.expected)
  assert_equal(2, ctx.index)
enddef

def! g:Test_CT_ParseSequence003()
  var ctx = { text: "X=:", index: 0 }
  const Parser = Sequence(TT('X'), TT(':'))
  const result = Parser(ctx)
  assert_false(result.success)
  assert_equal(":", result.expected)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_ParseAndSkip()
  var ctx = { text: "a", index: 0 }
  const result = Skip(Text("a"))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_LookAhead001()
  var ctx = { text: "A: v", index: 0 }
  const result = LookAhead(Regex('.*:', 'colon'), Text("A"), Text("B"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_LookAhead002()
  var ctx = { text: "A.v", index: 0 }
  const result = LookAhead(Regex('.*\.', 'dot'), Text("B"), Text("A"))(ctx)
  assert_false(result.success)
  assert_equal("B", result.expected)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_LookAhead003()
  var ctx = { text: "A\nB:w", index: 0 }
  const result = LookAhead(Regex('[^\n]*:', 'colon'), Text("B"), Text("A"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_ParseAndMap()
  var ctx = { text: "xyabuuuuv", index: 0 }
  def F(L: list<string>): number
    return len(L[2]) + 38
  enddef
  const Parser = Sequence(Text("x"), Text("yab"), Regex("u*", "some u's"))
  const result = Map(Parser, F)(ctx)
  assert_true(result.success)
  assert_equal(42, result.value)
  assert_equal(8, ctx.index)
enddef

def! g:Test_CT_ParseAndMapFails()
  var ctx = { text: "xyabuuuuv", index: 0 }
  def F(L: list<string>): number
    return len(L[2]) + 38
  enddef
  const Parser = Sequence(Text("x"), Text("yab"), Regex('v\+', "some v's"))
  const result = Map(Parser, F)(ctx)
  assert_false(result.success)
  assert_equal("some v's", result.expected)
  assert_equal(4, ctx.index)
enddef

def! g:Test_CT_LabelledParser()
  var ctx = { text: "A: v", index: 0 }
  const Parser = OneOf(Text('B'), Text('CD'))
  const result = Label(Parser, "one of B or CD")(ctx)
  assert_false(result.success)
  assert_equal("one of B or CD", result.expected)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_Lexeme()
  var ctx = { text: "; x", index: 0 }
  const Skipper = Lexeme(Regex('.*$', "rest of line"))
  const CommentParser = Skipper(Text(";"))
  const result = CommentParser(ctx)
  assert_true(result.success)
  assert_equal(";", result.value)
  assert_equal(3, ctx.index)
enddef

def! g:Test_CT_ParseSpace001()
  var ctx = { text: " \t\nx", index: 0 }
  const result = Space(ctx)
  assert_true(result.success)
  assert_equal(" \t", result.value)
  assert_equal(2, ctx.index)
enddef

def! g:Test_CT_ParseSpace002()
  var ctx = { text: "a", index: 0 }
  const result = Space(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def! g:Test_CT_ParseToken()
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

def! g:Test_CT_ParseInteger001()
  var ctx = { text: 'xyz42', index: 3 }
  const result = Integer(ctx)
  assert_true(result.success)
  assert_equal(42, result.value)
  assert_equal(5, ctx.index)
enddef

def! g:Test_CT_ParseInteger002()
  var ctx = { text: 'xyz42', index: 2 }
  const result = Integer(ctx)
  assert_false(result.success)
  assert_equal('integer', result.expected)
  assert_equal(2, ctx.index)
enddef

def! g:Test_CT_ParseExpectedColon001()
  var ctx = { text: "Author=:", index: 0 }
  const Seq = Sequence(OneOf(TT('Author'), TT('XYZ')), Skip(TT(":")))
  const Parser = Many(OneOf(Seq, TT("Tsk")))
  const result = Parser(ctx)
  assert_false(result.success)
  assert_equal(":", result.expected)
  assert_equal(6, ctx.index)
enddef

def! g:Test_CT_ParseExpectedColon002()
  var ctx = { text: "Author=:", index: 0 }
  const Dir = OneOf(TT('Foo'), Sequence(TT('Author'), TT(':')))
  const Parser = Many(OneOf(Dir, TT("Tsk")))
  const result = Parser(ctx)
  assert_false(result.success)
  assert_equal(":", result.expected)
  assert_equal(6, ctx.index)
enddef

def! g:Test_CT_ParseExpectedColon003()
  var ctx = { text: "X=:", index: 0 }
  const Parser = OneOf(Text('Y'), Sequence(Text('X'), Text(':')))
  const result = Parser(ctx)
  assert_false(result.success)
  assert_equal(":", result.expected)
  assert_equal(1, ctx.index)
enddef

def! g:Test_CT_ManyWithOptionalInfiniteLoop()
  var ctx = { text: "\n", index: 0 }
  const result = Many(Optional(Eol))(ctx)
  assert_true(!result.success)
  assert_equal('no infinite loop', result.expected)
  assert_equal(1, ctx.index)
enddef

