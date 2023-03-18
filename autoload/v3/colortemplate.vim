vim9script

import './parser.vim'    as parser
import './generator.vim' as generator

class Config
  public this.creator = true
  public this.useTabs = false
endclass

# Helper functions {{{
def ClearScreen()
  redraw
  echo "\r"
enddef

def Notice(msg: string)
  ClearScreen()
  unsilent echomsg '[Colortemplate]' msg
enddef

def Error(msg: string, rethrow = true)
  ClearScreen()
  if rethrow
    unsilent echoerr '[Colortemplate]' msg
  else
    echohl Error
    unsilent echomsg '[Colortemplate]' msg
    echohl None
  endif
enddef

def Failure(): bool
    g:colortemplate_exit_status = 1
    return false
enddef

def Success(): bool
    g:colortemplate_exit_status = 0
    return true
enddef

def NewBuffer(name: string, content: list<string>, config: Config = Config.new()): number
  const nr = bufadd(name)

  setbufvar(nr, "&filetype",   "vim")
  setbufvar(nr, "&rightleft",  0)
  setbufvar(nr, "&wrap",       0)
  setbufvar(nr, "&bufhidden",  "hide")
  setbufvar(nr, "&expandtab",  config.useTabs ? 0 : 1)
  setbufvar(nr, "&tabstop",    2)
  setbufvar(nr, "&shiftwidth", 2)
  setbufvar(nr, "&buflisted",  1)
  bufload(nr)
  silent execute printf(":%dbufdo normal ggdG", nr)
  setbufline(nr, 1, content)
  silent execute printf(":%dbufdo normal gg=G", nr)

  return nr
enddef
# }}}

# Main {{{
export def Make(bufnr: number, outdir: string = '', bang: string = ''): bool
  if !empty(getbufvar('%', '&buftype')) || empty(expand('%:p'))
    Error("No filename. Please save your document first.", false)
    return Failure()
  endif

  update

  const inputPath = expand('%:p')
  const text      = join(getbufline(bufnr, 1, '$'), "\n")
  const overwrite = (bang == '!')
  const outputDir = empty(outdir)
        \ ? simplify(fnamemodify(inputPath, ":p:h") .. '/colors/')
        \ : simplify(fnamemodify(outdir, ":p"))

  # TODO: check that outputDir is valid and writable

  Notice(printf(
    'Building %s…', fnamemodify(inputPath, ':t:r')
  ))

  const startTime = reltime()
  const parseResult = parser.Parse(text)
  const elapsedParse = 1000.0 * reltimefloat(reltime(startTime))
  const result: parser.Result = parseResult.result

  if !result.success
    Notice(printf(
      "Build failed: %s (line %d, byte %d)",
      result.label, byte2line(result.errpos + 1), result.errpos + 1
    ))
    execute ':' bufnr 'buffer'
    execute 'goto' result.errpos
    return Failure()
  endif

  const startGen = reltime()
  const output: list<string> = generator.Generate(
    parseResult.meta, {
      'dark':  parseResult.dark,
      'light': parseResult.light,
    }
  )
  const elapsedGen = 1000.0 * reltimefloat(reltime(startGen))
  const nr         = NewBuffer('OutputColorscheme.vim', output)
  const elapsed    = 1000.0 * reltimefloat(reltime(startTime))
  const outputPath = fnamemodify(inputPath, ":p")  # FIXME

  Notice(printf(
    'Success! [%s created in %.00fms (parser: %.00fms, generator: %.00fms)]',
    fnamemodify(outputPath, ':t'), elapsed, elapsedParse, elapsedGen
  ))

  return Success()
enddef
# }}}

# vim: foldmethod=marker nowrap et ts=2 sw=2
