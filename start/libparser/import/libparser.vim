vim9script

# TODO: replace when `type` is implemented in Vim
# type TSuccess dict<any>
# type TFailure dict<any>
# type TResult  TSuccess | TFailure
# type TContext dict<any>
# type TParser  func(TContext): TResult

# The parser's context must have these keys:
#
# text:      string  (Immutable, multi-line) text to be parsed
# index:     number  Current position in text

# Internal utility functions {{{
export def Success(value: any): dict<any> # FIXME: remove export
  return { success: true, value: value }
enddef

# For failure, `value` is unused, and defined only for better output in tests.
def Failure(expected: string, backtrack: bool): dict<any>
  return { success: false, expected: expected, value: null, backtrack: backtrack }
enddef

def SaveState(ctx: dict<any>): dict<number>
  var state: dict<number> = {}
  state.index = ctx.index
  return state
enddef

def RestoreState(state: dict<number>, ctx: dict<any>)
  ctx.index = state.index
enddef
# }}}

# Convenience functions {{{
# Converts a failure into a non-backtracking failure.
export def DontBacktrack(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)
    return result.success ? result : Failure(result.expected, false)
  }
enddef

# Maps a Success to a callback.
export def Map(Parser: func(dict<any>): dict<any>, Fn: func(any): any): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)
    return result.success ? Success(Fn(result.value)) : result
  }
enddef

# Upon success, consumes a value by applying a function and returns a null value.
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

# Extend a parser with a failure message when the parser does not provide one,
# or override its failure message when it does provide one.
export def Label(Parser: func(dict<any>): dict<any>, expected: string): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)

    if result.success
      return result
    endif

    return Failure(expected, result.backtrack)
  }
enddef

# Returns a function that transforms a parser P into another parser that first
# applies P and then uses SkipParser to skip stuff (e.g., white space,
# comments). Returns the result of P.
export def Lexeme(SkipParser: func(dict<any>): dict<any>): func(func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any> => {
    return Sequence(Parser, SkipParser)->Map((x) => x[0])
  }
enddef
# }}}

# Parser generators {{{
# Case-sensitively matches a string at the current position.
# Fails when not found.
#
# NOTE: the text should not match across lines.
export def Text(text: string): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const n = len(text)

    if (strcharpart(ctx.text, ctx.index, n) ==# text)
      ctx.index = ctx.index + n
      return Success(text)
    else
      return Failure(text, true)
    endif
  }
enddef

# Matches a regexp at the current position. Fails when not found.
#
# NOTE: the pattern should not match across lines.
export def Regex(pattern: string, expected: string): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const match = matchstrpos(ctx.text, '^\%(' .. pattern .. '\)', ctx.index)

    if match[2] == -1
      return Failure(expected, true)
    else
      ctx.index = match[2]
      return Success(match[0])
    endif
  }
enddef
# }}}

# Basic parsers {{{
# Parser that does nothing, returns no value (returns null), and never fails.
export def Null(ctx: dict<any>): dict<any>
  return Success(null)
enddef

# Parser that does nothing, returns no value (returns null), and always fails.
export def Fail(ctx: dict<any>): dict<any>
  return Failure('fail', false)
enddef

# Matches at the end of file.
export def Eof(ctx: dict<any>): dict<any>
  return ctx.index >= len(ctx.text) ? Success(null) : Failure('end of input', true)
enddef
# }}}

# Parser combinators {{{
# Tries each parser in the given order, starting from the same point in the
# input. A parser is tried only if the previous one has failed without
# consuming any input, i.e., this parser does not implement a longest match
# rule.
# Returns the result of the first parser that succeeds, or the result of the
# first parser that fails after consuming some input, or the result of the
# first parser that fails and its result prevents backtracking.
export def OneOf(...Parsers: list<func(dict<any>): dict<any>>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const startIndex = ctx.index

    for Parser in Parsers
      const result = Parser(ctx)

      if result.success || !result.backtrack || startIndex < ctx.index
        return result
      endif
    endfor

    return Failure('', true) # Use Label() to attach a message
  }
enddef

# Matches a parser, or succeeds without consuming any input.
export def Optional(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return OneOf(Parser, Null)
enddef

# Applies a parser zero or more times, as many as possible. Accumulates the
# parsed results into a List. Fails when an instance of the parser fails after
# consuming some, but not all, the input.
export def Many(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    var values = []

    while (true)
      const currIndex = ctx.index
      const result = Parser(ctx)

      if result.success
        if type(result.value) != v:t_none
          values->add(result.value)
        endif

        if ctx.index == currIndex # Guard against infinite loops
          return Failure('no infinite loop', false)
        endif
      else
        # Report failure and do not backtrack if some input was consumed
        if ctx.index > currIndex || !result.backtrack
          return Failure(result.expected, false)
        endif

        break
      endif
    endwhile

    return Success(values)
  }
enddef

# Looks for an exact sequence of parsers. Fails when the sequence cannot be parsed.
export def Sequence(...Parsers: list<func(dict<any>): dict<any>>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    var values = []

    for Parser in Parsers
      const result = Parser(ctx)

      if result.success
        if type(result.value) != v:t_none
          values->add(result.value)
        endif
      else
        return result
      endif
    endfor

    return Success(values)
  }
enddef

# Applies a parser and throws away its result upon success.
export def Skip(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)

    return result.success ? Success(null) : result
  }
enddef

# Chooses a parser based on some look-ahead parser.
export def LookAhead(LAP: func(dict<any>): dict<any>, P1: func(dict<any>): dict<any>, P2: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const state  = SaveState(ctx)
    const result = LAP(ctx)
    RestoreState(state, ctx)

    return result.success ? P1(ctx) : P2(ctx)
  }
enddef

export def LookaheadPred(Parser: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const state  = SaveState(ctx)
    const result = Parser(ctx)
    RestoreState(state, ctx)

    return result.success ? Failure(result.expected, false) : result
  }
enddef

export def Throw(Parser: func(dict<any>): dict<any>, Recover: func(dict<any>): dict<any>): func(dict<any>): dict<any>
  return (ctx: dict<any>): dict<any> => {
    const result = Parser(ctx)
    if result.success
      return result
    endif
    Recover(ctx)
    return Failure('Throw', true)
  }
enddef
# }}}

