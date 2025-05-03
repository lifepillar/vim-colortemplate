vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

import 'libparser.vim' as parser
import 'libtinytest.vim' as tt

type Context = parser.Context
type Result  = parser.Result

const Apply        = parser.Apply
const Blank        = parser.Blank
const Bol          = parser.Bol
const Call         = parser.Call
const Eof          = parser.Eof
const Eol          = parser.Eol
const Eps          = parser.Eps
const FAIL         = parser.FAIL
const Lab          = parser.Lab
const Lexeme       = parser.Lexeme
const LookAhead    = parser.LookAhead
const Many         = parser.Many
const Map          = parser.Map
const NegLookAhead = parser.NegLookAhead
const OneOf        = parser.OneOf
const OneOrMore    = parser.OneOrMore
const Opt          = parser.Opt
const Regex        = parser.Regex
const RegexToken   = parser.RegexToken
const Seq          = parser.Seq
const Skip         = parser.Skip
const Space        = parser.Space
const Text         = parser.Text
const TextToken    = parser.TextToken
const Integer      = Regex('\d\+')->Map((x, _) => str2nr(x))

def Test_LP_Version()
  assert_true(match(parser.version, '^\d\+\.\d\+\.\d\+') != -1)
enddef


def Test_LP_Context()
  var ctx = Context.new("Some text")
  assert_equal(v:t_object, type(ctx))
  assert_equal("Some text", ctx.text)
  assert_equal(0, ctx.index)
  assert_equal(-1, ctx.farthest)

  ctx.index = 3
  ctx.farthest = 5

  assert_equal(3, ctx.index)
  assert_equal(5, ctx.farthest)

  ctx.Reset()

  assert_equal(0, ctx.index)
  assert_equal(-1, ctx.farthest)
  assert_equal("Some text", ctx.text)
enddef

def Test_LP_Result()
  var res = Result.newSuccess()

  assert_true(res.success)
  assert_equal(null, res.value)

  res = Result.newSuccess('ab')

  assert_true(res.success)
  assert_equal('ab', res.value)

  res = Result.newFailure(2)

  assert_false(res.success)
  assert_equal(2, res.errpos)
  assert_equal(null, res.value)
  assert_true(res.label is FAIL)

  res = Result.newFailure(3, 'something')

  assert_false(res.success)
  assert_equal(3, res.errpos)
  assert_equal(null, res.value)
  assert_equal('something', res.label)
enddef

def Test_LP_ParseNewline()
  var ctx = Context.new("012\n456", 3)
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\n", result.value)
  assert_equal(4, ctx.index)
enddef

def Test_LP_ParseReturn()
  var ctx = Context.new("012\r456", 3)
  const result = Eol(ctx)
  assert_true(result.success)
  assert_equal("\r", result.value)
  assert_equal(4, ctx.index)
enddef

def g:Test_LP_NotEol()
  var ctx = Context.new("012\n456", 2)
  const result = Eol(ctx)
  assert_false(result.success)
  assert_false(result.label is FAIL)
  assert_equal(2, ctx.index)
enddef

def g:Test_LP_ParseEolAtEof()
  var ctx = Context.new("012", 3)
  const result = Eol(ctx)
  assert_false(result.success)
  assert_false(result.label is FAIL)
  assert_equal(3, ctx.index)
enddef

