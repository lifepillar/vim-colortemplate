vim9script

import 'libtinytest.vim'                         as tt
import 'librelalg.vim'                           as ra
import '../import/colortemplate/parser/v3.vim'   as parser

const Parse = parser.Parse


def Test_Parser_EmptyDocument()
  var [result, colorscheme] = Parse('')

  assert_equal('', result.label)
  assert_true(result.success)

  assert_false(colorscheme.HasBackground('dark'))
  assert_false(colorscheme.HasBackground('light'))
enddef

def Test_Parser_Background()
  var [result, colorscheme] = Parse("Background: dark")

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(colorscheme.HasBackground('dark'))
  assert_false(colorscheme.HasBackground('light'))
  assert_false(colorscheme.IsLightAndDark())

  [result, colorscheme] = Parse("Background: dark Background: light")

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(colorscheme.HasBackground('dark'))
  assert_true(colorscheme.HasBackground('light'))
  assert_true(colorscheme.IsLightAndDark())
enddef

def Test_Parser_Environments()
  var [result, colorscheme] = Parse("Environments: 8")

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(['8'], colorscheme.environments)

  [result, colorscheme] = Parse("Environments:8 gui   16 256  88 0")

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(['0', '16', '256', '8', '88', 'gui'], colorscheme.environments)
enddef

def Test_Parser_UnicodeMetadata()
  var fullname = 'àèì ėęčž 🚀 Scheme®'
  var template = $'Full name: {fullname}'
  var [result, colorscheme] = Parse(template)

  assert_true(result.success)
  assert_equal('', result.label)
  assert_equal(fullname, colorscheme.fullname)
enddef

def Test_Parser_ColoschemeNameWithHyphens()
  var template =<< trim END
    Full  name: Base16-3024
    Short name: base16-3024
    Background: dark
  END
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_true(result.success)
  assert_equal('Base16-3024', colorscheme.fullname)
  assert_equal('base16-3024', colorscheme.shortname)
  assert_equal('', result.label)
enddef

def Test_Parser_InvalidShortName()
  var templates = [
    ['Short name: invalid-name$'],
    ['Short name: short name with spaces is invalid']
  ]

  for template in templates
    var [result, _] = Parse(join(template, "\n"))

    assert_false(result.success, $'Template should have failed: {template}')
    assert_equal('Unexpected token', result.label)
  endfor
enddef

def Test_Parser_MinimalColorDefinition()
  var template =<< trim END
  Background: dark
  Color: black #000000 ~
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  assert_true(colorscheme.HasBackground('dark'))
  assert_false(colorscheme.HasBackground('light'))
  assert_false(colorscheme.IsLightAndDark())
  assert_equal('#000000', colorscheme.dark.Color.Lookup(['Name'], ['black']).GUI)
  assert_equal('16',      colorscheme.dark.Color.Lookup(['Name'], ['black']).Base256)
  assert_equal('#000000', colorscheme.dark.Color.Lookup(['Name'], ['black']).Base256Hex)
  assert_equal('NONE',    colorscheme.dark.Color.Lookup(['Name'], ['black']).Base16)
enddef

def Test_Parser_GUIColorName()
  var template =<< trim END
    Background: dark

    Color: myblack  "Black"  16  Black
    Color: myblue   "Blue"    ~  Blue

    Normal myblack myblue
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal('black',   colorscheme.dark.Color.Lookup(['Name'], ['myblack']).GUI)
  assert_equal('16',      colorscheme.dark.Color.Lookup(['Name'], ['myblack']).Base256)
  assert_equal('#000000', colorscheme.dark.Color.Lookup(['Name'], ['myblack']).Base256Hex)
  assert_equal('Black',   colorscheme.dark.Color.Lookup(['Name'], ['myblack']).Base16)
  assert_equal('blue',    colorscheme.dark.Color.Lookup(['Name'], ['myblue']).GUI)
  assert_equal('21',      colorscheme.dark.Color.Lookup(['Name'], ['myblue']).Base256)
  assert_equal('#0000ff', colorscheme.dark.Color.Lookup(['Name'], ['myblue']).Base256Hex)
  assert_equal('Blue',    colorscheme.dark.Color.Lookup(['Name'], ['myblue']).Base16)
