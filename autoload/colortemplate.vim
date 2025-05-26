vim9script

import 'libpath.vim'                                     as path
import '../import/libcolortemplate.vim'                  as lib
import '../import/colortemplate/generator/vim9.vim'      as vim9generator
import '../import/colortemplate/generator/viml.vim'      as vimlgenerator
import '../import/colortemplate/generator/template.vim'  as templategenerator

type Colorscheme = lib.Colorscheme
type Result      = lib.ParserResult

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

def CheckMetadata(theme: Colorscheme): bool
  if empty(theme.fullname)
    return Error('Please define the full name of the color scheme')
  endif

  if empty(theme.shortname)
    return Error('Please define the short name of the color scheme')
  endif

  if empty(theme.authors)
    return Error('Please define the author of the color scheme')
  endif

  return true
enddef

def CheckMissing(theme: Colorscheme): bool
  for background in ['dark', 'light']
    var db = theme.Db(background)
    var missing = db.MissingDefaultDefs()

    if !empty(missing)
      return Error($"Default definitions are missing for {join(missing, ', ')} ({db.background} background)")
    endif
  endfor

    return true
enddef


def WriteFile(filePath: string, content: list<string>, overwrite: bool = false): bool
  if overwrite || !path.Exists(filePath)
    var dirPath = path.Parent(filePath)

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
  var auxfiles: dict<list<string>> = theme.auxfiles

  for auxPath in keys(auxfiles)
    if !path.IsRelative(auxPath)
      return Error(printf(
        "Path of auxiliary file must be a relative path. Got '%s'", auxPath
      ))
    endif

    var outPath = path.Expand(auxPath, outputDir)
    var content = auxfiles[auxPath]

    if !WriteFile(outPath, content, overwrite)
      return false
    endif
  endfor

  return true
enddef

def ColorschemePath(bufnr: number): string
  var name: string

  if IsCached(bufnr)
    var theme: Colorscheme = CachedTheme(bufnr)
    name = theme.shortname
  else
    # Extract the name of the color scheme from the template
    var matchedName = matchlist(
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
  var errmsg   = result.label
  var included = matchlist(errmsg, 'in included file "\(.\{-}\)", byte \(\d\+\)')
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

  Error(
    $'Build failed: {errmsg} (line {byte2line(errpos)}, byte {errpos})'
  )

  execute ':' nr 'buffer'
  execute 'goto' errpos

  popup_atcursor(errmsg, {
    pos:         'botleft',
    line:        'cursor-1',
    col:         'cursor',
    border:      [1, 1, 1, 1],
    borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    moved:       'any',
    fixed:       true,
    highlight:   'WarningMsg',
  })
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
const toolbar = Toolbar.new()

export def GetToolbar(): Toolbar
  return toolbar
enddef

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

  var newdir = input('Change to: ', '', 'dir')

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

  var newdir = path.Expand(dirpath)

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
  var sourcePath    = ColorschemePath(bufnr)
  var colorsName    = path.Stem(sourcePath)
  var currentColors = get(g:, 'colors_name', 'default')

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
  var sourcePath = ColorschemePath(bufnr)

  if !path.IsReadable(sourcePath)
    return Error(printf('Color scheme not found at %s', sourcePath))
  endif

  execute "keepalt split" sourcePath

  ClearScreen()

  return true
enddef
# }}}

# Main {{{
export def Build(bufnr: number, outdir = '', bang = '', opts: dict<any> = {}): bool
  if !IsColortemplateBuffer(bufname(bufnr))
    return Error('Command can be executed only on Colortemplate buffers')
  endif

  var parseOnly:  bool          = get(opts, 'parseonly', false)
  var generator:  lib.Generator = get(opts, 'generator', null_object)
  var filesuffix: string        = get(opts, 'filesuffix', '.vim')

  var text      = join(getbufline(bufnr, 1, '$'), "\n")
  var overwrite = (bang == '!')
  var outputDir = empty(outdir) ? get(b:, 'colortemplate_outdir', '') : path.Expand(outdir)
  var inputPath = path.Expand(bufname(bufnr))

  if empty(outputDir)
    return Error('Output directory not set: please set b:colortemplate_outdir')
  endif

  Notice('Building' .. (empty(inputPath) ? '' : ' ' .. path.Stem(inputPath)) .. '…')

  var startTime = reltime()
  var [result: Result, theme: Colorscheme] = lib.Parse(text, path.Parent(inputPath))
  var elapsedParse = 1000.0 * reltimefloat(reltime(startTime))

  if !result.success
    ReportError(result, bufnr)
    return false
  endif

  CacheTheme(bufnr, theme)

  if parseOnly
    ClearScreen()
    return true
  endif

  if !CheckMetadata(theme)
    return false
  endif

  if !CheckMissing(theme)
    return false
  endif

  if generator == null
    if theme.options.backend == 'template'
      generator = templategenerator.Generator.new()
      filesuffix = '.colortemplate'
    elseif theme.options.backend == 'vim9'
      generator = vim9generator.Generator.new()
    elseif theme.options.backend->In(['viml', 'legacy'])
      generator = vimlgenerator.Generator.new()
    else
      throw $'Unexpected value for generator: {theme.options.backend}'
    endif
  endif

  var startGen   = reltime()
  var content    = generator.Generate(theme)
  var elapsedGen = 1000.0 * reltimefloat(reltime(startGen))
  var name       = theme.shortname .. filesuffix
  var filePath   = filesuffix == '.vim' ? path.Join(outputDir, 'colors', name) : path.Join(outputDir, name)

  if !WriteFile(filePath, content, overwrite)
    return false
  endif

  if !WriteAuxFiles(outputDir, theme, overwrite)
    return false
  endif

  var elapsed = 1000.0 * reltimefloat(reltime(startTime))

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

  var templates = path.Children(buildDir, '[^_]*.colortemplate')
  var N         = len(templates)
  var startTime = reltime()
  var success   = true
  var failed    = []

  for template in templates
    execute "edit" template
    if !Build(bufnr(), null_string, bang)
      failed->add(path.Basename(template))
      success = false
    endif
  endfor

  var elapsed = 1000.0 * reltimefloat(reltime(startTime))

  if success
    Notice(printf(
      'Success! %d color scheme%s built in %.00fms', N, N == 1 ? '' : 's', elapsed
    ))
  else
    return Error($'Some templates failed to build (see :messages): {failed}')
  endif

  return true
enddef

export def Stats()
  var nr = bufnr()

  if IsCached(nr) || Build(nr, null_string, null_string, {parseonly: true})
    lib.ColorStats(CachedTheme(nr))
  endif
enddef
# }}}

# vim: foldmethod=marker nowrap et ts=2 sw=2
