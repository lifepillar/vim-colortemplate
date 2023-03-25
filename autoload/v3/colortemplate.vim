vim9script

import 'libpath.vim' as path
import './colorscheme.vim' as cscheme
import './parser.vim'    as parser
import './generator.vim' as generator

const Metadata = cscheme.Metadata

# Helper functions {{{
def ClearScreen()
  redraw
  echo "\r"
enddef

def Notice(msg: string)
  ClearScreen()
  unsilent echomsg '[Colortemplate]' msg .. '.'
enddef

def Error(msg: string): bool
  ClearScreen()
  echohl Error
  unsilent echomsg '[Colortemplate]' msg .. '.'
  echohl None
  return false
enddef

def IsColortemplateBuffer(bufname: string): bool
  return getbufvar(bufname, '&ft') == 'colortemplate'
enddef

def WriteColorscheme(content: list<string>, outpath: string, overwrite = false): bool
  const outdir = path.Parent(outpath)

  if !path.MakeDir(outdir, 'p')
    return Error(printf('Could not create directory: %s', outdir))
  endif

  if overwrite || !path.Exists(outpath)
    if writefile(content, outpath) < 0
      return Error(printf("Could not write %s: %s", outpath, v:exception))
    endif
  else
    return Error(printf("File exists: %s. Use ! to overwrite it", outpath))
  endif

  return true
enddef
# }}}

# Public {{{
export def AskOutputDir(): string
  if exists('b:colortemplate_outdir')
    if !empty(b:colortemplate_outdir)
      echo b:colortemplate_outdir
    endif
  else
    b:colortemplate_outdir = ''
  endif

  const newdir = input('Change to: ', '', 'dir')

  if empty(newdir)
    return b:colortemplate_outdir
  endif

  SetOutputDir(newdir)

  return b:colortemplate_outdir
enddef

export def SetOutputDir(dirpath: string): bool
  if !IsColortemplateBuffer('%')
    return Error('Directory can be set only in Colortemplate buffers')
  endif

  const newdir = path.Expand(dirpath)

  if !path.IsDirectory(newdir)
    return Error(printf(
      'Directory does not exist or path is not a directory: %s', newdir
    ))
  elseif !path.IsWritable(newdir)
    return Error('Directory is not writable')
  endif

  b:colortemplate_outdir = newdir

  if get(g:, 'colortemplate_rtp', true)
    execute 'set runtimepath^=' .. b:colortemplate_outdir
  endif

  return true
enddef

export def Make(bufnr: number, outdir: string = '', bang: string = ''): bool
  if !IsColortemplateBuffer('%')
    return Error('Command can be executed only in Colortemplate buffers')
  endif

  const text      = join(getbufline(bufnr, 1, '$'), "\n")
  const overwrite = (bang == '!')
  const outputDir = empty(outdir) ? get(b:, 'colortemplate_outdir', '') : path.Expand(outdir)
  const inputPath = expand('%:p')

  if empty(outputDir)
    return Error('Output directory not set: please set b:colortemplate_outdir')
  endif

  Notice(printf('Building%s…', empty(inputPath) ? '' : ' ' .. path.Stem(inputPath)))

  const startTime = reltime()
  const parseResult = parser.Parse(text, path.Parent(inputPath))
  const elapsedParse = 1000.0 * reltimefloat(reltime(startTime))
  const result: parser.Result = parseResult.result

  if !result.success
    Notice(printf(
      "Build failed: %s (line %d, byte %d)",
      result.label, byte2line(result.errpos + 1), result.errpos + 1
    ))
    execute ':' bufnr 'buffer'
    execute 'goto' result.errpos
    return false
  endif

  const startGen = reltime()
  const output: list<string> = generator.Generate(
    parseResult.meta, {
      'dark':  parseResult.dark,
      'light': parseResult.light,
    }
  )
  const meta: Metadata = parseResult.meta
  const elapsedGen = 1000.0 * reltimefloat(reltime(startGen))
  const name       = meta.shortname .. '.vim'
  const outpath    = path.Join(outputDir, 'colors', name)

  if !WriteColorscheme(output, outpath, overwrite)
    return false
  endif

  const elapsed = 1000.0 * reltimefloat(reltime(startTime))

  Notice(printf(
    'Success! %s created in %.00fms (parser: %.00fms, generator: %.00fms)',
    path.Basename(outpath), elapsed, elapsedParse, elapsedGen
  ))

  return true
enddef
# }}}

# vim: foldmethod=marker nowrap et ts=2 sw=2