enddef

def Test_Parser_RgbColorDefinition()
  var template =<< trim END
  Background: light
  Color: my_green rgb(0,255, 127) ~ Green
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  assert_false(colorscheme.HasBackground('dark'))
  assert_true(colorscheme.HasBackground('light'))
  assert_false(colorscheme.IsLightAndDark())
  assert_equal('#00ff7f', colorscheme.light.Color.Lookup(['Name'], ['my_green']).GUI)
  assert_equal('48',      colorscheme.light.Color.Lookup(['Name'], ['my_green']).Base256)
  assert_equal('#00ff87', colorscheme.light.Color.Lookup(['Name'], ['my_green']).Base256Hex)
  assert_equal('Green',   colorscheme.light.Color.Lookup(['Name'], ['my_green']).Base16)
enddef

def Test_Parser_tilde()
  var template =<< trim END
  Background: dark
  Color: my_black #333334 ~ Black
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal('#333334', colorscheme.dark.Color.Lookup(['Name'], ['my_black']).GUI)
  assert_equal('236',     colorscheme.dark.Color.Lookup(['Name'], ['my_black']).Base256)
  assert_equal('#303030', colorscheme.dark.Color.Lookup(['Name'], ['my_black']).Base256Hex)
  assert_equal('Black',   colorscheme.dark.Color.Lookup(['Name'], ['my_black']).Base16)
enddef

def Test_Parser_Base256Color0_15()
  var template =<< trim END
    Full name: C15
    Short name: c15
    Background: dark
    Color: C0  #000000 0  0
    Color: C15 #000000 15 15
  END
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_true(result.success)
  assert_equal('C15', colorscheme.fullname)
  assert_equal('c15', colorscheme.shortname)
  assert_equal('', result.label)

  var expected = [
    {Name: 'C0',  Base256:  '0'},
    {Name: 'C15', Base256: '15'},
  ]
  var db = colorscheme.dark

  for i in ['0', '15']
    var r = ra.Query(ra.Select(db.Color, (t) => t.Base256 == i))

    assert_equal(1, len(r))
    assert_equal($'C{i}', r[0].Name)
  endfor
enddef

def Test_Parser_OutOfRangeBase256Color()
  var template = ['Background:light', 'Color:white #ffffff 256 White']
  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success, $'Template should have failed: {template}')
  assert_true(result.label =~ 'color index out of range')
enddef

def Test_Parser_OptionalBase16()
  var template =<< trim END
  Background: dark
  Color: bg1             #ffffff     237 DarkGray
  Color: bg2             #fafafa     239
  Color: bg3             #343433      59
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  assert_equal('#ffffff',  colorscheme.dark.Color.Lookup(['Name'], ['bg1']).GUI)
  assert_equal('237',      colorscheme.dark.Color.Lookup(['Name'], ['bg1']).Base256)
  assert_equal('#3a3a3a',  colorscheme.dark.Color.Lookup(['Name'], ['bg1']).Base256Hex)
  assert_equal('DarkGray', colorscheme.dark.Color.Lookup(['Name'], ['bg1']).Base16)

  assert_equal('#fafafa',  colorscheme.dark.Color.Lookup(['Name'], ['bg2']).GUI)
  assert_equal('239',      colorscheme.dark.Color.Lookup(['Name'], ['bg2']).Base256)
  assert_equal('#4e4e4e',  colorscheme.dark.Color.Lookup(['Name'], ['bg2']).Base256Hex)
  assert_equal('NONE',     colorscheme.dark.Color.Lookup(['Name'], ['bg2']).Base16)

  assert_equal('#343433',  colorscheme.dark.Color.Lookup(['Name'], ['bg3']).GUI)
  assert_equal('59',       colorscheme.dark.Color.Lookup(['Name'], ['bg3']).Base256)
  assert_equal('#5f5f5f',  colorscheme.dark.Color.Lookup(['Name'], ['bg3']).Base256Hex)
  assert_equal('NONE',     colorscheme.dark.Color.Lookup(['Name'], ['bg3']).Base16)
enddef

