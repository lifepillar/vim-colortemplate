vim9script

import 'librelalg.vim'                           as ra
import 'libtinytest.vim'                         as tt
import '../import/colortemplate/colorscheme.vim' as colorscheme

type Colorscheme = colorscheme.Colorscheme
type Database    = colorscheme.Database

const KEY_NOT_FOUND = colorscheme.KEY_NOT_FOUND

const Count      = ra.Count
const Project    = ra.Project
const Query      = ra.Query
const RelEq      = ra.RelEq
const Select     = ra.Select
const SortBy     = ra.SortBy
const Transform  = ra.Transform


def Test_Colorscheme_DatabaseBackground()
  var db1 = Database.new('dark')
  var db2 = Database.new('light')

  assert_equal('dark',  db1.background)
  assert_equal('light', db2.background)

  tt.AssertFails(() => {
    var db3 = Database.new('foobar')
    }, 'Invalid background')
enddef

def Test_Colorscheme_Database()
  var db = Database.new('dark')

  # The default environment must be defined
  assert_equal(
    'default',
    db.Environment.Lookup(['Environment'], ['default']).Environment
  )
  # Aliases for colors must be predefined
  assert_equal(['', 'bg', 'fg', 'none'],
    db.Color->Project('Name')->SortBy('Name')->Transform((t) => t.Name)
  )
  # A default empty discriminator must be predefined
  assert_equal(
    [{DiscrName: '', Definition: '', DiscrNum: 0}],
    db.Discriminator.Instance()
  )
  # A default condition must be predefined
  assert_equal(
    [{Condition: 0, Environment: 'default', DiscrName: '', DiscrValue: ''}],
    db.Condition.Instance()
  )
enddef

def Test_Colorscheme_InsertLinkedGroup()
  var db = Database.new('dark')

  assert_equal([], db.HighlightGroup.Instance())
  assert_equal([], db.HighlightGroupDef.Instance())
  assert_equal([], db.LinkedGroup.Instance())

  db.InsertLinkedGroup('default', '', '', 'Comment', 'String')

  assert_true(RelEq(
    [{HiGroup: 'Comment', DiscrName: ''}],
    db.HighlightGroup.Instance()
  ), '01')

  assert_true(RelEq(
    [{HiGroup: 'Comment', Condition: 0, IsLinked: true}],
    db.HighlightGroupDef.Instance()
  ), '02')

  assert_true(RelEq(
    [{HiGroup: 'Comment', Condition: 0, TargetGroup: 'String'}],
    db.LinkedGroup.Instance()
  ), '03')

  tt.AssertFails(() => {
    db.InsertLinkedGroup('default', 'titled', 'true', 'Comment', 'Title')
  }, 'Referential integrity failed') # 'titled' discriminator is undefined

  db.InsertDiscriminator('titled', 'def goes here')
  db.InsertLinkedGroup('default', 'titled', 'true', 'Comment', 'Title')

  assert_true(RelEq([
    {HiGroup: 'Comment', DiscrName: 'titled'}],
    db.HighlightGroup.Instance()
  ), '04')

  assert_true(RelEq([
    {HiGroup: 'Comment', Condition: 0, IsLinked: true},
    {HiGroup: 'Comment', Condition: 1, IsLinked: true},
  ],
    db.HighlightGroupDef.Instance()
  ), '05')

  assert_true(RelEq([
    {HiGroup: 'Comment', Condition: 0, TargetGroup: 'String'},
    {HiGroup: 'Comment', Condition: 1, TargetGroup: 'Title'},
  ],
    db.LinkedGroup.Instance()
  ), '06')

  tt.AssertFails(() => {
    db.InsertLinkedGroup('default', 'foobar', 'xyz', 'Comment', 'String')
  }, 'Inconsistent discriminator') # Cannot have more than one discriminator per highlight group
enddef

def Test_Colorscheme_InsertBaseGroup()
  var db = Database.new('light')

  assert_equal([], db.HighlightGroup.Instance())
  assert_equal([], db.HighlightGroupDef.Instance())
  assert_equal([], db.BaseGroup.Instance())

  db.InsertBaseGroup('default', '', '', 'Normal', 'fg', 'bg', 'none', 'bold')

  assert_true(RelEq([
    {HiGroup: 'Normal', DiscrName: ''}],
    db.HighlightGroup.Instance()
  ), '01')

  assert_true(RelEq([
    {HiGroup: 'Normal', Condition: 0, IsLinked: false},
  ],
    db.HighlightGroupDef.Instance()
  ), '02')

  assert_equal([{
    HiGroup:   'Normal',
    Condition:  0,
    Fg:        'fg',
    Bg:        'bg',
    Special:   'none',
    Style:     'bold',
    Font:      '',
    Start:     '',
    Stop:      '',
  }],
    db.BaseGroup.Instance()
  )
