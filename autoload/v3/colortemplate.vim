vim9script

import 'libpath.vim' as path
import './colorscheme.vim' as cscheme
import './parser.vim'    as parser
import './generator.vim' as generator

const Metadata    = cscheme.Metadata
const Colorscheme = cscheme.Colorscheme

# Cache for generated color schemes
var colorschemes: dict<Colorscheme>

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


export def ViewSource(bufnr: number): bool
  var name: string

  if colorschemes->has_key(bufnr)
    const meta = colorschemes[bufnr].metadata
    name = meta.shortname
  else
    # Extract the name of the color scheme from the template
    const matchedName = matchlist(
      getbufline(bufnr, 1, "$"), '\m\c^\s*Short\s*name:\s*\(\w\+\)'
    )
    if empty(matchedName)  # Fallback to using the template's name
      name = path.Stem(bufname(bufnr))
    else
      name = matchedName[1]
    endif
  endif

  const sourcePath = path.Join(b:colortemplate_outdir, 'colors', name .. '.vim')
  if !path.IsReadable(sourcePath)
    return Error(printf('Cannot open file at %s', sourcePath))
  endif
  execute "keepalt split" sourcePath
  ClearScreen()

  return true
enddef
# }}}

# Main {{{
export def Build(bufnr: number, outdir: string = '', bang: string = ''): bool
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

  # Cache the color scheme data
  colorschemes[bufnr] = Colorscheme.new(
    bufnr,
    parseResult.meta,
    parseResult.dark,
    parseResult.light
  )

  const startGen       = reltime()
  const output         = generator.Generate(colorschemes[bufnr])
  const meta: Metadata = parseResult.meta
  const elapsedGen     = 1000.0 * reltimefloat(reltime(startGen))
  const name           = meta.shortname .. '.vim'
  const outpath        = path.Join(outputDir, 'colors', name)

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

# Build all templates inside a directory
export def BuildAll(directory: string = '', bang: string = ''): bool
  if !IsColortemplateBuffer('%')
    return Error('Command can be executed only in Colortemplate buffers')
  endif

  var buildDir = directory

  if empty(buildDir)
    if !empty(expand('%'))
      buildDir = expand('%:p:h')
    else
      return Error('Build directory not set. Is the current buffer unsaved?')
    endif
  endif

  if !path.IsReadable(buildDir)
    return Error(printf('Path not readable: %s', buildDir))
  endif

  const templates = path.Children(buildDir, '[^_]*.colortemplate')
  const N         = len(templates)
  const startTime = reltime()
  var   success   = true
  var   failed    = []

  for template in templates
    execute "edit" template
    if !Build(bufnr(), null_string, bang)
      failed->add(path.Basename(template))
      success = false
    endif
  endfor

  const elapsed = 1000.0 * reltimefloat(reltime(startTime))

  if success
    Notice(printf(
      'Success! %d color scheme%s built in %.00fms', N, N == 1 ? '' : 's', elapsed
    ))
  else
    return Error(printf('Some templates failed to build (see :messages): %s', failed))
  endif

  return true
enddef
# }}}

# vim: foldmethod=marker nowrap et ts=2 sw=2
