vim9script

import 'libtinytest.vim' as tt
import 'libcolor.vim'    as libcolor

const TESTPATH = resolve(expand('<sfile>:p'))
const TESTFILE = fnamemodify(TESTPATH, ':t')
const TESTDIR  = fnamemodify(TESTPATH, ':h')

const EPS                  = 0.000001
const Xterm2Hex            = libcolor.Xterm2Hex
const Xterm2Rgb            = libcolor.Xterm2Rgb
const Rgb2Hex              = libcolor.Rgb2Hex
const Hex2Rgb              = libcolor.Hex2Rgb
const Hex2Gray             = libcolor.Hex2Gray
const Rgb2Hsv              = libcolor.Rgb2Hsv
const Hsv2Rgb              = libcolor.Hsv2Rgb
const Rgb2Xyz              = libcolor.Rgb2Xyz
const Rgb2Cielab           = libcolor.Rgb2Cielab
const Rgb                  = libcolor.Rgb
const Hsv                  = libcolor.Hsv
const ColorDifference      = libcolor.ColorDifference
const ContrastRatio        = libcolor.ContrastRatio
const PerceptualDifference = libcolor.PerceptualDifference
const Approximate          = libcolor.Approximate
const ColorsWithin         = libcolor.ColorsWithin
const Neighbours           = libcolor.Neighbours


def Test_Color_Xterm2Hex()
  assert_equal('#000000', Xterm2Hex(16))
  assert_equal('#ffffff', Xterm2Hex(231))

  var i = 16

  while i < 256
    const hex = Xterm2Hex(i)

    assert_equal(i, Approximate(hex).xterm)

    ++i
  endwhile

  tt.AssertFails(() => {
    Xterm2Hex(15)
  },  'out of range'
  )
  tt.AssertFails(() => {
    Xterm2Hex(256)
  }, 'out of range'
  )
enddef

def Test_Color_Xterm2Rgb()
  assert_equal([0, 0, 0], Xterm2Rgb(16))
  assert_equal([255, 255, 255], Xterm2Rgb(231))
enddef

def Test_Color_Hex2Rgb()
  const black = Rgb.new(0, 0, 0)
  const white = Rgb.new(255, 255, 255)

  assert_equal(black, Rgb.newHex('#000000'))
  assert_equal(black, Rgb.newHex('000000'))
  assert_equal(white, Rgb.newHex('#ffffff'))
  assert_equal(white, Rgb.newHex('ffffff'))
enddef

def Test_Color_Rgb2Hex()
  assert_equal('#000000', Rgb2Hex(0, 0, 0))
  assert_equal('#ffffff', Rgb2Hex(255, 255, 255))
  assert_equal('#0b67da', call(Rgb2Hex, Hex2Rgb('#0b67da')))
enddef

def Test_Color_Hex2Gray()
  assert_equal(0,   Hex2Gray('#000000'))
  assert_equal(64,  Hex2Gray('#404040'))
  assert_equal(127, Hex2Gray('#7f7f7F'))
  assert_equal(191, Hex2Gray('#bfbfbf'))
  assert_equal(255, Hex2Gray('#ffffff'))
  assert_equal(84,  Hex2Gray('#405952'))
  assert_equal(153, Hex2Gray('#9c9b7a'))
  assert_equal(218, Hex2Gray('#ffd393'))
  assert_equal(177, Hex2Gray('#ff974f'))
  assert_equal(137, Hex2Gray('#f54f29'))
enddef