def Test_Parser_ColorCannotBeRedefined()
  var template =<< trim END
  Options: creator=false timestamp=false backend=viml
  Environments: gui 256
  Full name:Test 35
  Short name:test35
  Author:y
  Maintainer:w
  Background:dark
  Color:black rgb(0,0,0) 16 Black
  Color:white #ffffff 255 White
  Color:black #eeeeee 230 White  ; ERROR: cannot redefine color
  Normal white black
  ; vim: ft=colortemplate
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success)
  assert_true(result.label =~ 'Uniqueness failed.*Duplicate key')
enddef

def Test_Parser_ColorCannotBeDefinedBeforeBackground()
  var template =<< trim END
  Environments: gui 256
  Full name:Test 36
  Short name:test36
  Author:y
  Maintainer:w
  Color:white #ffffff 255 White ; Color defined before background
  Background:dark
  Color:black rgb(0,0,0) 16 Black
  Normal white black
  Background:light
  Normal white white
  ColorColumn white black ; black is undefined here
  ; vim: ft=colortemplate
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success)
  assert_true(result.label =~ "Missing 'Background' directive")
enddef

def Test_Parser_ReservedColorNames()
  var templates = [
  ['Background: dark', 'Color: none rgb(0,0,0) 16 Black'],
  ['Background: dark', 'Color:   fg rgb(0,0,0) 16 Black'],
  ['Background: dark', 'Color:   bg rgb(0,0,0) 16 Black'],
  ]

  for template in templates
    var [result, _] = Parse(join(template, "\n"))

    assert_false(result.success, $'Template should have failed: {template}')
    assert_true(result.label =~ "Uniqueness failed")
  endfor
enddef

def Test_Parser_InvalidStyleAttribute()
  var template =<< trim END
  Background:dark
  Color:black rgb(0,0,0) 16 Black
  Color:white #ffffff 255 White
  Error white black idontexist
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success, $'Template should have failed: {template}')
  assert_equal('Unexpected token', result.label)
enddef

def Test_Parser_InvalidEnvironment()
  var template =<< trim END
  Environments: gui 256
  Full name:Test 6
  Short name:test6
  Author:y
  Maintainer:w
  Background:dark
  Color:black rgb(0,0,0) 16 Black
  Color:white #ffffff 255 White
  Normal white black/white
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success, $'Template should have failed: {template}')
  assert_match('Expected an environment value', result.label)
enddef

def Test_Parser_Lookahead()
  var template =<< trim END
    Background: dark
    Color: red #ff0000 ~

    gladCrane red none ; a : here should not be picked up by lookahed
  END
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  var t0 = colorscheme.dark.BaseGroup.Lookup(['HiGroup', 'Condition'], ['gladCrane', 0])

  assert_true(t0 isnot ra.KEY_NOT_FOUND, '01')
  assert_equal('red',  t0.Fg)
  assert_equal('none', t0.Bg)
  assert_equal('none', t0.Special)
  assert_equal('NONE', t0.Style)
enddef

def Test_Parser_HiGroupDefWithDiscr()
  var template =<< trim END
  Background:   dark
  Environments: gui 256
  Color:        black #333333 231 black
  Color:        white #fafafa 251 white

  #const foobar = "X"
  Comment+foobar "X" white black ; Discriminator without environment
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success)
  assert_equal('Unexpected token', result.label)
enddef