def Test_LP_EmptyEof()
  const ctx = Context.new("", 0)
  const result = Eof(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseEof()
  var ctx = Context.new("012", 3)
  const result = Eof(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_NotEof()
  var ctx = Context.new("012", 2)
  const result = Eof(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(2, ctx.index)
enddef

def Test_LP_Bol()
  var ctx = Context.new("ab")
  var result = Bol(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)

  ctx.index = 1
  result = Bol(ctx)

  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(1, ctx.index)

  ctx = Context.new("ab\ncd", 3)
  result = Bol(ctx)

  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(3, ctx.index)

  for i in [1, 2, 4, 5]
    ctx.index = i
    result = Bol(ctx)
    assert_false(result.success)
  endfor

  const T = TextToken(Blank)
  const Parse = Seq(T('à'), Seq(Bol, T('b')))

  ctx = Context.new("à\rb")
  result = Parse(ctx)

  assert_true(result.success)
  assert_equal(-1, result.errpos)
  assert_equal(['à', ['b']], result.value)
enddef

def Test_LP_ParseEmptyText001()
  var ctx = Context.new("abc", 0)
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseEmptyText002()
  var ctx = Context.new("abc", 1)
  const result = Text("")(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseEps001()
  var ctx = Context.new("", 1)
  const result = Eps(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseEps002()
  var ctx = Context.new("abc", 1)
  const result = Eps(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseText001()
  var ctx = Context.new("hello world", 0)
  const result = Text("hello")(ctx)
  assert_true(result.success)
  assert_equal("hello", result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseText002()
  const text = "hello world"
  var ctx = Context.new(text, 6)
  const result = Text("world")(ctx)
  assert_true(result.success)
  assert_equal("world", result.value)
  assert_equal(len(text), ctx.index)
enddef

def Test_LP_ParseText003()
  const text = "hello world"
  var ctx = Context.new(text, 6)
  const result = Text("hello")(ctx)
  assert_false(result.success)
  assert_equal(6, ctx.index)
enddef

def Test_LP_ParseRegex001()
  const text = "x012abc"
  var ctx = Context.new(text, 1)
  const result = Regex('\d\+')(ctx)
  assert_true(result.success)
  assert_equal("012", result.value)
  assert_equal(4, ctx.index)
enddef

def Test_LP_ParseRegex002()
  const text = "x012abc"
  var ctx = Context.new(text, 0)
  const result = Regex('\d\+')(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseDefaultRegexToken()
  var ctx = Context.new("x012 \n abc", 1)
  const R = RegexToken()
  const result = R('\d\+')(ctx)
  assert_true(result.success)
  assert_equal("012", result.value)
  assert_equal(7, ctx.index)
enddef

def Test_LP_ParseCustomRegexToken()
  var ctx = Context.new("x012 #x\n abc", 1)
  const Comment = Regex('#[^\n]*')
  const SpaceOrComment = Many(OneOf(Space, Comment))
  const R = RegexToken(SpaceOrComment)
  const result = R('\d\+')(ctx)
  assert_true(result.success)
  assert_equal("012", result.value)
  assert_equal(9, ctx.index)
enddef

def Test_LP_Call()
  var n = 0
  const F = () => {
    ++n
  }
  var ctx = Context.new('ab')
  const result = Call(F)(ctx)
  assert_equal(1, n)
enddef

def Test_LP_ParseOneOf001()
  var ctx = Context.new("A: v")
  const result = OneOf(Text("A"), Text("B"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseOneOf002()
  var ctx = Context.new("A: v")
  const result = OneOf(Text("B"), Text("A"))(ctx)
  assert_true(result.success)
  assert_equal("A", result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_ParseOneOf003()
  var ctx = Context.new("A:v")
  const Parse = OneOf(Text("B"), Text("C"))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOneOf004()
  var ctx = Context.new("A:v")
  const Parse = OneOf(Text("B"), Seq(Text("A"), Text("=")))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOneOrMore000()
  var ctx = Context.new("+z")
  const result = OneOrMore(Text('+x'))(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOneOrMore001()
  var ctx = Context.new("+x+z")
  const result = OneOrMore(Text('+x'))(ctx)
  assert_true(result.success)
  assert_equal(['+x'], result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseOneOrMore002()
  var ctx = Context.new("+x+x+z")
  const result = OneOrMore(Text('+x'))(ctx)
  assert_true(result.success)
  assert_equal(['+x', '+x'], result.value)
  assert_equal(4, ctx.index)
enddef

def Test_LP_ParseOneOrMore003()
  var ctx = Context.new("+x+x+x+z")
  const result = OneOrMore(Text('+x'))(ctx)
  assert_true(result.success)
  assert_equal(['+x', '+x', '+x'], result.value)
  assert_equal(6, ctx.index)
enddef

def Test_LP_OptionalTextSuccess()
  var ctx = Context.new("AB: v")
  const result = Opt(Text('AB'))(ctx)
  assert_true(result.success)
  assert_equal("AB", result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_OptEps()
  var ctx = Context.new("xy")
  const result = Opt(Eps)(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_OptionalTextFail()
  var ctx = Context.new("AB: v")
  const result = Opt(Text('AC'))(ctx)
  assert_true(result.success)
  assert_equal('', result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseOptionalSequence()
  var ctx = Context.new("abcd")
  const Parse = Opt(Seq(Text('abc'), Text('x')))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal('', result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseMany001()
  var ctx = Context.new("xyxyxyz")
  const result = Many(Text("xy"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "xy", "xy"], result.value)
  assert_equal(6, ctx.index)
enddef

def Test_LP_ParseMany002()
  var ctx = Context.new("xyxyxyz")
  const result = Many(Text("xz"))(ctx)
  assert_true(result.success)
  assert_equal([], result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseMany003()
  var ctx = Context.new("xyxyxyz")
  var result = Many(Eps)(ctx)
  assert_true(result.success)
  assert_equal([''], result.value)
  assert_equal(0, ctx.index)
  result = Many(Text(""))(ctx)
  assert_true(result.success)
  assert_equal([''], result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseSeqOpt()
  var ctx = Context.new("xyabuv")
  const Parse = Seq(Opt(Text('z')))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal([''], result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseSequence001()
  var ctx = Context.new("xyabuv")
  const result = Seq(Text("xy"), Text("abu"))(ctx)
  assert_true(result.success)
  assert_equal(["xy", "abu"], result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseSequence002()
  var ctx = Context.new("xyabuv")
  const Parse = Seq(Text("xy"), Text("buv"))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseSequence003()
  var ctx = Context.new("X=:")
  const Parse = Seq(Text('X'), Lab(Text(':'), ':'))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal(':', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseAndSkip()
  var ctx = Context.new("a")
  const result = Skip(Text("a"))(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(1, ctx.index)
enddef

def Test_LP_LookAhead001()
  var ctx = Context.new("A: v")
  const Parse = LookAhead(Regex('.*:'))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_LookAhead002()
  var ctx = Context.new("A.v")
  const Parse = Seq(LookAhead(Regex('.*\.')), Text('A.'))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(['A.'], result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_LookAhead003()
  var ctx = Context.new("A\nB:w")
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
  var ctx = Context.new("xyabuuuuv")
  def F(L: list<string>, _: Context): number
    return len(L[2]) + 38
  enddef
  const Parse = Seq(Text("x"), Text("yab"), Regex("u*"))
  const result = Map(Parse, F)(ctx)
  assert_true(result.success)
  assert_equal(42, result.value)
  assert_equal(8, ctx.index)
enddef

def Test_LP_ParseAndMapFails()
  var ctx = Context.new("xyabuuuuv")
  def F(L: list<string>, _: Context): number
    return len(L[2]) + 38
  enddef
  const Parse = Seq(Text("x"), Text("yab"), Regex('v\+'))
  const result = Map(Parse, F)(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(0, ctx.index)
enddef

def Test_LP_MapThrows()
  var ctx = Context.new("12")

  const Parse = Text("12")->Map((v, _): string => {
    throw 'Tsk'
  })
  const result = Parse(ctx)

  assert_false(result.success)
  assert_equal('Tsk', result.label)
  assert_equal(2, ctx.index)
enddef

def Test_LP_LabelledParser()
  var ctx = Context.new('A: v')
  const Parse = OneOf(Seq(Text('A'), Lab(Text(';'), 'semicolon')), Eps)
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal('semicolon', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_Lexeme()
  var ctx = Context.new("; x")
  const Skipper = Lexeme(Regex('.*$'))
  const CommentParser = Skipper(Text(";"))
  const result = CommentParser(ctx)
  assert_true(result.success)
  assert_equal(";", result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_ParseSpace()
  var ctx = Context.new(" \t\nx")
  const result = Space(ctx)
  assert_true(result.success)
  assert_equal(" \t\n", result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_ParseBlank()
  var ctx = Context.new(" \t\nx")
  var result = Blank(ctx)
  assert_true(result.success)
  assert_equal(" \t\n", result.value)
  assert_equal(3, ctx.index)
  result = Blank(ctx)
  assert_true(result.success)
  assert_equal("", result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_ParseDefaultTextToken()
  var ctx = Context.new("hello  \tworld  ")
  const T = TextToken()
  const result = T("hello")(ctx)
  assert_true(result.success)
  assert_equal("hello", result.value)
  assert_equal(8, ctx.index)
  const result2 = T("world")(ctx)
  assert_true(result2.success)
  assert_equal("world", result2.value)
  assert_equal(15, ctx.index)
enddef

def Test_LP_ParseCustomTextToken()
  var ctx = Context.new("abc  # x\n\n y")
  const Comment = Regex('#[^\n]*')
  const SpaceOrComment = Many(OneOf(Space, Comment))
  const T = TextToken(SpaceOrComment)
  const result = T('abc')(ctx)
  assert_true(result.success)
  assert_equal('abc', result.value)
  assert_equal(11, ctx.index)
enddef

def Test_LP_ParseInteger001()
  var ctx = Context.new('xyz42', 3)
  const result = Integer(ctx)
  assert_true(result.success)
  assert_equal(42, result.value)
  assert_equal(5, ctx.index)
enddef

def Test_LP_ParseInteger002()
  var ctx = Context.new('xyz42', 2)
  const result = Integer(ctx)
  assert_false(result.success)
  assert_true(result.label is FAIL)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ParseExpectedColon001()
  var ctx = Context.new("Author=:")
  const S = Seq(OneOf(Text('Author'), Text('XYZ')), Skip(Text(':')))
  const Parse = Many(OneOf(S, Text("Tsk")))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal([], result.value)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseExpectedColon002()
  var ctx = Context.new("Author=:")
  const Dir = OneOf(Text('Foo'), Seq(Text('Author'), Lab(Text(':'), 'colon')))
  const Parse = Many(OneOf(Dir, Text("Tsk")))
  const result = Parse(ctx)
  assert_false(result.success)
  assert_equal('colon', result.label)
  assert_equal(0, ctx.index)
enddef

def Test_LP_ParseExpectedColon003()
  var ctx = Context.new("X:=")
  const Parse = OneOf(Text('Y'), Seq(Text('X'), Lab(Text(':'), 'colon')))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(['X', ':'], result.value)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ManyWithOptional()
  var ctx = Context.new("\n\n\n")
  const Parse = Many(Opt(Eol))
  const result = Parse(ctx)
  assert_true(result.success)
  assert_equal(["\n", "\n", "\n", ""], result.value)
  assert_equal(3, ctx.index)
enddef

def Test_LP_CustomTokenizer()
  const Spaces         = Regex('\%(\s\|\n\|\r\)\+')
  const Comment        = Regex('#[^\n]*')
  const SpaceOrComment = Many(OneOf(Spaces, Comment))
  const MyToken        = Lexeme(SpaceOrComment)
  var   ctx            = Context.new("abc # XY\n ok")
  var   Parse          = MyToken(Text("abc"))
  var   result         = Parse(ctx)
  assert_true(result.success)
  assert_equal('abc', result.value)
  assert_equal(10, ctx.index)

  ctx    = Context.new("abc#XY")
  Parse  = MyToken(Text("abc"))
  result = Parse(ctx)
  assert_true(result.success)
  assert_equal('abc', result.value)
  assert_equal(6, ctx.index)
enddef

def Test_LP_Apply()
  var ctx = Context.new("12")
  ctx.state.expected = 0

  const Parse = Text("12")->Apply((v, c: Context) => {
    c.state.expected = 12
  })

  const result = Parse(ctx)

  assert_true(result.success)
  assert_equal(null, result.value)
  assert_equal(12, ctx.state.expected)
  assert_equal(2, ctx.index)
enddef

def Test_LP_ApplyThrows()
  var ctx = Context.new("12")

  const Parse = Text("12")->Apply((v, _) => {
    throw 'Tsk'
  })
  const result = Parse(ctx)

  assert_false(result.success)
  assert_equal('Tsk', result.label)
  assert_equal(2, ctx.index)
enddef

def Test_LP_UnicodeText()
  const expected = 'abc ▇'
  const text     = expected .. "\n  endverb"
  var   ctx      = Context.new(text)

  const Parse = Text(expected)
  const result = Parse(ctx)

  assert_true(result.success)
  assert_equal(expected, result.value)
  assert_equal(strlen(expected), ctx.index)
enddef

def Test_LP_UnicodeText2()
  const text = "abc ▇\n  endverb"
  var   ctx  = Context.new(text)

  const SpaceOrComment = Regex('\%([ \n\t\r]*\%(;[^\n\r]*\)\=\)*')
  const R              = RegexToken(SpaceOrComment)
  const VERBTEXT       = R('\_.\{-}\zeendverb')
  const Parse          = Seq(VERBTEXT, Text('endverb'))
  const result         = Parse(ctx)
  const expectedValue  = ["abc ▇\n  ", "endverb"]

  assert_equal(15, strchars(text))
  assert_equal(17, strlen(text))
  assert_true(result.success)
  assert_equal(expectedValue, result.value)
  assert_equal(strlen(text), ctx.index)
enddef

def Test_LP_ComposingCharacters()
  const text = "X:ė̃\r  x"
  var   ctx  = Context.new(text)

  assert_equal(8,  strchars(text))       # Count composing characters separately
  assert_equal(7,  strchars(text, true)) # Ignore composing characters
  assert_equal(7,  strcharlen(text))     # Same as strchars(..., true)
  assert_equal(10, strlen(text))         # Length in bytes

  const R             = RegexToken(Space)
  const Line          = R('[^\r\n]\+')
  const Parse         = Seq(Text('X'), Text(':'), Line, Text('x'))
  const result        = Parse(ctx)
  const expectedValue = ['X', ':', 'ė̃', 'x']

  assert_true(result.success)
  assert_equal(expectedValue, result.value)
  assert_equal(strlen(text), ctx.index)
enddef

def Test_LP_CaseSensitiveRegex()
  const text = 'AbCd'
  var ctx = Context.new(text)
  var result = Regex('\CAbCd')(ctx)

  assert_true(result.success)
  assert_equal('AbCd', result.value)
  assert_equal(4, ctx.index)

  ctx = Context.new(text)
  result = Regex('\CAbCD')(ctx)
  assert_false(result.success)
enddef

tt.Run('_LP_')
