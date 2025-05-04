vim9script

import 'libpath.vim'                     as path
import 'libparser.vim'                   as libparser
import './colortemplate/colorscheme.vim' as themes
import './colortemplate/parser.vim'      as parser
import './colortemplate/generator.vim'   as gen
import './colortemplate/colorstats.vim'  as stats

type Colorscheme = themes.Colorscheme
type Result      = libparser.Result
type Generator   = gen.Generator

# Cache for generated color schemes
var theme_cache: dict<Colorscheme>

# Helper functions {{{
def CacheTheme(bufnr: number, theme: Colorscheme)
  unlockvar theme_cache
  theme_cache[bufnr] = theme
enddef

def CachedTheme(bufnr: number): Colorscheme
  return theme_cache[bufnr]
enddef

def IsCached(bufnr: number): bool
  return theme_cache->has_key(bufnr)
enddef

def In(item: any, items: list<any>): bool
  return index(items, item) != -1
enddef

def NotIn(item: any, items: list<any>): bool
  return index(items, item) == -1
enddef

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

# export def RegisterBackend(generator: IGenerator)
# enddef

def CheckMetadata(theme: Colorscheme)
  if empty(theme.fullname)
    throw 'Please define the full name of the color scheme'
  endif

  if empty(theme.shortname)
    throw 'Please define the short name of the color scheme'
  endif

  if empty(theme.author)
    throw 'Please define the author of the color scheme'
  endif
enddef

def WriteFile(filePath: string, content: list<string>, overwrite: bool = false): bool
  if overwrite || !path.Exists(filePath)
    const dirPath = path.Parent(filePath)

    if !path.MakeDir(dirPath, 'p')
      return Error(printf('Could not create directory: %s', dirPath))
    endif

    if writefile(content, filePath) < 0
      return Error(printf("Could not write %s: %s", filePath, v:exception))
    endif
  else
    return Error(printf("File exists: %s. Use ! to overwrite it", filePath))
  endif

  return true
enddef

def WriteAuxFiles(outputDir: string, theme: Colorscheme, overwrite: bool): bool
  const auxfiles: dict<list<string>> = theme.auxfiles

  for auxPath in keys(auxfiles)
    if !path.IsRelative(auxPath)
      return Error(printf(
        "Path of auxiliary file must be a relative path. Got '%s'", auxPath
      ))
    endif

    const outPath = path.Expand(auxPath, outputDir)
    const content = auxfiles[auxPath]

    if !WriteFile(outPath, content, overwrite)
      return false
    endif
  endfor

  return true
enddef

def ColorschemePath(bufnr: number): string
  var name: string

  if IsCached(bufnr)
    const theme: Colorscheme = CachedTheme(bufnr)
    name = theme.shortname
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

  return path.Join(b:colortemplate_outdir, 'colors', name .. '.vim')
enddef

def ReportError(result: Result, bufnr: number)
  const errmsg = result.label
  const included = matchlist(errmsg, 'in included file "\(.\{-}\)", byte \(\d\+\)')
  var errpos: number
  var nr:     number

  if empty(included)
    nr = bufnr
    errpos = result.errpos + 1
  else
    execute 'edit' included[1]
    nr = bufnr()
    errpos = str2nr(included[2]) + 1
  endif

  Notice(printf(
    "Build failed: %s (line %d, byte %d)", result.label, byte2line(errpos), errpos
  ))
  execute ':' nr 'buffer'
  execute 'goto' errpos
enddef
# }}}

# Toolbar {{{
class Toolbar
  public var entries: list<string>
  public var actions: dict<string>

  def new()
    this.entries = [
      'Build!',
      'BuildAll!',
      'Show',
      'Hide',
      'Check',
      'Stats',
      'Source',
      'HiTest',
      'OutDir',
    ]
    this.actions = extend({
          \ 'Build!':     ':Colortemplate!<cr>',
          \ 'BuildAll!':  ':ColortemplateAll!<cr>',
          \ 'Check':      ':ColortemplateCheck<cr>',
          \ 'Colortest':  ':ColortemplateTest<cr>',
          \ 'HiTest':     ':ColortemplateHiTest<cr>',
          \ 'Hide':       ':ColortemplateHide<cr>',
          \ 'OutDir':     ':ColortemplateOutdir<cr>',
          \ 'Show':       ':ColortemplateShow<cr>',
          \ 'Source':     ':ColortemplateSource<cr>',
          \ 'Stats':      ':ColortemplateStats<cr>',
          \ }, get(g:, 'colortemplate_toolbar_actions', {}))
  enddef

  def Show()
    if has('menu')
        && get(g:, 'colortemplate_toolbar', true)
        && getbufvar('%', '&ft') == 'colortemplate'
        && expand('%:t') !~# '\m^_'
      nunmenu WinBar

      var n = 1

      for entry in this.entries
        if this.actions->has_key(entry)
          execute printf(
            'nnoremenu <silent> 1.%d WinBar.%s %s', n, escape(entry, '@\/ '), this.actions[entry]
          )
          ++n
        endif
      endfor

      nnoremenu 1.99 WinBar.✕ :nunmenu WinBar<cr>
    endif
  enddef

  def Hide()
    if getbufvar('%', '&ft') == 'colortemplate'
      nunmenu WinBar
    endif
  enddef
