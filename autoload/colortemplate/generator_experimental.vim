vim9script

import './colorscheme.vim'
import './version.vim'
import 'librelalg.vim' as ra

# Aliases {{{
const AntiJoin             = ra.AntiJoin
const EquiJoin             = ra.EquiJoin
const LeftEquiJoin         = ra.LeftEquiJoin
const PartitionBy          = ra.PartitionBy
const Query                = ra.Query
const Select               = ra.Select
const Sort                 = ra.Sort
const Transform            = ra.Transform
# }}}

const VERSION        = version.VERSION
const NO_DISCR_VALUE = colorscheme.DEFAULT_DISCR_VALUE
type  Database       = colorscheme.Database
const Metadata       = colorscheme.Metadata
const BASE_FILLER    = [{Fg: '', Bg: '', Special: '', Style: '', Font: '', Start: '', Stop: ''}]
const LINK_FILLER    = [{TargetGroup: ''}]

# Helper functions {{{
def CompareDistinct(s1: string, s2: string): number
  return s1 < s2 ? -1 : 1
enddef

def CompareByHiGroupName(t: dict<any>, u: dict<any>): number
  if t.HiGroupName == u.HiGroupName
    return 0
  elseif t.HiGroupName == 'Normal'
    return -1
  elseif u.HiGroupName == 'Normal'
    return 1
  else
    return CompareDistinct(t.HiGroupName, u.HiGroupName)
  endif
enddef

def CompareByDiscrName(t: dict<any>, u: dict<any>): number
  if t.DiscrName == u.DiscrName
    return 0
  else
    return CompareDistinct(t.DiscrName, u.DiscrName)
  endif

enddef

def CompareByDiscrValueAndHiGroupName(t: dict<any>, u: dict<any>): number
  if t.DiscrValue == u.DiscrValue
    return CompareByHiGroupName(t, u)
  elseif t.DiscrValue == NO_DISCR_VALUE
    return 1
  elseif u.DiscrValue == NO_DISCR_VALUE
    return -1
  else
    return CompareDistinct(t.DiscrValue, u.DiscrValue)
  endif
enddef

def LinkedGroupToString(t: dict<any>): string
  return printf("hi! link %s %s", t.HiGroupName, t.TargetGroup)
enddef

def AttributesToString(t: dict<any>, meta: dict<any>): list<string>
  var attributes = []

  # If the variant supports color attribute `key`, and if the highlight group
  # has a value for it, map the color and add it to the definition
  for key in ['Fg', 'Bg', 'Special']
    if !empty(meta[key]) && !empty(t[key])
      const colorName: string = t[key]
      attributes->add(meta[key] .. '=' .. meta.Colors[colorName])
    endif
  endfor

  # Do the same for the other (non-color) attributes (no mapping needed)
  for key in ['Style', 'Font', 'Start', 'Stop']
    if !empty(meta[key]) && !empty(t[key])
      attributes->add(meta[key] .. '=' .. t[key])
    endif
  endfor

  return attributes
enddef

def BaseGroupToString(t: dict<any>, meta: dict<any>, metaAlt: dict<any> = null_dict): string
  var hiGroupDef = ['hi', t.HiGroupName] + AttributesToString(t, meta)

  if metaAlt != null
    hiGroupDef += AttributesToString(t, metaAlt)
  endif

  return join(hiGroupDef, ' ')
enddef

def HiGroupToString(t: dict<any>, meta: dict<any>): string
  # Convert a higlight group tuple into a string.
  #
  # t       A tuple with enough information to generate a highlight group
  #         definition (for example, a tuple from Database.BaseGroup).
  # meta    Variant metadata from Database.GetVariantMetadata()
  if t->has_key('TargetGroup') && !empty(t.TargetGroup)
    return LinkedGroupToString(t)
  endif

  return BaseGroupToString(t, meta)
enddef

def GenerateDiscriminators(db: Database): list<string>
  const defs = db.Discriminator
    ->Select((t) => !empty(t.DiscrName))
    ->Sort(CompareByDiscrName)
    ->Transform((t) => printf("const %s = %s", t.DiscrName, t.Definition))

  return defs
enddef