def Test_Color_Rgb2Hsv()
  var h: number
  var s: number
  var v: number

  [h,s,v] = Rgb2Hsv(0, 0, 0)
  assert_equal(  0, h)
  assert_equal(  0, s)
  assert_equal(  0, v)
  [h,s,v] = Rgb2Hsv(255, 255, 255)
  assert_equal(  0, h)
  assert_equal(  0, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(128, 128, 128)
  assert_equal(  0, h)
  assert_equal(  0, s)
  assert_equal( 50, v)
  [h,s,v] = Rgb2Hsv(255, 0, 4)
  assert_equal(359, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(255, 0, 0)
  assert_equal(  0, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(255, 128, 0)
  assert_equal( 30, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(255, 255, 0)
  assert_equal( 60, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(128, 255, 0)
  assert_equal( 90, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(0, 255, 0)
  assert_equal(120, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(0, 255, 128)
  assert_equal(150, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(0, 255, 255)
  assert_equal(180, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(0, 128, 255)
  assert_equal(210, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(0, 0, 255)
  assert_equal(240, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(128, 0, 255)
  assert_equal(270, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(255, 0, 255)
  assert_equal(300, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(255, 0, 128)
  assert_equal(330, h)
  assert_equal(100, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(1, 1, 1)
  assert_equal(  0, h)
  assert_equal(  0, s)
  assert_equal(  0, v)
  [h,s,v] = Rgb2Hsv(3, 3, 3)
  assert_equal(  0, h)
  assert_equal(  0, s)
  assert_equal(  1, v)
  [h,s,v] = Rgb2Hsv(252, 3, 7)
  assert_equal(359, h)
  assert_equal( 99, s)
  assert_equal( 99, v)
  [h,s,v] = Rgb2Hsv(255, 255, 254)
  assert_equal( 60, h)
  assert_equal(  0, s)
  assert_equal(100, v)
  [h,s,v] = Rgb2Hsv(197, 128, 63)
  assert_equal( 29, h)
  assert_equal( 68, s)
  assert_equal( 77, v)
  [h,s,v] = Rgb2Hsv(33, 197, 99)
  assert_equal(144, h)
  assert_equal( 83, s)
  assert_equal( 77, v)
  [h,s,v] = Rgb2Hsv(239, 7, 131)
  assert_equal(328, h)
  assert_equal( 97, s)
  assert_equal( 94, v)
  [h,s,v] = Rgb2Hsv(135, 38, 39)
  assert_equal(359, h)
  assert_equal( 72, s)
  assert_equal( 53, v)
enddef

def Test_Color_Hsv2Rgb()
   var [r,g,b] = Hsv2Rgb(0, 0, 0)
   assert_equal(  0, r)
   assert_equal(  0, g)
   assert_equal(  0, b)
   [r,g,b] = Hsv2Rgb(0, 0, 100)
   assert_equal(255, r)
   assert_equal(255, g)
   assert_equal(255, b)
   [r,g,b] = Hsv2Rgb(300, 0, 50)
   assert_equal(128, r)
   assert_equal(128, g)
   assert_equal(128, b)
   [r,g,b] = Hsv2Rgb(359, 100, 100)
   assert_equal(255, r)
   assert_equal(  0, g)
   assert_equal(  4, b)
   [r,g,b] = Hsv2Rgb(360, 100, 100)  # 360° == 0°
   assert_equal(255, r)
   assert_equal(  0, g)
   assert_equal(  0, b)
   [r,g,b] = Hsv2Rgb(30, 100, 100)
   assert_equal(255, r)
   assert_equal(128, g)
   assert_equal(  0, b)
   [r,g,b] = Hsv2Rgb(60, 100, 100)
   assert_equal(255, r)
   assert_equal(255, g)
   assert_equal(  0, b)
   [r,g,b] = Hsv2Rgb(90, 100, 100)
   assert_equal(128, r)
   assert_equal(255, g)
   assert_equal(  0, b)
   [r,g,b] = Hsv2Rgb(120, 100, 100)
   assert_equal(  0, r)
   assert_equal(255, g)
   assert_equal(  0, b)
   [r,g,b] = Hsv2Rgb(150, 100, 100)
   assert_equal(  0, r)
   assert_equal(255, g)
   assert_equal(128, b)
   [r,g,b] = Hsv2Rgb(180, 100, 100)
   assert_equal(  0, r)
   assert_equal(255, g)
   assert_equal(255, b)
   [r,g,b] = Hsv2Rgb(210, 100, 100)
   assert_equal(  0, r)
   assert_equal(128, g)
   assert_equal(255, b)
   [r,g,b] = Hsv2Rgb(240, 100, 100)
   assert_equal(  0, r)
   assert_equal(  0, g)
   assert_equal(255, b)
   [r,g,b] = Hsv2Rgb(270, 100, 100)
   assert_equal(128, r)
   assert_equal(  0, g)
   assert_equal(255, b)
   [r,g,b] = Hsv2Rgb(300, 100, 100)
   assert_equal(255, r)
   assert_equal(  0, g)
   assert_equal(255, b)
   [r,g,b] = Hsv2Rgb(300, 100, 100)
   assert_equal(255, r)
   assert_equal(  0, g)
   assert_equal(255, b)
   [r,g,b] = Hsv2Rgb(330, 100, 100)
   assert_equal(255, r)
   assert_equal(  0, g)
   assert_equal(128, b)
   [r,g,b] = Hsv2Rgb(279, 57, 99)
   assert_equal(202, r)
   assert_equal(109, g)
   assert_equal(252, b)
   [r,g,b] = Hsv2Rgb(1, 1, 1)
   assert_equal(  3, r)
   assert_equal(  3, g)
   assert_equal(  3, b)
   [r,g,b] = Hsv2Rgb(359, 99, 99)
   assert_equal(252, r)
   assert_equal(  3, g)
   assert_equal(  7, b)
enddef


def Test_Color_Rgb2xyz()
  const [x,y,z] = Rgb2Xyz(238, 238, 239)
  # Values as computed by http://colormine.org/color-converter
  tt.AssertApprox(81.41441852841255, x, 0.0, EPS)
  tt.AssertApprox(85.55820926290504, y, 0.0, EPS)
  tt.AssertApprox(93.88474076133308, z, 0.0, EPS)
enddef

def Test_Color_Rgb2Cielab()
  const [L,a,b] = Rgb2Cielab(238, 238, 239)
  # Values as computed by http://colormine.org/color-converter
  tt.AssertApprox(94.12313115610355,    L, 0.0, EPS)
  tt.AssertApprox(0.18264247948240886,  a, 0.0, EPS)
  tt.AssertApprox(-0.49221569623207895, b, 0.0, EPS)
enddef

def Test_Color_ColorDifference()
  const fixture = [
    [0.0,   ColorDifference('#000000', '#000000')],
    [765.0, ColorDifference('#000000', '#ffffff')],
    [765.0, ColorDifference('#ffff00', '#0000ff')],
  ]

  for pair in fixture
    assert_equal(v:t_float, type(pair[1]))
    assert_equal(pair[0], pair[1])
  endfor
enddef

def Test_Color_PerceptualDifference()
  const fixture = [
    [0.5442200, PerceptualDifference('#eeeeef', '#eeeeee')],
    [7.8896850, PerceptualDifference('#767676', '#7c6f64')],
    [38.040076, PerceptualDifference('#444444', '#ff0000')],
  ]

  for pair in fixture
    assert_equal(v:t_float, type(pair[1]))
    tt.AssertApprox(pair[0], pair[1], 0.0, EPS)
  endfor
enddef

def Test_Color_Rgb()
  const red    = Rgb.new(166, 35, 23)
  const redHsv = Hsv.new(5,   86, 65)

  assert_equal(166,       red.r)
  assert_equal(35,        red.g)
  assert_equal(23,        red.b)
  assert_equal('#a62317', red.Hex())
  assert_equal(86,        red.ToGray())
  assert_equal(redHsv,    red.ToHsv())

  const brown    = Rgb.new(138, 108, 56)
  const brownHsv = Hsv.new(38,   59, 54)

  assert_equal(138,       brown.r)
  assert_equal(108,       brown.g)
  assert_equal(56,        brown.b)
  assert_equal('#8a6c38', brown.Hex())
  assert_equal(113,       brown.ToGray())
  assert_equal(brownHsv,  brown.ToHsv())
enddef

def Test_Color_Hsv()
  const brown    = Hsv.new(38,   59, 54)
  const brownRgb = Rgb.new(138, 108, 56)

  assert_equal(38,        brown.h)
  assert_equal(59,        brown.s)
  assert_equal(54,        brown.v)
  assert_equal('#8a6c38', brown.Hex())
  assert_equal(113,       brown.ToGray())
  assert_equal(brownRgb,  brown.ToRgb())

  const red    = Hsv.new(5,   86, 65)
  const redRgb = Rgb.new(166, 35, 23)

  assert_equal(5,         red.h)
  assert_equal(86,        red.s)
  assert_equal(65,        red.v)
  assert_equal('#a62317', red.Hex())
  assert_equal(86,        red.ToGray())
  assert_equal(redRgb,    red.ToRgb())
enddef

def Test_Color_ContrastRatio()
  const testCasesRgb = [
    [[0,   0,   0  ], [0,   0,   0  ],  1.0],
    [[255, 255, 255], [255, 255, 255],  1.0],
    [[100, 100, 100], [100, 100, 100],  1.0],
    [[0,   0,   0  ], [255, 255, 255], 21.0],
    [[255, 255, 255], [0,   0,   0  ], 21.0],
  ]

  for t in testCasesRgb
    const [r1, g1, b1]          = t[0]
    const [r2, g2, b2]          = t[1]
    const expectedContrastRatio = t[2]
    const rgb1                  = Rgb.new(r1, g1, b1)
    const rgb2                  = Rgb.new(r2, g2, b2)

    tt.AssertApprox(
      expectedContrastRatio, ContrastRatio(rgb1, rgb2), 0.01
    )
  endfor

  const testCasesHex = [
    ['#707070', '#e1fafa', 4.54],
    ['#e1fafa', '#707070', 4.54],
    ['#fafa96', '#707070', 4.52],
    ['#707070', '#fafa96', 4.52],
    ['#707070', '#fafaaf', 4.56],
    ['#fafaaf', '#707070', 4.56],
    ['#707070', '#fafac8', 4.62],
    ['#fafac8', '#707070', 4.62],
    ['#707070', '#fafae1', 4.68],
    ['#fafae1', '#707070', 4.68],
    ['#707070', '#fafafa', 4.74],
    ['#fafafa', '#707070', 4.74],
  ]

  for t  in testCasesHex
    const rgb1                  = Rgb.newHex(t[0])
    const rgb2                  = Rgb.newHex(t[1])
    const expectedContrastRatio = t[2]

    tt.AssertApprox(
      expectedContrastRatio, ContrastRatio(rgb1, rgb2), 0.01
    )
  endfor
enddef

def Test_Color_Approximate()
  const approx = Approximate('#eeeeef')

  assert_equal(255,        approx.xterm)
  assert_equal('#eeeeee',  approx.hex)
  tt.AssertApprox(0.54422, approx.delta, 0.0, EPS)
enddef


def Test_Color_ColorsWithin()
  const neighbours = '#9e0006'->ColorsWithin(4.5)

  assert_equal(2,   len(neighbours))
  assert_equal(88,  neighbours[0])
  assert_equal(124, neighbours[1])
enddef

def Test_Color_Neighbours()
  const neighbours = '#9e0006'->Neighbours(2)

  assert_equal(2,   len(neighbours))
  assert_equal(124, neighbours[0].xterm)
  assert_equal(88,  neighbours[1].xterm)
enddef


tt.Run('_Color_')
