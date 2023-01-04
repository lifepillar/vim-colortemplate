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

# Internals {{{
export const fail = null_string  # Backtracking label

def Success(value: any): dict<any>
  return {success: true, value: value}
enddef

def Failure(ctx: dict<any>, errpos: number, label: string = fail): dict<any>
  ctx.furthest = errpos
  return {success: false,  label: label, errpos: ctx.furthest}
enddef
# }}}

# Basic parsers {{{
export def Eps(ctx: dict<any>): dict<any>
  return Success('')
enddef

export def Null(ctx: dict<any>): dict<any>
  return Success(null)
enddef

export def SoftFail(ctx: dict<any>): dict<any>
  return Failure(ctx, ctx.index)
enddef

export def Eof(ctx: dict<any>): dict<any>
  if ctx.index >= strchars(ctx.text)
    return Success(null)
  else
    return Failure(ctx, ctx.index)
  endif
enddef
# }}}

# Parser generators {{{
export def Fail(msg: string): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    return Failure(ctx, ctx.index, msg)
  }
enddef

# Case-sensitively matches a string at the current position.
# Fails when not found.
#
# NOTE: the text should not match across lines.
export def Text(text: string): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const n = strchars(text)

    if strcharpart(ctx.text, ctx.index, n) == text
      ctx.index = ctx.index + n
      return Success(text)
    else
      return Failure(ctx, ctx.index)
    endif
  }
enddef

# NOTE: the pattern should not match across lines.
export def Regex(pattern: string): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const match = matchstrpos(ctx.text, '^\%(' .. pattern .. '\)', ctx.index)

    if match[2] == -1
      return Failure(ctx, ctx.index)
    else
      ctx.index = match[2]
      return Success(match[0])
    endif
  }
enddef
# }}}

# Parser combinators {{{
export def Err(
    Parser: func(dict<any>): dict<any>,
    label: string
): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)

    if result.success || result.label isnot fail
      return result
    endif

    return Failure(ctx, ctx.index, label)
  }
enddef

export def Seq(
    ...Parsers: list<func(dict<any>): dict<any>>
): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
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

    return empty(values) ? Success(null) : Success(values)
  }
enddef

export def OneOf(
    ...Parsers: list<func(dict<any>): dict<any>>
): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    var furthestFailure = ctx.index

    for Parser in Parsers
      const result = Parser(ctx)

      if result.success || result.label isnot fail
        return result
      elseif result.errpos > furthestFailure
        furthestFailure = result.errpos
      endif
    endfor

    return Failure(ctx, furthestFailure)
  }
enddef

export def Opt(
    Parser: func(dict<any>): dict<any>
): func(dict<any>): dict<any>
  return OneOf(Parser, Null)
enddef

export def Many(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
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
        if result.label isnot fail
          ctx.index = startIndex
          return result
        endif

        break

      endif
    endwhile

    return empty(values) ? Success(null) : Success(values)
  }
enddef

export def Skip(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)
    return result.success ? Success(null) : result
  }
enddef

export def LookAhead(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const startIndex = ctx.index
    const result = Skip(Parser)(ctx)
    ctx.index = startIndex
    return result
  }
enddef

export def NegLookAhead(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const startIndex = ctx.index
    const result = Skip(Parser)(ctx)

    if result.success
      const errPos = ctx.index
      ctx.index = startIndex
      return Failure(ctx, errPos)
    else
      ctx.index = startIndex
      return Success(null)
    endif
  }
enddef
# }}}

# Derived parsers and other functions {{{
export def Context(text: string, index: number = 0): dict<any>
  return {text: text, index: index, furthest: index}
enddef

export def Map(
    Parser: func(dict<any>): dict<any>,
    Fn: func(any): any
): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)
    return result.success ? Success(Fn(result.value)) : result
  }
enddef

export def Apply(Parser: func(dict<any>): dict<any>, Fn: func(any): void): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)
    if result.success
      Fn(result.value)
      return Success(null)
    endif
    return result
  }
enddef

export def Lexeme(
    SkipParser: func(dict<any>): dict<any>
): func(func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any> => {
    return Seq(Parser, SkipParser)->Map((x) => x[0])
  }
enddef

export const Eol   = Regex('[\r\n]')
export const Space = Regex('\%(\r\|\n\|\s\)*')
export const Token = Lexeme(Space)

export def T(token: string): func(dict<any>): dict<any>
  return Token(Text(token))
enddef

export def R(pattern: string): func(dict<any>): dict<any>
  return Token(Regex(pattern))
enddef
# }}}
