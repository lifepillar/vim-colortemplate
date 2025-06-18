vim9script

import 'libpath.vim'                                     as path
import autoload './colortemplate/config.vim'             as config
import '../import/colortemplate/colorscheme.vim'         as colorscheme
import '../import/colortemplate/colorstats.vim'          as stats
import '../import/colortemplate/parser/v3.vim'           as parser
import '../import/colortemplate/generator/base.vim'      as base
import '../import/colortemplate/generator/vim9.vim'      as vim9
import '../import/colortemplate/generator/viml.vim'      as viml
import '../import/colortemplate/generator/template.vim'  as colortemplate

type  Config      = config.Config
type  Colorscheme = colorscheme.Colorscheme
type  Result      = parser.ParserResult
const Parse       = parser.Parse

# Cache for generated color schemes
var theme_cache: dict<Colorscheme> = {}

# Helper functions {{{
def CacheTheme(bufnr: number, theme: Colorscheme)
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
# }}}

# Error reporting {{{
class ErrorReporter
  var ok = true # Is the color scheme without errors?
  public var warnings = true # Record and emit warnings?

  def new(opts: dict<any> = {})
    var clear = get(opts, 'clear', true)

    if clear
      setqflist([], 'r')
    endif
  enddef

  def AddItem(bufnr: number, msg: string, type: string, lnum: number, col: number)
    setqflist([{
        filename: bufname(bufnr),
        lnum:     lnum,
        col:      col,
        text:     msg,
        type:     type,
      }], 'a')
  enddef

  def AddWarning(bufnr: number, msg: string, lnum = 1, col = 1)
    if this.warnings
      this.AddItem(bufnr, msg, 'W', lnum, col)
    endif
  enddef

  def AddError(bufnr: number, msg: string, lnum = 1, col = 1)
    this.AddItem(bufnr, msg, 'E', lnum, col)
    this.ok = false
  enddef

  def AddParserError(bufnr: number, result: Result, opts: dict<any> = {})
    var popup    = get(opts, 'popup', true)
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

    this.AddError(nr, errmsg, byte2line(errpos))

    if popup
      popup_atcursor(errmsg, {
        border:      [1, 1, 1, 1],
        borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        close:       'clicked',
        col:         'cursor',
        fixed:       true,
        highlight:   'WarningMsg',
        line:        'cursor-1',
        moved:       'any',
        pos:         'botleft',
      })
    endif
  enddef

  def ShowQuickFixList()
    ClearScreen()
    botright copen
    wincmd p
  enddef

  def HideQuickFixList()
    cclose
  enddef

  def CheckColorscheme(bufnr: number, theme: Colorscheme)
    if empty(theme.shortname)
      this.AddError(bufnr, 'Please define the short name of the color scheme.')
    endif

    if empty(theme.environments)
      this.AddWarning(bufnr, '`Environments` metadata is missing (see :help colortemplate-environments).')
    endif

    if empty(theme.fullname)
      this.AddWarning(bufnr, 'Please define the full name of the color scheme.')
    endif

    if empty(theme.authors)
      this.AddWarning(bufnr, 'Please define the author of the color scheme.')
    endif

    for background in []
      if !theme.HasBackground(background)
        continue
      endif

      # Check for missing default definitions
      var db = theme.Db(background)
      var missing = db.MissingDefaultDefs()

      if !empty(missing)
        this.AddWarning(bufnr,
          $"Default definitions are missing for {join(missing, ', ')} ({db.background} background)."
        )
      endif

      # Check that 'fg', 'bg', 'ul' are used only if normal color is defined
      var groups = db.HighlightGroupsUsingAliasesInconsistently()

      if !empty(groups)
        this.AddWarning(bufnr,
          $"Special color names 'fg', 'bg', or 'ul' are used by {groups}, " ..
          $"but Normal does not define the corresponding color (see `:help E419`)."
        )
      endif
    endfor
  enddef
endclass
# }}}

# Toolbar {{{
export def ShowToolbar()
  if Config.UseToolbar() && getbufvar('%', '&ft') == 'colortemplate' && expand('%:t') !~# '\m^_'
    nunmenu WinBar

    var n = 1
    var actions = Config.ToolbarActions()

    for name in Config.ToolbarItems()
      var action = get(actions, name, ":echomsg 'Please define an action for this menu item (`:help colortemplate-toolbar`).'<cr>")

      execute $'nnoremenu <silent> 1.{n} WinBar.{escape(name, '@\/ ')} {action}'

      ++n
    endfor

    nnoremenu 1.99 WinBar.✕ :nunmenu WinBar<cr>
  endif
enddef