def GenerateOverridingDefinitions(
    hiGroups: list<dict<any>>, meta: dict<any>
): list<string>
  # Generate overriding definition based on discriminators.
  #
  # hiGroups  A list of tuples sharing the same discriminator's name and
  #           containing enough information to generate a highlight group
  #           definition.
  # meta      Variant metadata from Database.GetVariantMetadata()
  if empty(hiGroups)
    return []
  endif

  const discrName = hiGroups[0].DiscrName
  var discrValue = hiGroups[0].DiscrValue
  var defs: list<string> = []

  defs->add(printf("if %s == %s", discrName, discrValue))

  for t in hiGroups
    if t.DiscrValue != discrValue
      discrValue = t.DiscrValue
      defs->add(printf("elseif %s == %s", discrName, discrValue))
    endif
    const overrideDef = HiGroupToString(t, meta)
    defs->add(overrideDef)
  endfor

  defs->add("endif")

  return defs
enddef

def StartColorscheme(meta: Metadata, background: string): list<string>
  if meta.IsLightAndDark()
    return ['', printf("if &background == '%s'", background)]
  endif

  return []
enddef

def EndColorscheme(meta: Metadata): list<string>
  if meta.IsLightAndDark()
    return ['endif']
  endif

  return []
enddef

def StartVariant(meta: dict<any>): list<string>
  const variant = meta.Variant

  if variant == 'gui'
    return ["if has('gui_running')"]
  endif

  return [printf('if str2nr(&t_Co) >= %d', meta.NumColors)]
enddef

def EndVariant(meta: dict<any>): list<string>
  return ['finish', 'endif']
enddef

# }}}

# Header {{{
def AddMeta(header: list<string>, text: string, value: string): list<string>
  if !empty(value)
    header->add(printf(text, value))
  endif

  return header
enddef

def AddList(header: list<string>, text: string, items: list<string>): list<string>
  if !empty(items)
    header->AddMeta(text, items[0])

    const n = len(items)
    const spaces = repeat(' ', len(text) - 3)
    var i = 1
    while i < n
      header->add(printf('#%s%s', spaces, items[i]))
      ++i
    endwhile
  endif

  return header
enddef

def Header(meta: Metadata): list<string>
  const license     = empty(meta.license) ? 'Vim License (see `:help license`)' : meta.license
  var   header      = ['vim9script', '']

  header->AddMeta('# Name:           %s', meta.fullname)
  header->AddMeta('# Version:        %s', meta.version)
  header->AddList('# Description:    %s', meta.description)
  header->AddList('# Author(s):      %s', meta.author)
  header->AddList('# Maintainers(s): %s', meta.maintainer)
  header->AddList('# URL(s):         %s', meta.url)
  header->AddMeta('# License:        %s', meta.license)
  header->AddMeta('# Last Change:    %s', strftime("%c"))
  header->add('')
  header->AddMeta('# Generated by Colortemplate v%s', VERSION)
  header->add('')
  header->add("import '../import/higroupgenerator.vim' as generator")

  if !meta.backgrounds.light
    header->add('set background=dark')->add('')
  elseif !meta.backgrounds.dark
    header->add('set background=light')->add('')
  endif

  header->add('hi clear')->add('')
  header->AddMeta("g:colors_name = '%s'", meta.shortname)
  header->AddMeta("g:terminal_ansi_colors = %s", string(meta.termcolors))
  header->add('')->add('const theme = generator.HiGroupGenerator.new()')

  return header
enddef
# }}}

# Main {{{
export def Generate(meta: Metadata, dbase: dict<Database>): list<string>
  var theme = Header(meta)

  for [bg, db_] in items(dbase)
    if !meta.HasBackground(bg)
      continue
    endif

    const db: Database = db_

    theme += StartColorscheme(meta, bg)
    theme += GenerateDiscriminators(db)
    theme->add('')

    # Define colors
    theme += db.Color->Transform(
      (t) => printf("theme.Color('%s', '%s', '%s', '%s')", t.ColorName, t.GUIValue, t.Base256Value, t.Base16Value)
    )
    theme->add('')

    const hiGroups = db.HiGroup->Sort(CompareByHiGroupName)

    for t in hiGroups
      const defGUI = db.GetDefaultDef(t.HiGroupName, 'gui')
      const def256 = db.GetDefaultDef(t.HiGroupName, '256')
      const def016 = db.GetDefaultDef(t.HiGroupName,  '16')

      if defGUI->has_key('TargetGroup') && !empty(defGUI.TargetGroup)
        theme->add(printf("theme.Link('%s', '%s')", defGUI.HiGroupName, defGUI.TargetGroup))
      else
        theme->add(printf("theme.Hi('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
          defGUI.HiGroupName,
          defGUI.Fg, defGUI.Bg, defGUI.Special, defGUI.Style,
          defGUI.Fg, defGUI.Bg, defGUI.Special, defGUI.Style,
          defGUI.Style
        ))
      endif
    endfor

    theme += EndColorscheme(meta)
  endfor

  return theme
enddef
# }}}
