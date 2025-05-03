vim9script

export var version = '0.0.1-alpha'

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

# Context, Result and Parser {{{
export class Context
  var text: string # The text to be parsed

  public var index:    number    = 0  # Next position yet to be parsed
  public var farthest: number    = -1 # Position of farthest failure
  public var state:    dict<any> = {} # Arbitrary parser's state

  def new(this.text, this.index = v:none)
  enddef

  def Reset(idx = 0)
    this.index = idx
    this.farthest = -1
  enddef
endclass

export const FAIL: string = null_string  # Backtracking label

export class Result
  var success: bool   = true
  var value:   any    = null
  var label:   string = FAIL
  var errpos:  number = -1

  def newSuccess(this.value = v:none)
    this.success = true
  enddef

  def newFailure(this.errpos, this.label = v:none)
    this.success = false
  enddef
endclass

def Success(value: any = null): Result
  return Result.newSuccess(value)
enddef

def Failure(
    ctx: Context,
    errpos: number = ctx.index,
    label: string = FAIL
): Result
  if ctx.farthest < errpos
    ctx.farthest = errpos
  endif

  return Result.newFailure(errpos, label)
enddef

export type Parser = func(Context): Result
# }}}

# Basic parsers {{{
export def Bol(ctx: Context): Result
  if ctx.index <= 0 || strpart(ctx.text, ctx.index - 1, 1) =~ '[\n\r]'
    return Success()
  else
    return Failure(ctx)
  endif
enddef

export def Eps(ctx: Context): Result
  return Success('')
enddef

export def Null(ctx: Context): Result
  return Success()
enddef

export def SoftFail(ctx: Context): Result
  return Failure(ctx)
enddef

export def Eof(ctx: Context): Result
  return ctx.index >= strchars(ctx.text) ? Success() : Failure(ctx)
enddef
# }}}

# Parser generators {{{
export def Fail(msg: string): Parser
  return (ctx: Context): Result => {
    return Failure(ctx, ctx.index, msg)
  }
enddef

# Case-sensitively matches a string at the current position.
# Fails when not found.
#
# NOTE: the text should not match across lines.
export def Text(text: string): Parser
  return (ctx: Context): Result => {
    const n = len(text)

    if strpart(ctx.text, ctx.index, n) == text
      ctx.index = ctx.index + n
      return Success(text)
    else
      return Failure(ctx)
    endif
  }
enddef

export def Regex(pattern: string): Parser
  return (ctx: Context): Result => {
    const match = matchstrpos(ctx.text, '^\%(' .. pattern .. '\)', ctx.index)

    if match[2] == -1
      return Failure(ctx)
    else
      ctx.index = match[2]
      return Success(match[0])
    endif
  }
enddef

export def Call(Fn: func(): void): Parser
  return (ctx: Context): Result => {
    Fn()
    return Success()
  }
enddef
# }}}

# Parser combinators {{{
export def Lab(P: Parser, label: string): Parser
  return (ctx: Context): Result => {
    const result = P(ctx)

    if result.success || result.label isnot FAIL
      return result
    endif

    return Failure(ctx, ctx.index, label)
  }
enddef

export def Seq(...Parsers: list<Parser>): Parser
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    var values: list<any> = []

    for P in Parsers
      const result = P(ctx)

      if result.success
        if result.value != null
          values->add(result.value)
        endif
      else
        ctx.index = startIndex
        return result
      endif
    endfor

    return Success(values)
  }
enddef

export def OneOf(...Parsers: list<Parser>): Parser
  return (ctx: Context): Result => {
    var farthestFailure = ctx.index

    for P in Parsers
      const result = P(ctx)

      if result.success || result.label isnot FAIL
        return result
      elseif result.errpos > farthestFailure
        farthestFailure = result.errpos
      endif
    endfor

    return Failure(ctx, farthestFailure)
  }
enddef

export def OneOrMore(P: Parser): Parser
  return Seq(P, Many(P))->Map((v, _) => flattennew(v, 1))
enddef

export def Opt(P: Parser): Parser
  return OneOf(P, Eps)
enddef

export def Many(P: Parser): Parser
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    var values: list<any> = []

    while (true)
      const currIndex = ctx.index
      const result = P(ctx)

      if result.success
        if result.value != null
          values->add(result.value)
        endif

        if ctx.index <= currIndex # Guard against infinite loops
          break
        endif
      else
        if result.label isnot FAIL
          ctx.index = startIndex
          return result
        endif

        break

      endif
    endwhile

    return Success(values)
  }
enddef

export def Skip(P: Parser): Parser
  return (ctx: Context): Result => {
    const result = P(ctx)
    return result.success ? Success() : result
  }
enddef

export def LookAhead(P: Parser): Parser
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    const result = Skip(P)(ctx)
    ctx.index = startIndex
    return result
  }
enddef

export def NegLookAhead(P: Parser): Parser
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    const result = Skip(P)(ctx)

    if result.success
      const errPos = ctx.index
      ctx.index = startIndex
      return Failure(ctx, errPos)
    else
      ctx.index = startIndex
      return Success()
    endif
  }
enddef
# }}}

# Derived parsers and other functions {{{
export const Eol   = Regex('[\r\n]')
export const Space = Regex('\%(\s\|\r\|\n\)\+')
export const Blank = Regex('\%(\s\|\r\|\n\)*')

export def Map(P: Parser, Fn: func(any, Context): any): Parser
  return (ctx: Context): Result => {
    const result = P(ctx)

    if result.success
      try
        return Success(Fn(result.value, ctx))
      catch
        return Failure(ctx, ctx.index, v:exception)
      endtry
    else
      return result
    endif
  }
enddef

export def Apply(P: Parser, Fn: func(any, Context): void): Parser
  return (ctx: Context): Result => {
    const result = P(ctx)

    if result.success
      try
        Fn(result.value, ctx)
        return Success()
      catch
        return Failure(ctx, ctx.index, v:exception)
      endtry
    endif
    return result
  }
enddef

export def Lexeme(Skipper: Parser): func(Parser): Parser
  return (P: Parser): Parser => {
    return Seq(P, Skipper)->Map((x, _) => x[0])
  }
enddef

export def TextToken(Skipper: Parser = Blank): func(string): Parser
  return (token: string): Parser => Lexeme(Skipper)(Text(token))
enddef

export def RegexToken(Skipper: Parser = Blank): func(string): Parser
  return (pattern: string): Parser => Lexeme(Skipper)(Regex(pattern))
enddef
# }}}