export def HideToolbar()
  if has('menu') && getbufvar('%', '&ft') == 'colortemplate'
    nunmenu WinBar
  endif
enddef
# }}}

# Public {{{
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

  return true
enddef

export def InitOutputDir(force = false)
  if force || empty(get(b:, 'colortemplate_outdir', ''))
    b:colortemplate_outdir = ''  # Ensure that the variable exists

    var outdir = expand('%:p:h')

    if empty(outdir)
      return
    endif

    if path.Basename(outdir) =~? '\m^\%(color\)\=templates\=$'
      outdir = path.Parent(outdir)
    endif

    colortemplate.SetOutputDir(outdir)
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

var prevColors:     string = ''
var prevBackground: string = ''

export def ShowColorscheme(bufnr: number)
  var sourcePath = ColorschemePath(bufnr)
  var colorsName = path.Stem(sourcePath)

  # This is necessary to make sure that the color scheme is found
  # (see, for instamce, https://github.com/vim/vim/issues/17558).
  execute $'set runtimepath^={fnameescape(b:colortemplate_outdir)}'

  if empty(prevColors)
    prevColors     = get(g:, 'colors_name', 'default')
    prevBackground = &background
  endif

  try
    execute 'colorscheme' colorsName
  catch
    Error(v:exception)
    return
  endtry
enddef

export def HideColorscheme()
  if empty(prevColors)
    return
  endif

  &background = prevBackground

  try
    execute 'colorscheme' prevColors
  catch
    Error(v:exception)
  finally
    prevColors = ''
  endtry
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
    return Error('Command can be executed only in Colortemplate buffers')
  endif

  var parseOnly:   bool   = get(opts, 'parseonly',   false)
  var filesuffix:  string = get(opts, 'filesuffix', '.vim')
  var errorpopup:  bool   = get(opts, 'errorpopup',   true)
  var clearqflist: bool   = get(opts, 'clearqflist',  true)

  var errorReporter = ErrorReporter.new({clear: clearqflist})
  var text          = join(getbufline(bufnr, 1, '$'), "\n")
  var overwrite     = (bang == '!')
  var outputDir     = empty(outdir) ? get(b:, 'colortemplate_outdir', '') : path.Expand(outdir)
  var inputPath     = path.Expand(bufname(bufnr))

  if empty(outputDir)
    return Error('Output directory not set: please set b:colortemplate_outdir')
  endif

  Notice('Building' .. (empty(inputPath) ? '' : ' ' .. path.Stem(inputPath)) .. '…')

  var startTime = reltime()
  var [result: Result, theme: Colorscheme] = Parse(text, path.Parent(inputPath))
  var elapsedParse = 1000.0 * reltimefloat(reltime(startTime))

  if !result.success
    errorReporter.AddParserError(bufnr, result, {popup: errorpopup})

    if clearqflist
      errorReporter.ShowQuickFixList()
    endif

    return false
  endif

  CacheTheme(bufnr, theme)

  if parseOnly
    ClearScreen()
    return true
  endif

  errorReporter.warnings = theme.options.warnings
  errorReporter.CheckColorscheme(bufnr, theme)

  if clearqflist && getqflist({size: true}).size > 0
    errorReporter.ShowQuickFixList()
  else
    errorReporter.HideQuickFixList()
  endif

  if !errorReporter.ok
    return false
  endif

  # If we get here, the color scheme can be generated!
  var backend = get(opts, 'backend', theme.options.backend)
  var generator: base.IGenerator

  if backend == 'template'
    generator = colortemplate.Generator.new(theme)
    filesuffix = '.colortemplate'
  elseif backend == 'vim9'
    generator = vim9.Generator.new(theme)
  elseif backend->In(['viml', 'legacy'])
    generator = viml.Generator.new(theme)
  else
    return Error($"Invalid generator: '{backend}'")
  endif

  var startGen   = reltime()
  var content    = generator.Generate()
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

  var templates     = path.Children(buildDir, '[^_]*.colortemplate')
  var N             = len(templates)
  var startTime     = reltime()
  var success       = true
  var failed        = []
  var errorReporter = ErrorReporter.new()

  for template in templates
    execute "edit" template

    if !Build(bufnr(), null_string, bang, {
        clearqflist: false,
        errorpopup:  false,
        })
      failed->add(path.Basename(template))
      success = false
    endif
  endfor

  var elapsed = 1000.0 * reltimefloat(reltime(startTime))

  if getqflist({size: true}).size == 0
    errorReporter.HideQuickFixList()
  else
    errorReporter.ShowQuickFixList()
  endif

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
    stats.ColorStats(CachedTheme(nr))
  endif
enddef
# }}}

# vim: foldmethod=marker nowrap et ts=2 sw=2