def Test_Parser_HiGroupDef()
  var template =<< trim END
  Background:   dark
  Environments: gui 256 16
  Color:        black #333333 231 black
  Color:        white #fafafa 251 white

  Normal white black
  Comment black white reverse
     /256 white black s=white bold
  #const foobar = "X"
  Comment/gui+foobar "X" white white
  Comment/16 +foobar "Y" -> NonText
  END

  var [_, colorscheme] = Parse(join(template, "\n"))
  var db = colorscheme.dark
  var t0 = db.HiGroupDef('Normal',  'default')
  var t1 = db.HiGroupDef('Comment', 'default')
  var t2 = db.HiGroupDef('Comment', '256')
  var t3 = db.HiGroupDef('Comment', 'default', 'foobar', '"X"')
  var t4 = db.HiGroupDef('Comment', 'default', 'foobar', '"Y"')
  var t5 = db.HiGroupDef('Comment', 'gui',     'foobar', '"X"')
  var t6 = db.HiGroupDef('Comment', '16',      'foobar', '"Y"')

  assert_false(empty(t0), 't0 should not be empty')
  assert_equal('Normal', t0.HiGroup)
  assert_equal('black',  t0.Bg)
  assert_equal('white',  t0.Fg)
  assert_equal('none',   t0.Special)
  assert_equal('NONE',   t0.Style)

  assert_false(empty(t1), 't1 should not be empty')
  assert_equal('Comment', t1.HiGroup)
  assert_equal('white',   t1.Bg)
  assert_equal('black',   t1.Fg)
  assert_equal('none',    t1.Special)
  assert_equal('reverse', t1.Style)

  assert_false(empty(t2), 't2 should not be empty')
  assert_equal('Comment', t2.HiGroup)
  assert_equal('black',   t2.Bg)
  assert_equal('white',   t2.Fg)
  assert_equal('white',   t2.Special)
  assert_equal('bold',    t2.Style)

  assert_true(empty(t3), 't3 should be empty')
  assert_true(empty(t4), 't4 should be empty')

  assert_false(empty(t5), 't5 should not be empty')
  assert_equal('Comment', t5.HiGroup)
  assert_equal('white',   t5.Bg)
  assert_equal('white',   t5.Fg)
  assert_equal('none',    t5.Special)
  assert_equal('NONE',    t5.Style)

  assert_false(empty(t6), 't6 should not be empty')
  assert_equal('Comment', t6.HiGroup)
  assert_equal('NonText', t6.TargetGroup)
enddef

def Test_Parser_SingleDefMultipleVariantsCS()
  var template =<< trim END
    Background: dark
    #const italic = get(g:, 'italic', 1)
    Color: grey            rgb(146, 131, 116)    102 DarkGray
    Color: fg4             rgb(168, 153, 132)    137 Gray
    Comment                              grey   none          italic
                 /gui/256   +italic 0    grey   none
                 /8                      fg4    grey          italic
                 /8         +italic 0    omit   omit s=omit
  END

  var [_, colorscheme] = Parse(join(template, "\n"))
  var db = colorscheme.dark
  var t0 = db.HiGroupDef('Comment', 'default')
  var t1 = db.HiGroupDef('Comment', 'gui', 'italic', '0')
  var t2 = db.HiGroupDef('Comment', '256')
  var t3 = db.HiGroupDef('Comment', '256', 'italic', '0')
  var t4 = db.HiGroupDef('Comment', '8')
  var t5 = db.HiGroupDef('Comment', '8', 'italic', '0')

  assert_false(empty(t0), 't0 should not be empty')
  assert_equal('Comment', t0.HiGroup)
  assert_equal('grey',    t0.Fg)
  assert_equal('none',    t0.Bg)
  assert_equal('none',    t0.Special)
  assert_equal('italic',  t0.Style)

  assert_false(empty(t1), 't1 should not be empty')
  assert_equal('Comment', t1.HiGroup)
  assert_equal('grey',    t1.Fg)
  assert_equal('none',    t1.Bg)
  assert_equal('none',    t1.Special)
  assert_equal('NONE',    t1.Style)

  assert_true(empty(t2), 't2 should  be empty')

  assert_false(empty(t3), 't3 should not be empty')
  assert_equal('Comment', t3.HiGroup)
  assert_equal('grey',    t3.Fg)
  assert_equal('none',    t3.Bg)
  assert_equal('none',    t3.Special)
  assert_equal('NONE',    t3.Style)

  assert_false(empty(t4), 't4 should not be empty')
  assert_equal('Comment', t3.HiGroup)
  assert_equal('Comment', t4.HiGroup)
  assert_equal('fg4',     t4.Fg)
  assert_equal('grey',    t4.Bg)
  assert_equal('none',    t4.Special)
  assert_equal('italic',  t4.Style)

  assert_false(empty(t5), 't5 should not be empty')
  assert_equal('Comment', t5.HiGroup)
  assert_equal('',        t5.Fg)
  assert_equal('',        t5.Bg)
  assert_equal('',        t5.Special)
  assert_equal('NONE',    t5.Style)
enddef