enddef

def Test_Colorscheme_InsertionOrder()
  # It is possible to insert highlight group definitions in any order
  var db = Database.new('dark')

  db.InsertDiscriminator('italic', 'def goes here')
  db.InsertBaseGroup('256',      '',       '',     'String', 'fg', 'bg',   '',     ''      )
  db.InsertBaseGroup('16',       'italic', 'true', 'String', 'fg', 'bg',   '',     'italic')
  db.InsertBaseGroup('default',  '',       '',     'String', 'fg', 'none', 'none', 'bold'  )

  assert_equal(3, Count(db.Condition))

  assert_true(RelEq([
    {Condition: 0, Environment: 'default', DiscrName: '',       DiscrValue: ''    },
    {Condition: 1, Environment: '256',     DiscrName: '',       DiscrValue: ''    },
    {Condition: 2, Environment: '16',      DiscrName: 'italic', DiscrValue: 'true'},
  ],
  db.Condition.Instance()
  ))

  assert_true(RelEq([
    {
      HiGroup:   'String',
      Condition:  0,
      Fg:        'fg',
      Bg:        'none',
      Special:   'none',
      Style:     'bold',
      Font:      '',
      Start:     '',
      Stop:      '',
    },
    {
      HiGroup:   'String',
      Condition:  1,
      Fg:        'fg',
      Bg:        'bg',
      Special:   '',
      Style:     '',
      Font:      '',
      Start:     '',
      Stop:      '',
    },
    {
      HiGroup:   'String',
      Condition:  2,
      Fg:        'fg',
      Bg:        'bg',
      Special:   '',
      Style:     'italic',
      Font:      '',
      Start:     '',
      Stop:      '',
    },
  ],
  db.BaseGroup.Instance()
  ), $'Unexpectedly, got {db.BaseGroup.Instance()}')
enddef

def Test_Colorscheme_HiGroupDef()
  var db = Database.new('dark')

  db.InsertDiscriminator('italic', 'def goes here')
  db.InsertBaseGroup('256',      '',       '',     'String', 'fg', 'bg',   '',     ''      )
  db.InsertBaseGroup('16',       'italic', 'true', 'String', 'fg', 'bg',   '',     'italic')
  db.InsertBaseGroup('default',  '',       '',     'String', 'fg', 'none', 'none', 'bold'  )
  db.InsertLinkedGroup('8', '', '', 'String', 'Title')

  assert_equal({
    HiGroup:   'String',
    Condition:  0,
    Fg:        'fg',
    Bg:        'none',
    Special:   'none',
    Style:     'bold',
    Font:      '',
    Start:     '',
    Stop:      ''
    },
    db.HiGroupDef('String', 'default'), '01'
  )
  assert_equal({
    HiGroup:   'String',
    Condition:  1,
    Fg:        'fg',
    Bg:        'bg',
    Special:   '',
    Style:     '',
    Font:      '',
    Start:     '',
    Stop:      ''
    },
    db.HiGroupDef('String', '256'), '02'
  )
  assert_equal({
    HiGroup:   'String',
    Condition:  2,
    Fg:        'fg',
    Bg:        'bg',
    Special:   '',
    Style:     'italic',
    Font:      '',
    Start:     '',
    Stop:      ''
    },
    db.HiGroupDef('String', '16', 'italic', 'true'), '03'
  )
  assert_equal({
    HiGroup:    'String',
    Condition:   3,
    TargetGroup: 'Title',
    },
    db.HiGroupDef('String', '8'), '04'
  )

  assert_true(db.HiGroupDef('String', '8', 'italic', 'true') is KEY_NOT_FOUND)
  assert_true(db.HiGroupDef('String', '8', 'italic', 'false') is KEY_NOT_FOUND)
  assert_true(db.HiGroupDef('String', 'default', 'italic', 'true') is KEY_NOT_FOUND)
  assert_true(db.HiGroupDef('String', '16') is KEY_NOT_FOUND)
enddef


tt.Run('_Colorscheme_')