endclass
# }}}

# Public {{{
export const toolbar = Toolbar.new()

export def ColorTest(bufnr: number)
  ShowColorscheme(bufnr)
  runtime syntax/colortest.vim
enddef

export def HighlightTest(bufnr: number)
  ShowColorscheme(bufnr)
  runtime syntax/hitest.vim
enddef

export def Validate(bufnr: number)
  if ViewSource(bufnr)
    runtime colors/tools/check_colors.vim
    input('[Colortemplate] Press a key to continue')
    wincmd c
  endif
enddef

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
    execute 'set runtimepath^=' .. fnameescape(b:colortemplate_outdir)
  endif

  return true
enddef

var enabledColors:  list<string> = []
var prevColors:     string
var prevBackground: string

export def ShowColorscheme(bufnr: number)
  const sourcePath    = ColorschemePath(bufnr)
  const colorsName    = path.Stem(sourcePath)
  const currentColors = get(g:, 'colors_name', 'default')

  if currentColors->NotIn(enabledColors)
    prevColors = currentColors
    prevBackground = &background
  endif

  try
    execute 'colorscheme' colorsName
  catch
    Error(v:exception)
    return
  endtry

  if colorsName->NotIn(enabledColors)
    enabledColors->add(colorsName)
  endif
enddef

export def HideColorscheme()
  enabledColors = []
  &background   = prevBackground
  execute 'colorscheme' prevColors
enddef

export def ViewSource(bufnr: number): bool
  const sourcePath = ColorschemePath(bufnr)

  if !path.IsReadable(sourcePath)
    return Error(printf('Color scheme not found at %s', sourcePath))
  endif

  execute "keepalt split" sourcePath

  ClearScreen()

  return true
enddef
# }}}

# Main {{{
export def Build(bufnr: number, outdir: string = '', bang: string = '', parseOnly = false): bool
  if !IsColortemplateBuffer(bufname(bufnr))
    return Error('Command can be executed only on Colortemplate buffers')
  endif

  const text      = join(getbufline(bufnr, 1, '$'), "\n")
  const overwrite = (bang == '!')
  const outputDir = empty(outdir) ? get(b:, 'colortemplate_outdir', '') : path.Expand(outdir)
  const inputPath = path.Expand(bufname(bufnr))

  if empty(outputDir)
    return Error('Output directory not set: please set b:colortemplate_outdir')
  endif

  Notice(printf('Building%s…', empty(inputPath) ? '' : ' ' .. path.Stem(inputPath)))

  const startTime = reltime()
  const [result: Result, theme: Colorscheme] = parser.Parse(text, path.Parent(inputPath))
  const elapsedParse = 1000.0 * reltimefloat(reltime(startTime))

  if !result.success
    ReportError(result, bufnr)
    return false
  endif

  CacheTheme(bufnr, theme)

  if parseOnly
    ClearScreen()
    return true
  endif

  CheckMetadata(theme)

  const startGen       = reltime()
  const generator      = Generator.new(theme)
  const content        = generator.Generate()
  const elapsedGen     = 1000.0 * reltimefloat(reltime(startGen))
  const name           = theme.shortname .. '.vim'
  const filePath       = path.Join(outputDir, 'colors', name)

  if !WriteFile(filePath, content, overwrite)
    return false
  endif

  if !WriteAuxFiles(outputDir, theme, overwrite)
    return false
  endif

  const elapsed = 1000.0 * reltimefloat(reltime(startTime))

  Notice(printf(
    'Success! %s created in %.00fms (parser: %.00fms, generator: %.00fms)',
    path.Basename(filePath), elapsed, elapsedParse, elapsedGen
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

export def Stats()
  const nr = bufnr()

  if IsCached(nr) || Build(nr, null_string, null_string, true)
    stats.ColorStats(CachedTheme(nr))
  endif
enddef
# }}}

# vim: foldmethod=marker nowrap et ts=2 sw=2