def Test_Parser_LinkedGroup()
  var template =<< trim END
    Background: dark
    Environments: gui 256 16 8 0
    Define     -> Identifier
    Define/256 -> Conditional
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_true(colorscheme.HasBackground('dark'))
  assert_false(colorscheme.HasBackground('light'))
  assert_equal(['0', '16', '256', '8', 'gui'], colorscheme.environments)

  var db = colorscheme.dark
  var r0 = ra.Query(
    ra.EquiJoin(db.LinkedGroup, db.Condition, {on: 'Condition'})
  )

  var r1  = ra.Query(r0->ra.Select((t) => t.HiGroup == 'Define' && t.Environment == 'default'))

  assert_equal(1, len(r1))
  assert_equal('Identifier', r1[0]['TargetGroup'])

  var r2  = ra.Query(r0->ra.Select((t) => t.HiGroup == 'Define' && t.Environment == '256'))

  assert_equal(1, len(r2))
  assert_equal('Conditional', r2[0]['TargetGroup'])
  assert_equal('256',         r2[0]['Environment'])
enddef

def Test_Parser_NoDefaultLinkedGroup()
  var template =<< trim END
    Background: dark
    Define/256 -> Conditional
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_true(result.success)

  var db = colorscheme.dark
  var r0 = ra.Query(
    ra.EquiJoin(db.LinkedGroup, db.Condition, {on: 'Condition'})
  )

  assert_equal(1, len(r0))
  assert_equal('Conditional', r0[0]['TargetGroup'])
  assert_equal('256', r0[0]['Environment'])
  assert_equal('', r0[0]['DiscrName'])
  assert_equal('', r0[0]['DiscrValue'])
enddef

def Test_Parser_InconsistentSpelling()
  var template =<< trim END
  Background: dark
  Color: white #ffffff ~
  StatusLineTerm white white
  StatuslineTerm/256 white white ; Spelled differently
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success, $'Template should have failed: {template}')
  assert_match('Inconsistent spelling', result.label)
enddef

def Test_Parser_LinkedGroupExtraToken()
  var template =<< trim END
  Environments: gui 256
  Full name:Test 75
  Short name:test75
  Author:y
  Background:dark
  Color:white #ffffff 231 15
  Normal white white
  ; The following should raise an error (link with multiple tokens):
  ; See https://github.com/lifepillar/vim-colortemplate/issues/29
  Cursor -> x y
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success, $'Template should have failed: {template}')
  assert_match('Unexpected token', result.label)
enddef

def Test_Parser_DiscriminatorName()
  var template =<< trim END
    Background: dark
    Color: black  #394759  238  Black
    Color: white  #ebebeb  255  LightGrey
    #const foobar = get(g:, 'foobar', 0)
    Conceal black white
         /8 +foobar 1   white black reverse
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  var db = colorscheme.dark
  var t0 = db.Discriminator.Lookup(['DiscrName'], ['foobar'])

  assert_equal("get(g:, 'foobar', 0)", t0.Definition)

  var r0 = ra.Query(
    ra.EquiJoin(db.BaseGroup, db.Condition, {on: 'Condition'})
  )
  var r1 = ra.Query(ra.Select(r0, (t) => t.Environment == 'default'))
  var r2 = ra.Query(ra.Select(r0, (t) => t.Environment == '8'))

  assert_equal(2, len(r0))
  assert_equal(1, len(r1))
  assert_equal(1, len(r2))
  assert_equal('black', r1[0]['Fg'])
  assert_equal('white', r1[0]['Bg'])
  assert_equal('', r1[0]['DiscrName'])
  assert_equal('', r1[0]['DiscrValue'])
  assert_equal('white', r2[0]['Fg'])
  assert_equal('black', r2[0]['Bg'])
  assert_equal('foobar', r2[0]['DiscrName'])
  assert_equal('1', r2[0]['DiscrValue'])
enddef

