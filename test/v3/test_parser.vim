vim9script

import 'libtinytest.vim' as tt
import 'librelalg.vim' as ra
import 'libparser.vim'
import '../../autoload/v3/parser.vim' as colortemplateParser
import '../../autoload/v3/colorscheme.vim' as themes

const Parse       = colortemplateParser.Parse
const Result      = libparser.Result
const Colorscheme = themes.Colorscheme


def Test_PS_Background()
  const [result: Result, theme: Colorscheme] = Parse("Background: dark")

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(theme.backgrounds.dark)
  assert_false(theme.backgrounds.light)
enddef

def Test_PS_Variants()
  const [result: Result, theme: Colorscheme] = Parse("Variants: 8")

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(['8', 'gui'], theme.variants)
enddef

def Test_PS_NoDefaultLinkedGroup()
  const template =<< trim END
    Background: dark
    Variants:   256
    Define/256 -> Conditional
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_false(result.success)
  assert_match('must override an existing Highlight Group', result.label)
enddef

def Test_PS_LinkedGroup()
  const template =<< trim END
    Background: dark
    Variants:   gui 256 16 8 0
    Define     -> Identifier
    Define/256 -> Conditional
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(theme.backgrounds.dark)
  assert_false(theme.backgrounds.light)
  assert_equal(['0', '16', '256', '8', 'gui'], theme.variants)

  const db = theme.dark
  const r = ra.Query(
    db.LinkedGroup
    ->ra.Select((t) => t.HiGroupName == 'Define')
  )

  assert_equal(1, len(r))
  assert_equal('Identifier', r[0]['TargetGroup'])

  const s = ra.Query(
    db.LinkedGroupOverride
    ->ra.Select((t) => t.HiGroupName == 'Define')
  )
  assert_equal(1, len(s))
  assert_equal('Conditional', s[0]['TargetGroup'])
  assert_equal('256',         s[0]['Variant'])
enddef

def Test_PS_VariantDiscriminatorOverride()
  const template =<< trim END
    Background: dark
    Variants:   gui 256 8
    Color:      white #fafafa 231 White
    #const transp_bg = 0
    Normal white white
    Normal /256/8 +transp_bg 1 white none
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef


def Test_PS_DiscriminatorName()
  const template =<< trim END
    Background: dark
    Variants: gui 8
    Color: black  #394759  238  Black
    Color: white  #ebebeb  255  LightGrey
    #const foobar = get(g:, 'foobar', 0)
    Conceal black white
         /8 +foobar 1   white black reverse
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_MissingDefaultDef()
  const template =<< trim END
    Background: dark
    Variants: gui 8
    Color: black  #394759  238  Black
    Color: white  #ebebeb  255  LightGrey
    #const foobar = get(g:, 'foobar', 0)
    ; Missing default definition for Conceal
    Conceal/8 +foobar 1   white black reverse
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_match(
    "Missing default definition for highlight group 'Conceal'",
    result.label
  )
  assert_false(result.success)
enddef

def Test_PS_TranspBg()
  const template =<< trim END
    Variants: 256 8
    Background: light

    Color: black         #5f5f61     59           Black
    Color: white         #fafafa     231          White

    #const transp_bg = get(g:, 'wwdc17_transp_bg', 0)

    Normal black white
    Normal /256/8 +transp_bg 1 black white
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_GUIColor()
  const template =<< trim END
    Background: light

    Color: black  Black  16  Black
    Color: blue   Blue    ~  Blue

    Normal black blue
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

# A verbatim block before a background directive is stored as theme metadata
def Test_PS_VerbatimMetadata()
  const template =<< trim END
    verbatim
      Hi!
    endverbatim
  END
  const expected = ['  Hi!']
  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, theme.verbatimtext)
enddef

# A verbatim block after a background directive is stored as database metadata
def Test_PS_VerbatimDatabase()
  const template =<< trim END
    Background: dark
    verbatim
      Hi!
    endverbatim
  END
  const expected = ['  Hi!']
  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal([], theme.verbatimtext)
  assert_equal(['  Hi!'], theme.dark.verbatimtext)
  assert_equal([], theme.light.verbatimtext)
enddef

