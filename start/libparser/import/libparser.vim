vim9script

# Author:       Lifepillar <lifepillar@lifepillar.me>
# Maintainer:   Lifepillar <lifepillar@lifepillar.me>
# Website:      https://github.com/lifepillar/vim-devel
# License:      Vim License (see `:help license`)

# TODO: replace when `type` is implemented in Vim
# type TSuccess dict<any>
# type TFailure dict<any>
# type TResult  TSuccess | TFailure
# type TContext dict<any>
# type TParser  func(TContext): TResult

# Context and result {{{
export class Context
  this.text:            string      # The text to be parsed
  public this.index:    number = 0  # Next position yet to be parsed
  public this.farthest: number = -1 # Position of farthest failure

  def new(this.text, this.index = v:none)
  enddef

  def Reset(idx = 0)
    this.index = idx
    this.farthest = -1
  enddef
endclass

export const FAIL: string = null_string  # Backtracking label

export class Result
  this.success: bool   = true
  this.value:   any    = null
  this.label:   string = FAIL
  this.errpos:  number = -1

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
# }}}

# Basic parsers {{{
export def Bol(ctx: Context): Result
  if ctx.index <= 0 || ctx.text[ctx.index - 1] =~ '[\n\r]'
    return Success(null)
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
export def Fail(msg: string): func(Context): Result
  return (ctx: Context): Result => {
    return Failure(ctx, ctx.index, msg)
  }
enddef

# Case-sensitively matches a string at the current position.
# Fails when not found.
#
# NOTE: the text should not match across lines.
export def Text(text: string): func(Context): Result
  return (ctx: Context): Result => {
    const n = strchars(text)

    if strcharpart(ctx.text, ctx.index, n) == text
      ctx.index = ctx.index + n
      return Success(text)
    else
      return Failure(ctx)
    endif
  }
enddef

# NOTE: the pattern should not match across lines.
export def Regex(pattern: string): func(Context): Result
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
# }}}

# Parser combinators {{{
export def Lab(
    Parser: func(Context): Result,
    label: string
): func(Context): Result
  return (ctx: Context): Result => {
    const result = Parser(ctx)

    if result.success || result.label isnot FAIL
      return result
    endif

    return Failure(ctx, ctx.index, label)
  }
enddef

export def Seq(
    ...Parsers: list<func(Context): Result>
): func(Context): Result
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    var values: list<any> = []

    for Parser in Parsers
      const result = Parser(ctx)

      if result.success
        if result.value != null
          values->add(result.value)
        endif
      else
        ctx.index = startIndex
        return result
      endif
    endfor

    return empty(values) ? Success() : Success(values)
  }
enddef

export def OneOf(
    ...Parsers: list<func(Context): Result>
): func(Context): Result
  return (ctx: Context): Result => {
    var farthestFailure = ctx.index

    for Parser in Parsers
      const result = Parser(ctx)

      if result.success || result.label isnot FAIL
        return result
      elseif result.errpos > farthestFailure
        farthestFailure = result.errpos
      endif
    endfor

    return Failure(ctx, farthestFailure)
  }
enddef

export def OneOrMore(
    Parser: func(Context): Result
): func(Context): Result
  return Seq(Parser, Many(Parser))->Map((v) => flattennew(v, 1))
enddef

export def Opt(
    Parser: func(Context): Result
): func(Context): Result
  return OneOf(Parser, Null)
enddef

export def Many(Parser: func(Context): Result): func(Context): Result
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    var values: list<any> = []

    while (true)
      const currIndex = ctx.index
      const result = Parser(ctx)

      if result.success
        if ctx.index <= currIndex # Guard against infinite loops
          ctx.index = startIndex
          return Failure(ctx, currIndex, 'no infinite loop')
        endif

        if result.value != null
          values->add(result.value)
        endif
      else
        if result.label isnot FAIL
          ctx.index = startIndex
          return result
        endif

        break

      endif
    endwhile

    return empty(values) ? Success() : Success(values)
  }
enddef

export def Skip(Parser: func(Context): Result): func(Context): Result
  return (ctx: Context): Result => {
    const result = Parser(ctx)
    return result.success ? Success() : result
  }
enddef

export def LookAhead(Parser: func(Context): Result): func(Context): Result
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    const result = Skip(Parser)(ctx)
    ctx.index = startIndex
    return result
  }
enddef

export def NegLookAhead(Parser: func(Context): Result): func(Context): Result
  return (ctx: Context): Result => {
    const startIndex = ctx.index
    const result = Skip(Parser)(ctx)

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
export def Map(
    Parser: func(Context): Result,
    Fn: func(any): any
): func(Context): Result
  return (ctx: Context): Result => {
    const result = Parser(ctx)
    return result.success ? Success(Fn(result.value)) : result
  }
enddef

export def Apply(Parser: func(Context): Result, Fn: func(any): void): func(Context): Result
  return (ctx: Context): Result => {
    const result = Parser(ctx)
    if result.success
      Fn(result.value)
      return Success()
    endif
    return result
  }
enddef

export def Lexeme(
    SkipParser: func(Context): Result
): func(func(Context): Result): func(Context): Result
  return (Parser: func(Context): Result): func(Context): Result => {
    return Seq(Parser, SkipParser)->Map((x) => x[0])
  }
enddef

export const Eol   = Regex('[\r\n]')
export const Space = Regex('\%(\r\|\n\|\s\)*')
export const Token = Lexeme(Space)

export def T(token: string): func(Context): Result
  return Token(Text(token))
enddef

export def R(pattern: string): func(Context): Result
  return Token(Regex(pattern))
enddef
# }}}