def Test_Parser_VariantDiscriminatorOverride()
  var template =<< trim END
    Background: dark
    Color:      white #fafafa 231 White
    #const transp_bg = 0
    Normal white white
    Normal /256/8 +transp_bg 1 white none
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  var db = colorscheme.dark
  var r0 = ra.Query(
    ra.EquiJoin(db.BaseGroup, db.Condition, {on: 'Condition'})
  )
  assert_equal(3, len(r0))

  var r1 = ra.Query(ra.Select(r0, (t) => t.Environment == 'default'))
  var r2 = ra.Query(ra.Select(r0, (t) => t.Environment == '256'))
  var r3 = ra.Query(ra.Select(r0, (t) => t.Environment == '8'))

  assert_equal(1, len(r1))
  assert_equal(1, len(r2))
  assert_equal(1, len(r3))
  assert_equal('white',     r1[0]['Fg'])
  assert_equal('white',     r1[0]['Bg'])
  assert_equal('white',     r2[0]['Fg'])
  assert_equal('none',      r2[0]['Bg'])
  assert_equal('transp_bg', r2[0]['DiscrName'])
  assert_equal('1',         r2[0]['DiscrValue'])
  assert_equal('white',     r3[0]['Fg'])
  assert_equal('none',      r3[0]['Bg'])
  assert_equal('transp_bg', r3[0]['DiscrName'])
  assert_equal('1',         r3[0]['DiscrValue'])
enddef

def Test_Parser_TranspBg()
  var template =<< trim END
    Environments: 256 8
    Background: light

    Color: black         #5f5f61     59           Black
    Color: white         #fafafa     231          White

    #const transp_bg = get(g:, 'wwdc17_transp_bg', 0)

    Normal black white
    Normal /256/8 +transp_bg 1 black white
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(['256', '8'], colorscheme.environments)

  var db = colorscheme.light
  var r0 = ra.Query(
    ra.EquiJoin(db.BaseGroup, db.Condition, {on: 'Condition'})
  )
  var r1 = ra.Query(ra.Select(r0, (t) => t.Environment == 'default'))
  var r2 = ra.Query(ra.Select(r0, (t) => t.Environment == '256'))
  var r3 = ra.Query(ra.Select(r0, (t) => t.Environment == '8'))

  assert_equal(3, len(r0))
  assert_equal(1, len(r1))
  assert_equal(1, len(r2))
  assert_equal(1, len(r3))

  assert_equal('Normal', r1[0]['HiGroup'])
  assert_equal('black', r1[0]['Fg'])
  assert_equal('white', r1[0]['Bg'])
  assert_equal('', r1[0]['DiscrName'])
  assert_equal('', r1[0]['DiscrValue'])

  assert_equal('Normal', r2[0]['HiGroup'])
  assert_equal('black', r2[0]['Fg'])
  assert_equal('white', r2[0]['Bg'])
  assert_equal('transp_bg', r2[0]['DiscrName'])
  assert_equal('1', r2[0]['DiscrValue'])

  assert_equal('Normal', r3[0]['HiGroup'])
  assert_equal('black', r3[0]['Fg'])
  assert_equal('white', r3[0]['Bg'])
  assert_equal('transp_bg', r3[0]['DiscrName'])
  assert_equal('1', r3[0]['DiscrValue'])
enddef

def Test_Parser_ConditionalDef()
  var template =<< trim END
    Background: dark
    Color: red #ff0000 ~
    #const foo = get(g:, 'foo', false)
    baldBison -> omit

    baldBison/gui+foo 1  none   none s=red   undercurl
             /256+foo 1  none   none s=red   underline
  END
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  var db = colorscheme.dark
  var base = ra.Query(
    ra.EquiJoin(db.BaseGroup, db.Condition, {on: 'Condition'})
  )
  var linked = ra.Query(
    ra.EquiJoin(db.LinkedGroup, db.Condition, {on: 'Condition'})
  )
  var r1 = ra.Query(ra.Select(linked, (t) => t.Environment == 'default'))
  var r2 = ra.Query(ra.Select(base,   (t) => t.Environment == 'gui'))
  var r3 = ra.Query(ra.Select(base,   (t) => t.Environment == '256'))

  assert_equal(2, len(base),   '01')
  assert_equal(1, len(linked), '02')
  assert_equal(1, len(r1),     '03')
  assert_equal(1, len(r2),     '04')
  assert_equal(1, len(r3),     '05')

  assert_equal('',     r1[0]['TargetGroup'])

  assert_equal('none',      r2[0]['Fg'])
  assert_equal('none',      r2[0]['Bg'])
  assert_equal('red',       r2[0]['Special'])
  assert_equal('undercurl', r2[0]['Style'])
  assert_equal('foo',       r2[0]['DiscrName'])
  assert_equal('1',         r2[0]['DiscrValue'])

  assert_equal('none',      r3[0]['Fg'])
  assert_equal('none',      r3[0]['Bg'])
  assert_equal('red',       r3[0]['Special'])
  assert_equal('underline', r3[0]['Style'])
  assert_equal('foo',       r3[0]['DiscrName'])
  assert_equal('1',         r3[0]['DiscrValue'])
