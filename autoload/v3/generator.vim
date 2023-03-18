vim9script

import './colorscheme.vim'
import './version.vim'
import 'librelalg.vim' as ra

# Aliases {{{
const EquiJoin       = ra.EquiJoin
const LeftEquiJoin   = ra.LeftEquiJoin
const PartitionBy    = ra.PartitionBy
const Select         = ra.Select
const Sort           = ra.Sort
const Transform      = ra.Transform
# }}}

const VERSION        = version.VERSION
const NO_DISCR_VALUE = colorscheme.DEFAULT_DISCR_VALUE
const Database       = colorscheme.Database
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
  elseif t.DiscrName == 't_Co'
    return -1
  elseif u.DiscrName == 't_Co'
    return 1
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

def AttributesToString(t: dict<any>, meta: dict<any>, termgui: bool): list<string>
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
  if !empty(meta.Style) && !empty(t.Style)
    attributes->add(meta.Style .. '=' .. t.Style)

    if termgui
      attributes->add('cterm=' .. t.Style)
    endif
  endif

  for key in ['Font', 'Start', 'Stop']
    if !empty(meta[key]) && !empty(t[key])
      attributes->add(meta[key] .. '=' .. t[key])
    endif
  endfor

  return attributes
enddef

def BaseGroupToString(t: dict<any>, meta: dict<any>, termgui: bool = false): string
  var hiGroupDef = ['hi', t.HiGroupName] + AttributesToString(t, meta, termgui)

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
    ->Select((t) => !empty(t.DiscrName) && t.DiscrName != 't_Co')
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

  return [printf('if t_Co >= %d', meta.NumColors)]
enddef

def EndVariant(meta: dict<any>): list<string>
  const variant = meta.Variant

  if variant == 'gui'
    return ['endif']
  endif

  return ['finish', 'endif']
enddef
# }}}

# Integrity checks {{{
export def CheckMetadata(meta: Metadata)
  if empty(meta.fullname)
    throw 'Please define the full name of the color scheme'
  endif

  if empty(meta.shortname)
    throw 'Please define the short name of the color scheme'
  endif

  if empty(meta.author)
    throw 'Please define the author of the color scheme'
  endif
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
  header->AddMeta('# Last Updated:   %s', strftime("%c"))
  header->add('')
  header->AddMeta('# Generated by Colortemplate v%s', VERSION)
  header->add('')

  if !meta.backgrounds.light
    header->add('set background=dark')->add('')
  elseif !meta.backgrounds.dark
    header->add('set background=light')->add('')
  endif

  header->add('hi clear')->add('')
  header->AddMeta("g:colors_name = '%s'", meta.shortname)
  header->AddMeta("g:terminal_ansi_colors = %s", string(meta.termcolors))
  header->add('')
  header->add("const t_Co = exists('&t_Co') && !has('gui_running') ? (str2nr(&t_Co) ?? 0) : -1")

  return header
enddef
# }}}

# Main {{{
def GenerateVariantDefinitions(
    hiGroups:    list<dict<any>>,
    variantMeta: dict<any>,
    db:          Database,
    discrNames:  list<string>,
    overrides:   dict<list<dict<any>>>
    ): list<string>
  const variant = variantMeta.Variant
  var defaultDefs: list<dict<any>>

  if variant == 'gui' # Generate only if overriding default
    defaultDefs = db.HiGroupOverride
      ->Select((t) => t.DiscrValue == NO_DISCR_VALUE && t.Variant == variant)
      ->LeftEquiJoin(db.LinkedGroupOverride,
        ['HiGroupName', 'Variant', 'DiscrValue'],
        ['HiGroupName', 'Variant', 'DiscrValue'], LINK_FILLER
      )
      ->LeftEquiJoin(db.BaseGroupOverride,
        ['HiGroupName', 'Variant', 'DiscrValue'],
        ['HiGroupName', 'Variant', 'DiscrValue'], BASE_FILLER
      )
      ->Sort(CompareByHiGroupName)
  else
    defaultDefs = hiGroups->Transform((t) => db.GetDefaultDef(t.HiGroupName, variant))
    # Remove default linked groups because they are added globally
    filter(defaultDefs, (_, t) => t->has_key('Fg') || t->has_key('Variant'))
  endif

  var defs: list<string> = defaultDefs->mapnew((_, t) => HiGroupToString(t, variantMeta))

  # Generate discriminator-based definitions
  for discrName in discrNames
    const variantOverrides = overrides[discrName]
      ->Select((t) => t.Variant == variant)
      ->LeftEquiJoin(db.LinkedGroupOverride,
        ['HiGroupName', 'Variant', 'DiscrValue'],
        ['HiGroupName', 'Variant', 'DiscrValue'], LINK_FILLER
      )
      ->LeftEquiJoin(db.BaseGroupOverride,
        ['HiGroupName', 'Variant', 'DiscrValue'],
        ['HiGroupName', 'Variant', 'DiscrValue'], BASE_FILLER
      )
      ->Sort(CompareByDiscrValueAndHiGroupName)

    defs += GenerateOverridingDefinitions(variantOverrides, variantMeta)
  endfor

  return defs
enddef

export def Generate(meta: Metadata, dbase: dict<Database>): list<string>
  CheckMetadata(meta)

  var theme = Header(meta)

  for [bg, db_] in items(dbase)
    if !meta.HasBackground(bg)
      continue
    endif

    const db: Database = db_
    const metaGUI      = db.GetVariantMetadata('gui')
    const hiGroups     = db.HiGroup    ->Sort(CompareByHiGroupName)
    const globalLinked = db.LinkedGroup->Sort(CompareByHiGroupName)
    const globalBaseGr = db.BaseGroup  ->Sort(CompareByHiGroupName)
    const overrides    = db.HiGroupOverride
      ->Select((t) => t.DiscrValue != NO_DISCR_VALUE)
      ->EquiJoin(db.HiGroup, ['HiGroupName'], ['HiGroupName'])
      ->PartitionBy('DiscrName')
    const discrNames   = sort(keys(overrides))

    theme += StartColorscheme(meta, bg)

    theme += GenerateDiscriminators(db)
    theme->add('')
    # Add global default definitions (GUI+termgui)
    theme += globalLinked->Transform((t) => LinkedGroupToString(t))
    theme->add('')
    theme += globalBaseGr->Transform((t) => BaseGroupToString(t, metaGUI, true))

    # Add variant-specific definitions and overrides, in the specified order
    for variant in ['gui', '256', '88', '16', '8', '0']
      if index(meta.variants, variant) == -1
        continue
      endif

      const variantMeta = db.GetVariantMetadata(variant)

      theme->add('')
      theme += StartVariant(variantMeta)
      theme += GenerateVariantDefinitions(hiGroups, variantMeta, db, discrNames, overrides)
      theme += EndVariant(variantMeta)
    endfor

    theme += EndColorscheme(meta)
  endfor

  return theme
enddef
# }}}

# vim: foldmethod=marker nowrap et ts=2 sw=2
