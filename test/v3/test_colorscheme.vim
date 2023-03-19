vim9script

import 'libtinytest.vim' as tt
import '../../autoload/v3/parser.vim'    as parser
import '../../autoload/v3/colorscheme.vim' as colorscheme

const Parse    = parser.Parse
const NO_DISCR = colorscheme.DEFAULT_DISCR_VALUE
const Metadata = colorscheme.Metadata
const Database = colorscheme.Database

def Test_CS_GetVariantMetadata()
  const template =<< trim END
  Background: dark
  Variants: gui 256
  Color: black #333333 231 black
  Color: white #fafafa 250 white
  END

  const parseResult  = Parse(join(template, "\n"))
  const db: Database = parseResult.dark
  const metaGUI      = db.GetVariantMetadata('gui')
  const meta256      = db.GetVariantMetadata('256')

  assert_true(metaGUI.Colors->has_key('black'))
  assert_true(metaGUI.Colors->has_key('white'))
  assert_equal('#333333',      metaGUI.Colors['black'])
  assert_equal('#fafafa',      metaGUI.Colors['white'])
  assert_equal('gui',          metaGUI.Variant)
  assert_equal(16777216,       metaGUI.NumColors)
  assert_equal('GUIValue',     metaGUI.ColorAttr)
  assert_equal('guifg',        metaGUI.Fg)
  assert_equal('guibg',        metaGUI.Bg)
  assert_equal('gui',          metaGUI.Style)
  assert_equal('font',         metaGUI.Font)

  assert_true(meta256.Colors->has_key('black'))
  assert_true(meta256.Colors->has_key('white'))
  assert_equal('231',          meta256.Colors['black'])
  assert_equal('250',          meta256.Colors['white'])
  assert_equal('256',          meta256.Variant)
  assert_equal(256,            meta256.NumColors)
  assert_equal('Base256Value', meta256.ColorAttr)
  assert_equal('ctermfg',      meta256.Fg)
  assert_equal('ctermbg',      meta256.Bg)
  assert_equal('cterm',        meta256.Style)
  assert_equal('',             meta256.Font)
enddef

def Test_CS_HiGroupDef()
  const template =<< trim END
  Background: dark
  Variants: gui 256
  Color: black #333333 231 black
  Color: white #fafafa 251 white
  Normal white black
  Comment black white reverse
     /256 white black s=white bold
  #const foobar = "X"
  Comment+foobar "X" white white
  Comment+foobar "Y" -> NonText
  END

  const parseResult = Parse(join(template, "\n"))
  const db: Database = parseResult.dark
  const t0 = db.HiGroupDef('Normal', 'gui')
  const t1 = db.HiGroupDef('Comment', 'gui')
  const t2 = db.HiGroupDef('Comment', '256')
  const t3 = db.HiGroupDef('Comment', '256', '"X"')
  const t4 = db.HiGroupDef('Comment', 'gui', '"Y"')

  assert_false(empty(t0))
  assert_equal('Normal', t0.HiGroupName)
  assert_equal('black',  t0.Bg)
  assert_equal('white',  t0.Fg)
  assert_equal('none',   t0.Special)
  assert_equal('NONE',   t0.Style)
  assert_false(empty(t1))
  assert_equal('Comment', t1.HiGroupName)
  assert_equal('white',   t1.Bg)
  assert_equal('black',   t1.Fg)
  assert_equal('none',    t1.Special)
  assert_equal('reverse', t1.Style)
  assert_false(empty(t2))
  assert_equal('Comment', t2.HiGroupName)
  assert_equal('black',   t2.Bg)
  assert_equal('white',   t2.Fg)
  assert_equal('white',   t2.Special)
  assert_equal('bold',    t2.Style)
  assert_false(empty(t3))
  assert_equal('Comment', t3.HiGroupName)
  assert_equal('white',   t3.Bg)
  assert_equal('white',   t3.Fg)
  assert_equal('none',    t3.Special)
  assert_equal('NONE',    t3.Style)
  assert_false(empty(t4))
  assert_equal('Comment', t4.HiGroupName)
  assert_equal('NonText', t4.TargetGroup)
enddef


tt.Run('_CS_')