enddef

def Test_Parser_BoldItalicHigGroups()
  var template =<< trim END
    Full name: **Bold** *Italic*
    Short name: bold-italic
    Background: dark
    ; Bold and Italic are valid highlight group names
    ; and should not be confused with keywords
    Added  none none
    Bold   none none bold
    Italic none none italic
  END
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_true(result.success)
  assert_equal('', result.label)

  var db = colorscheme.dark
  var r = ra.Query(
    db.BaseGroup->ra.Select((t) => t.HiGroup == 'Bold')
  )

  assert_equal(1, len(r))
  assert_equal('bold', r[0]['Style'])

  var s = ra.Query(
    db.BaseGroup->ra.Select((t) => t.HiGroup == 'Italic')
  )

  assert_equal(1, len(s))
  assert_equal('italic', s[0]['Style'])
enddef

def Test_Parser_SingleDefMultipleVariants()
  var template =<< trim END
    Background: dark
    #const italic = get(g:, 'italic', 1)
    Color: grey            rgb(146, 131, 116)    102 DarkGray
    Color: fg4             rgb(168, 153, 132)    137 Gray
    Comment                              grey   none          italic
                 /gui/256/16+italic 0    grey   none
                 /8                      fg4    none          italic
                 /8         +italic 0    fg4    none
  END
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)

  var db = colorscheme.dark
  var base = ra.Query(
    ra.EquiJoin(db.BaseGroup, db.Condition, {on: 'Condition'})
  )
  var r1 = ra.Query(ra.Select(base, (t) => t.Environment == 'default'))
  var r2 = ra.Query(ra.Select(base, (t) => t.Environment == 'gui'))
  var r3 = ra.Query(ra.Select(base, (t) => t.Environment == '256'))
  var r4 = ra.Query(ra.Select(base, (t) => t.Environment == '16'))
  var r5 = ra.Query(ra.Select(base, (t) => t.Environment == '8' && empty(t.DiscrName)))
  var r6 = ra.Query(ra.Select(base, (t) => t.Environment == '8' && t.DiscrName == 'italic'))

  assert_equal(6, len(base))

  for ri in [r1, r2, r3, r4, r5, r6]
    assert_equal(1, len(ri))
  endfor

  assert_equal('Comment', r1[0]['HiGroup'])
  assert_equal('grey',    r1[0]['Fg'])
  assert_equal('none',    r1[0]['Bg'])
  assert_equal('italic',  r1[0]['Style'])

  assert_equal('Comment', r2[0]['HiGroup'])
  assert_equal('grey',    r2[0]['Fg'])
  assert_equal('none',    r2[0]['Bg'])
  assert_equal('italic',  r2[0]['DiscrName'])
  assert_equal('0',       r2[0]['DiscrValue'])
  assert_equal('NONE',    r2[0]['Style'])

  assert_equal('Comment', r3[0]['HiGroup'])
  assert_equal('grey',    r3[0]['Fg'])
  assert_equal('none',    r3[0]['Bg'])
  assert_equal('italic',  r3[0]['DiscrName'])
  assert_equal('0',       r3[0]['DiscrValue'])
  assert_equal('NONE',    r3[0]['Style'])

  assert_equal('Comment', r4[0]['HiGroup'])
  assert_equal('grey',    r4[0]['Fg'])
  assert_equal('none',    r4[0]['Bg'])
  assert_equal('italic',  r4[0]['DiscrName'])
  assert_equal('0',       r4[0]['DiscrValue'])
  assert_equal('NONE',    r4[0]['Style'])

  assert_equal('Comment', r5[0]['HiGroup'])
  assert_equal('fg4',     r5[0]['Fg'])
  assert_equal('none',    r5[0]['Bg'])
  assert_equal('',        r5[0]['DiscrName'])
  assert_equal('',        r5[0]['DiscrValue'])
  assert_equal('italic',  r5[0]['Style'])

  assert_equal('Comment', r6[0]['HiGroup'])
  assert_equal('fg4',     r6[0]['Fg'])
  assert_equal('none',    r6[0]['Bg'])
  assert_equal('italic',  r6[0]['DiscrName'])
  assert_equal('0',       r6[0]['DiscrValue'])
  assert_equal('NONE',    r6[0]['Style'])