# Verbatim blocks are interpolated
def Test_PS_VerbatimBlockInterpolation()
  const template =<< trim END
    Author: myself
    Short name: xyz
    Version: v1.2.3
    Full name: XYZ
    verbatim

    This is
      arbitrary text
    By @author1
    endverbatim

    Background: light
    Variants: gui
    Color: black #333333 17 Black

    verbatim
    Color=@guiblack Approx=@256black/@16black
      Shortname: @shortname
      Fullname:  @fullname @version
    The background is @background
    endverbatim
  END

  const expected1 =<< trim END
    This is
      arbitrary text
    By myself
  END

  const expected2 =<< trim END
    Color=#333333 Approx=17/Black
      Shortname: xyz
      Fullname:  XYZ v1.2.3
    The background is light
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected1, theme.verbatimtext)
  assert_equal(expected2, theme.light.verbatimtext)
enddef

def Test_PS_VerbatimDateVersion()
  const template =<< trim END
    verbatim
      Today is @date
      And this is Vim v@vimversion.0
    endverbatim
  END

  const expected = [
    printf("  Today is %s", strftime("%Y %b %d")),
    printf("  And this is Vim v%d.0", v:version / 100),
  ]

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, theme.verbatimtext)
enddef

# Multiple verbatim blocks are concatenated
def Test_PS_MultipleVerbatimBlocks()
  const template =<< trim END
  Background: dark
  Author:     Nemo
  verbatim
  @background
  endverbatim

  verbatim @author endverbatim
  END

  const expected = ['dark', ' Nemo ']
  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, theme.dark.verbatimtext)
enddef

def Test_PS_VerbatimIdentifierWithNumbers()
  const template =<< trim END
    Background: dark
    Color: base0    #839496   246     12
    Color: base03   #002b36   235      8
    verbatim
      @256base03
      @256base0
    endverbatim
  END
  const expected = ['  235', '  246']
  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, theme.dark.verbatimtext)
enddef

def Test_PS_auxfile()
  const template =<< trim END
    auxfile foo/bar
    abc '▇' def
    endauxfile
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal({'foo/bar': ["abc '▇' def"]}, theme.auxfiles)
enddef

def Test_PS_tilde()
  const template =<< trim END
  Background: dark
  Color: black #333334 ~ Black
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_Rgb()
  const template =<< trim END
  Background: dark
  Color: black rgb(0, 255, 127) ~ Green
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_MinimalColorDefinition()
  const template =<< trim END
  Background: dark
  Color: black #000000 ~
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_OptionalBase16()
  const template =<< trim END
  Background: dark
  Color: bg1             #ffffff     237 DarkGray
  Color: bg2             #fafafa     239
  Color: bg3             #343433      59
  END

  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_SingleDefMultipleVariants()
  const template =<< trim END
    Background: dark
    #const italic = get(g:, 'italic', 1)
    Color: grey            rgb(146, 131, 116)    102 DarkGray
    Color: fg4             rgb(168, 153, 132)    137 Gray
    Comment                              grey   none          italic
                 /gui/256/16+italic 0    grey   none
                 /8                      fg4    none          italic
                 /8         +italic 0    fg4    none
  END
  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_ConditionalDef()
  const template =<< trim END
    Background: dark
    Color: red #ff0000 ~
    #const foo = get(g:, 'foo', false)
    baldBison -> omit

    baldBison/gui+foo 1  none   none s=red   undercurl
             /256+foo 1  none   none s=red   underline
  END
  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_Lookahead()
  const template =<< trim END
    Background: dark
    Color: red #ff0000 ~

    gladCrane red none ; a : here should not be picked up by lookahed
  END
  const [result: Result, _] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
enddef

def Test_PS_UnicodeMetadata()
  const template =<< trim END
    Full name: àèì ėęčž 🚀 Scheme®
    Background: dark
    helpVim   -> Title
  END
  const [result: Result, theme: Colorscheme] = Parse(join(template, "\n"))

  assert_true(result.success)
  assert_equal('àèì ėęčž 🚀 Scheme®', theme.fullname)
  assert_equal('', result.label)
enddef

tt.Run('_PS_')

# vim: tw=100
