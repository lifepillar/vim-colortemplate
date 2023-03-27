vim9script

import 'libtinytest.vim' as tt
import 'librelalg.vim' as ra
import 'libparser.vim' as parser
import '../../autoload/v3/parser.vim' as colortemplate_parser
import '../../autoload/v3/colorscheme.vim'

const Parse    = colortemplate_parser.Parse
const Result   = parser.Result
const Metadata = colorscheme.Metadata
const Database = colorscheme.Database


def Test_Parser_Background()
  const res = Parse("Background: dark")

  assert_equal(v:t_dict, type(res))
  assert_equal(['dark', 'light', 'meta', 'result'], sort(keys(res)))

  const result: Result   = res.result
  const meta:   Metadata = res.meta

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(meta.backgrounds.dark)
  assert_false(meta.backgrounds.light)
enddef

def Test_Parser_Variants()
  const res = Parse("Variants: 8")

  assert_equal(v:t_dict, type(res))
  assert_equal(['dark', 'light', 'meta', 'result'], sort(keys(res)))

  const result: Result   = res.result
  const meta:   Metadata = res.meta

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(index(meta.variants, '8') != -1)
enddef

def Test_Parser_NoDefaultLinkedGroup()
  const template =<< trim END
    Background: dark
    Variants:   256
    Define/256 -> Conditional
  END

  const res = Parse(join(template, "\n"))
  const result: Result = res.result

  assert_false(result.success)
  assert_match('must override an existing Highlight Group', result.label)
enddef

def Test_Parser_LinkedGroup()
  const template =<< trim END
    Background: dark
    Variants:   gui 256 16 8 0
    Define     -> Identifier
    Define/256 -> Conditional
  END

  const res = Parse(join(template, "\n"))
  const result: Result   = res.result
  const meta:   Metadata = res.meta
  const dbase:  Database = res.dark

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(meta.backgrounds.dark)
  assert_false(meta.backgrounds.light)
  assert_equal(['0', '16', '256', '8', 'gui'], meta.variants)

  const r = ra.Query(
    dbase.LinkedGroup
    ->ra.Select((t) => t.HiGroupName == 'Define')
  )

  assert_equal(1, len(r))
  assert_equal('Identifier', r[0]['TargetGroup'])

  const s = ra.Query(
    dbase.LinkedGroupOverride
    ->ra.Select((t) => t.HiGroupName == 'Define')
  )
  assert_equal(1, len(s))
  assert_equal('Conditional', s[0]['TargetGroup'])
  assert_equal('256',         s[0]['Variant'])
enddef

def Test_Parser_VariantDiscriminatorOverride()
  const template =<< trim END
    Background: dark
    Variants:   gui 256 8
    Color:      white #fafafa 231 White
    #const transp_bg = 0
    Normal white white
    Normal /256/8 +transp_bg 1 white none
  END
  const res = Parse(join(template, "\n"))
  const result: Result = res.result

  assert_equal('', result.label)
  assert_true(result.success)
enddef


def Test_Parser_DiscriminatorName()
  const template =<< trim END
  Background: dark
  Variants: gui 8
  Color: black  #394759  238  Black
  Color: white  #ebebeb  255  LightGrey
  #const foobar = get(g:, 'foobar', 0)
  Conceal black white
       /8 +foobar 1   white black reverse
  END
  const res = Parse(join(template, "\n"))
  const result: Result = res.result

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_Parser_MissingDefaultDef()
  const template =<< trim END
  Background: dark
  Variants: gui 8
  Color: black  #394759  238  Black
  Color: white  #ebebeb  255  LightGrey
  #const foobar = get(g:, 'foobar', 0)
  ; Missing default definition for Conceal
  Conceal/8 +foobar 1   white black reverse
  END

  const parserInput = join(template, "\n")
  const res = Parse(parserInput)
  const result: Result = res.result

  assert_equal(
    'Missing default definition for highlight group: Conceal',
    result.label
  )
  assert_false(result.success)
enddef

def Test_Parser_TranspBg()
  const template =<< trim END
    Variants: 256 8
    Background: light

    Color: black         #5f5f61     59           Black
    Color: white         #fafafa     231          White

    #const transp_bg = get(g:, 'wwdc17_transp_bg', 0)

    Normal black white
    Normal /256/8 +transp_bg 1 black white
  END

  const parserInput = join(template, "\n")
  const res = Parse(parserInput)
  const result: Result = res.result

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_Parser_GUIColor()
  const template =<< trim END
    Variants:   256 8
    Background: light

    Color: black  Black   0  Black
    Color: blue   Blue   12  Blue

    Normal black blue
  END

  const parserInput = join(template, "\n")
  const res = Parse(parserInput)
  const result: Result = res.result

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_Parser_VerbatimBlock()
  const template =<< trim END
  verbatim
    This
      is arbitrary
            text
  endverbatim
  END

  const parserInput = join(template, "\n")
  const res = Parse(parserInput)
  const result: Result = res.result
  const meta: Metadata = res.meta

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(
    "This\n    is arbitrary\n          text\n", meta.verbatimtext
  )
enddef

tt.Run('_Parser_')