enddef

# A verbatim block before a background directive is stored as colorscheme metadata
def Test_Parser_VerbatimMetadata()
  var template =<< trim END
    verbatim
      Hi!
    endverbatim
  END
  var expected = ['  Hi!']
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, colorscheme.verbatimtext)
enddef

# A verbatim block after a background directive is stored as database metadata
def Test_Parser_VerbatimDatabase()
  var template =<< trim END
    Background: dark
    verbatim
      Hi!
    endverbatim
  END
  var expected = ['  Hi!']
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal([], colorscheme.verbatimtext)
  assert_equal(['  Hi!'], colorscheme.dark.verbatimtext)
  assert_equal([], colorscheme.light.verbatimtext)
enddef

# Verbatim blocks are interpolated
def Test_Parser_VerbatimBlockInterpolation()
  var template =<< trim END
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
    Environments: gui
    Color: black #333333 17 Black

    verbatim
    Color=@guiblack Approx=@256black/@16black
      Shortname: @shortname
      Fullname:  @fullname @version
    The background is @background
    endverbatim
  END

  var expected1 =<< trim END
    This is
      arbitrary text
    By myself
  END

  var expected2 =<< trim END
    Color=#333333 Approx=17/Black
      Shortname: xyz
      Fullname:  XYZ v1.2.3
    The background is light
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected1, colorscheme.verbatimtext)
  assert_equal(expected2, colorscheme.light.verbatimtext)
enddef

def Test_Parser_VerbatimDateVersion()
  var template =<< trim END
    verbatim
      Today is @date
      And this is Vim v@vimversion.0
    endverbatim
  END

  var expected = [
    printf("  Today is %s", strftime("%Y %b %d")),
    printf("  And this is Vim v%d.0", v:version / 100),
  ]

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, colorscheme.verbatimtext)
enddef

# Multiple verbatim blocks are concatenated
def Test_Parser_MultipleVerbatimBlocks()
  var template =<< trim END
  Background: dark
  Author:     Nemo
  verbatim
  @background
  endverbatim

  verbatim @author endverbatim
  END

  var expected = ['dark', ' Nemo ']
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, colorscheme.dark.verbatimtext)
enddef

def Test_Parser_VerbatimIdentifierWithNumbers()
  var template =<< trim END
    Background: dark
    Color: base0    #839496   246     12
    Color: base03   #002b36   235      8
    verbatim
      @256base03
      @256base0
    endverbatim
  END
  var expected = ['  235', '  246']
  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal(expected, colorscheme.dark.verbatimtext)
enddef

def Test_Parser_AuxFile()
  var template =<< trim END
    auxfile foo/bar
    abc '▇' def
    endauxfile
  END

  var [result, colorscheme] = Parse(join(template, "\n"))

  assert_equal('', result.label)
  assert_true(result.success)
  assert_equal({'foo/bar': ["abc '▇' def"]}, colorscheme.auxfiles)
enddef

def Test_Parser_MissingDiscriminator()
  var template =<< trim END
  Background: dark
  Color: violet #6c71c4 61 13
  vimCommentString -> omit
  vimCommentString /gui/256/16 +extra 1 violet none
  END

  var [result, _] = Parse(join(template, "\n"))

  assert_false(result.success, $'Template should have failed: {template}')
  assert_match("Discriminator: {DiscrName: 'extra'} not found", result.label)
enddef


tt.Run('_Parser_')

# vim: tw=100
