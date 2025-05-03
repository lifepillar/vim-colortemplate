vim9script

import 'libtinytest.vim' as tt
import 'libcolor.vim'    as libcolor

const TESTPATH = resolve(expand('<sfile>:p'))
const TESTFILE = fnamemodify(TESTPATH, ':t')
const TESTDIR  = fnamemodify(TESTPATH, ':h')

type Rgb = libcolor.Rgb
type Hsv = libcolor.Hsv

const EPS                  = 0.000001
const PI                   = libcolor.PI
const AssertFails          = tt.AssertFails
const ColorNumber2Hex      = libcolor.ColorNumber2Hex
const Cterm2Hex            = libcolor.Cterm2Hex
const CtermName2Hex        = libcolor.CtermName2Hex
const DegToRad             = libcolor.DegToRad
const Xterm2Hex            = libcolor.Xterm2Hex
const Xterm2Rgb            = libcolor.Xterm2Rgb
const Rgb2Hex              = libcolor.Rgb2Hex
const Hex2Rgb              = libcolor.Hex2Rgb
const Hex2Gray             = libcolor.Hex2Gray
const Rgb2Hsv              = libcolor.Rgb2Hsv
const Hsv2Rgb              = libcolor.Hsv2Rgb
const Rgb2Xyz              = libcolor.Rgb2Xyz
const Rgb2Cielab           = libcolor.Rgb2Cielab
const ColorDifference      = libcolor.ColorDifference
const ContrastRatio        = libcolor.ContrastRatio
const PerceptualDifference = libcolor.PerceptualDifference
const DeltaE2000           = libcolor.DeltaE2000
const Approximate          = libcolor.Approximate
const ColorsWithin         = libcolor.ColorsWithin
const Neighbours           = libcolor.Neighbours

def In(v: any, items: list<any>): bool
  return index(items, v) != -1
enddef

def Test_Color_Version()
  assert_true(match(libcolor.version, '^\d\+\.\d\+\.\d\+') != -1)
enddef

def Test_Color_Cterm2Hex()
  for i in range(16)
    assert_equal(libcolor.ANSI_HEX[i], Cterm2Hex(i))
  endfor
enddef

def Test_Color_CtermName2Hex()
  for name in libcolor.ANSI_COLORS
    assert_true(CtermName2Hex(name)->In(libcolor.ANSI_HEX))
  endfor
enddef

def Test_Color_ColorNumber2Hex()
  assert_equal(libcolor.ANSI_HEX[0],  ColorNumber2Hex(0))
  assert_equal(libcolor.ANSI_HEX[9],  ColorNumber2Hex(9))
  assert_equal(libcolor.ANSI_HEX[15], ColorNumber2Hex(15))
  assert_equal('#000000',             ColorNumber2Hex(16))
  assert_equal('#ffffff',             ColorNumber2Hex(231))

  AssertFails(() => {
    ColorNumber2Hex(256)
  }, 'out of range')

  AssertFails(() => {
    ColorNumber2Hex(-1)
  }, 'out of range')
enddef

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
  const testCases = [
    [  0,   0,   0,    0,   0,   0],
    [255, 255, 255,    0,   0, 100],
    [128, 128, 128,    0,   0,  50],
    [255,   0,   4,  359, 100, 100],
    [255,   0,   0,    0, 100, 100],
    [255, 128,   0,   30, 100, 100],
    [255, 255,   0,   60, 100, 100],
    [128, 255,   0,   90, 100, 100],
    [  0, 255,   0,  120, 100, 100],
    [  0, 255, 128,  150, 100, 100],
    [  0, 255, 255,  180, 100, 100],
    [  0, 128, 255,  210, 100, 100],
    [  0,   0, 255,  240, 100, 100],
    [128,   0, 255,  270, 100, 100],
    [255,   0, 255,  300, 100, 100],
    [255,   0, 128,  330, 100, 100],
    [  1,   1,   1,    0,   0,   0],
    [  3,   3,   3,    0,   0,   1],
    [252,   3,   7,  359,  99,  99],
    [255, 255, 254,   60,   0, 100],
    [197, 128,  63,   29,  68,  77],
    [ 33, 197,  99,  144,  83,  77],
    [239,   7, 131,  328,  97,  94],
    [135,  38,  39,  359,  72,  53],
    [ 40,  40,  40,    0,   0,  16],
  ]

  for t in testCases
    const [h, s, v] = Rgb2Hsv(t[0], t[1], t[2])
    assert_equal(t[3], h)
    assert_equal(t[4], s)
    assert_equal(t[5], v)
  endfor
enddef

def Test_Color_Hsv2Rgb()
  const testCases = [
    [  0,   0,   0,    0,   0,   0],
    [  0,   0, 100,  255, 255, 255],
    [300,   0,  50,  128, 128, 128],
    [359, 100, 100,  255,   0,   4],
    [360, 100, 100,  255,   0,   0], # 360° == 0°
    [ 30, 100, 100,  255, 128,   0],
    [ 60, 100, 100,  255, 255,   0],
    [ 90, 100, 100,  128, 255,   0],
    [120, 100, 100,    0, 255,   0],
    [150, 100, 100,    0, 255, 128],
    [180, 100, 100,    0, 255, 255],
    [210, 100, 100,    0, 128, 255],
    [240, 100, 100,    0,   0, 255],
    [270, 100, 100,  128,   0, 255],
    [300, 100, 100,  255,   0, 255],
    [300, 100, 100,  255,   0, 255],
    [330, 100, 100,  255,   0, 128],
    [279,  57,  99,  202, 109, 252],
    [  1,   1,   1,    3,   3,   3],
    [359,  99,  99,  252,   3,   7],
  ]

  for t in testCases
   var [r, g, b] = Hsv2Rgb(t[0], t[1], t[2])
   assert_equal(t[3], r, $'({t[3]},{t[4]},{t[5]}) ≠ ({r},{g},{b})')
   assert_equal(t[4], g, $'({t[3]},{t[4]},{t[5]}) ≠ ({r},{g},{b})')
   assert_equal(t[5], b, $'({t[3]},{t[4]},{t[5]}) ≠ ({r},{g},{b})')
  endfor
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
    [ 0.5442, PerceptualDifference('#eeeeef', '#eeeeee')],
    [ 7.8897, PerceptualDifference('#767676', '#7c6f64')],
    [38.0400, PerceptualDifference('#444444', '#ff0000')],
  ]
  const tol = pow(10, -4)

  for pair in fixture
    assert_equal(v:t_float, type(pair[1]))
    tt.AssertApprox(pair[0], pair[1], 0.0, tol)
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

# Delta CIEDE2000 - Reference implementation {{{
# G. Sharma, W. Wu, and E. N. Dalal.
# The CIEDE2000 color-difference formula: Implementation notes, supplementary test data, and mathematical observations.
# Color Research and Applications, 30(1):21–30, Feb. 2004.

def C_bar(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  const C_star_1 = sqrt(a1 * a1 + b1 * b1) # Eq (2)
  const C_star_2 = sqrt(a2 * a2 + b2 * b2) # Eq (2)
  return 0.5 * (C_star_1 + C_star_2)       # Eq (3)
enddef

def G(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (4)
  const C_bar_pow_7 = pow(C_bar(L1, a1, b1, L2, a2, b2), 7)
  return 0.5 * (1.0 - sqrt(C_bar_pow_7 / (C_bar_pow_7 + pow(25, 7))))
enddef

def A_prime_i(i: number, L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (5)
  const a = (i == 1 ? a1 : a2)
  return (1.0 + G(L1, a1, b1, L2, a2, b2)) * a
enddef

def C_prime_i(i: number, L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (6)
  const b = (i == 1 ? b1 : b2)
  const a_prime_i = A_prime_i(i, L1, a1, b1, L2, a2, b2)
  return sqrt(a_prime_i * a_prime_i + b * b)
enddef

def H_prime_i(i: number, L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (7)
  const b_i = (i == 1 ? b1 : b2)
  const a_prime_i = A_prime_i(i, L1, a1, b1, L2, a2, b2)

  # See note 1 on page 23
  var h_prime = atan2(b_i, a_prime_i) * 180.0 / PI # atan2(0.0, 0.0) == 0.0 by definition

  if h_prime < 0.0
    h_prime += 360.0
  endif

  return h_prime
enddef

def Delta_L_prime(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (8)
  return L2 - L1
enddef

def Delta_C_prime(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (9)
  const C_prime_1 = C_prime_i(1, L1, a1, b1, L2, a2, b2)
  const C_prime_2 = C_prime_i(2, L1, a1, b1, L2, a2, b2)
  return C_prime_2 - C_prime_1
enddef

def Delta_h_prime(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (10)
  const C_prime_1 = C_prime_i(1, L1, a1, b1, L2, a2, b2)
  const C_prime_2 = C_prime_i(2, L1, a1, b1, L2, a2, b2)
  const h_prime_1 = H_prime_i(1, L1, a1, b1, L2, a2, b2)
  const h_prime_2 = H_prime_i(2, L1, a1, b1, L2, a2, b2)
  const h_prime_abs_delta = abs(h_prime_1 - h_prime_2)

  var delta_h_prime: float

  if C_prime_1 * C_prime_2 == 0.0
    delta_h_prime = 0.0
  else
    if h_prime_abs_delta <= 180.0
      delta_h_prime = h_prime_2 - h_prime_1
    elseif h_prime_2 - h_prime_1 > 180
      delta_h_prime = h_prime_2 - h_prime_1 - 360.0
    else
      delta_h_prime = h_prime_2 - h_prime_1 + 360.0
    endif
  endif

  return delta_h_prime
enddef

def Delta_H_prime(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (11)
  const C_prime_1 = C_prime_i(1, L1, a1, b1, L2, a2, b2)
  const C_prime_2 = C_prime_i(2, L1, a1, b1, L2, a2, b2)
  const delta_h_prime = Delta_h_prime(L1, a1, b1, L2, a2, b2)
  return 2.0 * sqrt(C_prime_1 * C_prime_2) * sin(delta_h_prime * PI / 360.0)
enddef


def L_bar_prime(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (12)
  return 0.5 * (L1 + L2)
enddef

def C_bar_prime(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (13)
  const C_prime_1 = C_prime_i(1, L1, a1, b1, L2, a2, b2)
  const C_prime_2 = C_prime_i(2, L1, a1, b1, L2, a2, b2)
  return 0.5 * (C_prime_1 + C_prime_2)
enddef

def H_bar_prime(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (14)
  const h_prime_1 = H_prime_i(1, L1, a1, b1, L2, a2, b2)
  const h_prime_2 = H_prime_i(2, L1, a1, b1, L2, a2, b2)
  const h_prime_abs_delta = abs(h_prime_1 - h_prime_2)
  const C_prime_1 = C_prime_i(1, L1, a1, b1, L2, a2, b2)
  const C_prime_2 = C_prime_i(2, L1, a1, b1, L2, a2, b2)

  if C_prime_1 * C_prime_2 == 0.0
    return h_prime_1 + h_prime_2
  else
    if (h_prime_abs_delta <= 180.0)
      return 0.5 * (h_prime_1 + h_prime_2)
    elseif h_prime_1 + h_prime_2 < 360.0
      return 0.5 * (h_prime_1 + h_prime_2 + 360.0)
    else
      return 0.5 * (h_prime_1 + h_prime_2 - 360.0)
    endif
  endif
enddef

def T(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (15)
  const H = H_bar_prime(L1, a1, b1, L2, a2, b2)
  return 1.0
    - 0.17 * cos(DegToRad(H - 30.0))
    + 0.24 * cos(DegToRad(H * 2.0))
    + 0.32 * cos(DegToRad(H * 3.0 + 6.0))
    - 0.20 * cos(DegToRad(H * 4.0 - 63.0))
enddef

def Delta_theta(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (16)
  const H = H_bar_prime(L1, a1, b1, L2, a2, b2)
  var H_bar_prime_minus_275_div_25_square = (H - 275.0) / 25.0
  H_bar_prime_minus_275_div_25_square = H_bar_prime_minus_275_div_25_square * H_bar_prime_minus_275_div_25_square
  return 30.0 * exp(-H_bar_prime_minus_275_div_25_square)
enddef

def R_C(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (17)
  const C_bar_prime_pow_7 = pow(C_bar_prime(L1, a1, b1, L2, a2, b2), 7)
  return 2.0 * sqrt(C_bar_prime_pow_7 / (C_bar_prime_pow_7 + pow(25, 7)))
enddef

def S_L(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (18)
  const L_bar = L_bar_prime(L1, a1, b1, L2, a2, b2)
  const L_bar_minus_50_square = (L_bar - 50.0) * (L_bar - 50.0)
  return 1.0 + ((0.015 * L_bar_minus_50_square) / sqrt(20.0 + L_bar_minus_50_square))
enddef

def S_C(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (19)
  return 1.0 + 0.045 * C_bar_prime(L1, a1, b1, L2, a2, b2)
enddef

def S_H(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (20)
  return 1.0 + 0.015 * T(L1, a1, b1, L2, a2, b2) * C_bar_prime(L1, a1, b1, L2, a2, b2)
enddef

def R_T(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (21)
  return -R_C(L1, a1, b1, L2, a2, b2) * sin(DegToRad(2 * Delta_theta(L1, a1, b1, L2, a2, b2)))
enddef

def TestDeltaE(L1: float, a1: float, b1: float, L2: float, a2: float, b2: float): float
  # Eq (22)
  const k_L = 1.0
  const k_C = 1.0
  const k_H = 1.0
  const delta_L_prime_div_k_L_S_L = Delta_L_prime(L1, a1, b1, L2, a2, b2) / (S_L(L1, a1, b1, L2, a2, b2) * k_L)
  const delta_C_prime_div_k_C_S_C = Delta_C_prime(L1, a1, b1, L2, a2, b2) / (S_C(L1, a1, b1, L2, a2, b2) * k_C)
  const delta_H_prime_div_k_H_S_H = Delta_H_prime(L1, a1, b1, L2, a2, b2) / (S_H(L1, a1, b1, L2, a2, b2) * k_H)
  const R_T_ = R_T(L1, a1, b1, L2, a2, b2)

  return sqrt(
    delta_L_prime_div_k_L_S_L * delta_L_prime_div_k_L_S_L
    + delta_C_prime_div_k_C_S_C * delta_C_prime_div_k_C_S_C
    + delta_H_prime_div_k_H_S_H * delta_H_prime_div_k_H_S_H
    + R_T_ * delta_C_prime_div_k_C_S_C * delta_H_prime_div_k_H_S_H
  )
enddef
# }}}

def Test_Color_DeltaCIEDE2000()
  # Test data from https://hajim.rochester.edu/ece/sites/gsharma/ciede2000/
  # NOTE: some entries in the table above were wrong and have been corrected
  const testCases = [
    #     L1        a1         b1        L2        a2        b2    C_bar      G  a_prime_1 a_prime_2  C_prm_1  C_prm_2   H_prm_1   H_prm_2         dh        dH  L_bar_p  C_bar_p   H_bar_p       T  d_theta     R_C     S_L     S_C     S_H      R_T    Delta
    [50.0000,   2.6772,  -79.7751,  50.0000,   0.0000, -82.7485, 81.2843, 0.0001,   2.6774,   0.0000, 79.8200, 82.7485, 271.9222, 270.0000,   -1.9222,  -2.7264, 50.0000, 81.2843, 270.9611, 0.6907, 29.2271, 1.9997, 1.0000, 4.6578, 1.8421, -1.7042,  2.0425],
    [50.0000,   3.1571,  -77.2803,  50.0000,   0.0000, -82.7485, 80.0466, 0.0001,   3.1573,   0.0000, 77.3448, 82.7485, 272.3395, 270.0000,   -2.3395,  -3.2664, 50.0000, 80.0466, 271.1698, 0.6843, 29.3040, 1.9997, 1.0000, 4.6021, 1.8216, -1.7070,  2.8615],
    [50.0000,   2.8361,  -74.0200,  50.0000,   0.0000, -82.7485, 78.4114, 0.0001,   2.8363,   0.0000, 74.0743, 82.7485, 272.1944, 270.0000,   -2.1944,  -2.9984, 50.0000, 78.4114, 271.0972, 0.6865, 29.2777, 1.9997, 1.0000, 4.5285, 1.8074, -1.7060,  3.4412],
    [50.0000,  -1.3802,  -84.2814,  50.0000,   0.0000, -82.7485, 83.5206, 0.0001,  -1.3803,   0.0000, 84.2927, 82.7485, 269.0618, 270.0000,    0.9382,   1.3676, 50.0000, 83.5206, 269.5309, 0.7357, 28.5981, 1.9998, 1.0000, 4.7584, 1.9217, -1.6809,  1.0000],
    [50.0000,  -1.1848,  -84.8006,  50.0000,   0.0000, -82.7485, 83.7787, 0.0001,  -1.1849,   0.0000, 84.8089, 82.7485, 269.1995, 270.0000,    0.8005,   1.1704, 50.0000, 83.7787, 269.5997, 0.7335, 28.6323, 1.9998, 1.0000, 4.7700, 1.9218, -1.6822,  1.0000],
    [50.0000,  -0.9009,  -85.5211,  50.0000,   0.0000, -82.7485, 84.1372, 0.0001,  -0.9009,   0.0000, 85.5258, 82.7485, 269.3964, 270.0000,    0.6036,   0.8862, 50.0000, 84.1372, 269.6982, 0.7303, 28.6807, 1.9998, 1.0000, 4.7862, 1.9217, -1.6840,  1.0000],
    [50.0000,   0.0000,    0.0000,  50.0000,  -1.0000,   2.0000,  1.1180, 0.5000,   0.0000,  -1.5000,  0.0000,  2.5000,   0.0000, 126.8697,    0.0000,   0.0000, 50.0000,  1.2500, 126.8697, 1.2200,  0.0000, 0.0001, 1.0000, 1.0562, 1.0229,  0.0000,  2.3669],
    [50.0000,  -1.0000,    2.0000,  50.0000,   0.0000,   0.0000,  1.1180, 0.5000,  -1.5000,   0.0000,  2.5000,  0.0000, 126.8697,   0.0000,    0.0000,   0.0000, 50.0000,  1.2500, 126.8697, 1.2200,  0.0000, 0.0001, 1.0000, 1.0562, 1.0229,  0.0000,  2.3669],
    [50.0000,   2.4900,   -0.0010,  50.0000,  -2.4900,   0.0009,  2.4900, 0.4998,   3.7346,  -3.7346,  3.7346,  3.7346, 359.9847, 179.9862, -179.9985,  -7.4692, 50.0000,  3.7346, 269.9854, 0.7212, 28.8170, 0.0026, 1.0000, 1.1681, 1.0404, -0.0022,  7.1792],
    [50.0000,   2.4900,   -0.0010,  50.0000,  -2.4900,   0.0010,  2.4900, 0.4998,   3.7346,  -3.7346,  3.7346,  3.7346, 359.9847, 179.9847, -180.0000,  -7.4692, 50.0000,  3.7346, 269.9847, 0.7212, 28.8166, 0.0026, 1.0000, 1.1681, 1.0404, -0.0022,  7.1792],
    [50.0000,   2.4900,   -0.0010,  50.0000,  -2.4900,   0.0011,  2.4900, 0.4998,   3.7346,  -3.7346,  3.7346,  3.7346, 359.9847, 179.9831,  179.9985,   7.4692, 50.0000,  3.7346,  89.9839, 0.6175,  0.0000, 0.0026, 1.0000, 1.1681, 1.0346,  0.0000,  7.2195],
    [50.0000,   2.4900,   -0.0010,  50.0000,  -2.4900,   0.0012,  2.4900, 0.4998,   3.7346,  -3.7346,  3.7346,  3.7346, 359.9847, 179.9816,  179.9969,   7.4692, 50.0000,  3.7346,  89.9831, 0.6175,  0.0000, 0.0026, 1.0000, 1.1681, 1.0346,  0.0000,  7.2195],
    [50.0000,  -0.0010,    2.4900,  50.0000,   0.0009,  -2.4900,  2.4900, 0.4998,  -0.0015,   0.0013,  2.4900,  2.4900,  90.0345, 270.0311,  179.9965,   4.9800, 50.0000,  2.4900, 180.0328, 0.9779,  0.0000, 0.0006, 1.0000, 1.1121, 1.0365,  0.0000,  4.8045],
    [50.0000,  -0.0010,    2.4900,  50.0000,   0.0010,  -2.4900,  2.4900, 0.4998,  -0.0015,   0.0015,  2.4900,  2.4900,  90.0345, 270.0345,  180.0000,   4.9800, 50.0000,  2.4900, 180.0345, 0.9779,  0.0000, 0.0006, 1.0000, 1.1121, 1.0365,  0.0000,  4.8045],
    [50.0000,  -0.0010,    2.4900,  50.0000,   0.0011,  -2.4900,  2.4900, 0.4998,  -0.0015,   0.0016,  2.4900,  2.4900,  90.0345, 270.0380, -179.9965,  -4.9800, 50.0000,  2.4900,   0.0362, 1.3197,  0.0000, 0.0006, 1.0000, 1.1121, 1.0493,  0.0000,  4.7461],
    [50.0000,   2.5000,    0.0000,  50.0000,   0.0000,  -2.5000,  2.5000, 0.4998,   3.7496,   0.0000,  3.7496,  2.5000,   0.0000, 270.0000,  -90.0000,  -4.3299, 50.0000,  3.1248, 315.0000, 0.8454,  2.3191, 0.0014, 1.0000, 1.1406, 1.0396, -0.0001,  4.3065],
    [50.0000,   2.5000,    0.0000,  73.0000,  25.0000, -18.0000, 16.6529, 0.3827,   3.4569,  34.5687,  3.4569, 38.9743,   0.0000, 332.4939,  -27.5061,  -5.5190, 61.5000, 21.2156, 346.2470, 1.4453,  0.0089, 0.9812, 1.1608, 1.9547, 1.4599, -0.0003, 27.1492],
    [50.0000,   2.5000,    0.0000,  61.0000,  -5.0000,  29.0000, 15.9639, 0.3981,   3.4954,  -6.9907,  3.4954, 29.8307,   0.0000, 103.5532,  103.5532,  16.0440, 55.5000, 16.6630,  51.7766, 0.6447,  0.0000, 0.4699, 1.0640, 1.7498, 1.1612,  0.0000, 22.8977],
    [50.0000,   2.5000,    0.0000,  56.0000, -27.0000,  -3.0000, 14.8331, 0.4206,   3.5514, -38.3556,  3.5514, 38.4728,   0.0000, 184.4723, -175.5277, -23.3603, 53.0000, 21.0121, 272.2362, 0.6521, 29.6356, 0.9562, 1.0251, 1.9455, 1.2055, -0.8219, 31.9030],
    [50.0000,   2.5000,    0.0000,  58.0000,  24.0000,  15.0000, 15.4010, 0.4098,   3.5244,  33.8342,  3.5244, 37.0102,   0.0000,  23.9095,   23.9095,   4.7315, 54.0000, 20.2673,  11.9548, 1.1031,  0.0000, 0.8651, 1.0400, 1.9120, 1.3353,  0.0000, 19.4535],
    [50.0000,   2.5000,    0.0000,  50.0000,   3.1736,   0.5854,  2.8636, 0.4997,   3.7494,   4.7596,  3.7494,  4.7955,   0.0000,   7.0118,    7.0118,   0.5186, 50.0000,  4.2724,   3.5059, 1.2616,  0.0000, 0.0041, 1.0000, 1.1923, 1.0808,  0.0000,  1.0000],
    [50.0000,   2.5000,    0.0000,  50.0000,   3.2972,   0.0000,  2.8986, 0.4997,   3.7493,   4.9449,  3.7493,  4.9449,   0.0000,   0.0000,    0.0000,   0.0000, 50.0000,  4.3471,   0.0000, 1.3202,  0.0000, 0.0044, 1.0000, 1.1956, 1.0861,  0.0000,  1.0000],
    [50.0000,   2.5000,    0.0000,  50.0000,   1.8634,   0.5757,  2.2252, 0.4999,   3.7497,   2.7949,  3.7497,  2.8536,   0.0000,  11.6391,   11.6391,   0.6634, 50.0000,  3.3017,   5.8196, 1.2197,  0.0000, 0.0017, 1.0000, 1.1486, 1.0604,  0.0000,  1.0000],
    [50.0000,   2.5000,    0.0000,  50.0000,   3.2592,   0.3350,  2.8882, 0.4997,   3.7493,   4.8879,  3.7493,  4.8994,   0.0000,   3.9207,    3.9207,   0.2932, 50.0000,  4.3244,   1.9603, 1.2883,  0.0000, 0.0043, 1.0000, 1.1946, 1.0836,  0.0000,  1.0000],
    [60.2574, -34.0099,   36.2677,  60.4626, -34.1751,  39.4387, 50.9526, 0.0017, -34.0678, -34.2333, 49.7590, 52.2238, 133.2085, 130.9584,   -2.2501,  -2.0018, 60.3600, 50.9914, 132.0835, 1.3010,  0.0000, 1.9932, 1.1427, 3.2946, 1.9951,  0.0000,  1.2644],
    [63.0109, -31.0961,   -5.8663,  62.8187, -29.7946,  -4.0864, 30.8591, 0.0490, -32.6194, -31.2542, 33.1427, 31.5202, 190.1951, 187.4490,   -2.7461,  -1.5490, 62.9148, 32.3315, 188.8221, 0.9402,  0.0002, 1.8527, 1.1831, 2.4549, 1.4560,  0.0000,  1.2630],
    [61.2901,   3.7196,   -5.3901,  61.4292,   2.2480,  -4.9620,  5.9982, 0.4966,   5.5668,   3.3644,  7.7487,  5.9950, 315.9240, 304.1385,  -11.7855,  -1.3995, 61.3597,  6.8719, 310.0313, 0.6952,  4.2110, 0.0218, 1.1586, 1.3092, 1.0717, -0.0032,  1.8731],
    [35.0831, -44.1164,    3.7933,  35.0232, -40.0716,   1.5901, 42.1912, 0.0063, -44.3939, -40.3237, 44.5557, 40.3550, 175.1161, 177.7418,    2.6257,   1.9430, 35.0532, 42.4554, 176.4290, 1.0168,  0.0000, 1.9759, 1.2148, 2.9105, 1.6476,  0.0000,  1.8645],
    [22.7233,  20.0904,  -46.6940,  23.0331,  14.9730, -42.5619, 47.9757, 0.0026,  20.1424,  15.0118, 50.8532, 45.1317, 293.3339, 289.4279,   -3.9060,  -3.2653, 22.8782, 47.9924, 291.3809, 0.3636, 19.5282, 1.9897, 1.4014, 3.1597, 1.2617, -1.2537,  2.0373],
    [36.4612,  47.8580,   18.3852,  36.2715,  50.5065,  21.2231, 53.0262, 0.0013,  47.9197,  50.5716, 51.3256, 54.8444,  20.9901,  22.7660,    1.7759,   1.6444, 36.3664, 53.0850,  21.8781, 0.9239,  0.0000, 1.9949, 1.1943, 3.3888, 1.7357,  0.0000,  1.4146],
    [90.8027,  -2.0831,    1.4410,  91.1528,  -1.6435,   0.0447,  2.0885, 0.4999,  -3.1245,  -2.4651,  3.4408,  2.4655, 155.2410, 178.9612,   23.7202,   1.1972, 90.9778,  2.9531, 167.1011, 1.1546,  0.0000, 0.0011, 1.6110, 1.1329, 1.0511,  0.0000,  1.4441],
    [90.9257,  -0.5406,   -0.9208,  88.6381,  -0.8985,  -0.7239,  1.1108, 0.5000,  -0.8109,  -1.3477,  1.2270,  1.5298, 228.6315, 208.2412,  -20.3903,  -0.4850, 89.7819,  1.3784, 218.4363, 1.3916,  0.1794, 0.0001, 1.5930, 1.0620, 1.0288,  0.0000,  1.5381],
    [6.7747,   -0.2908,   -2.4247,   5.8714,  -0.0985,  -2.2286,  2.3364, 0.4999,  -0.4362,  -0.1477,  2.4636,  2.2335, 259.8025, 266.2073,    6.4048,   0.2621,  6.3231,  2.3486, 263.0049, 0.9556, 23.8310, 0.0005, 1.6517, 1.1057, 1.0337, -0.0004,  0.6377],
    [2.0776,    0.0795,   -1.1350,   0.9033,  -0.0636,  -0.5514,  0.8464, 0.5000,   0.1192,  -0.0954,  1.1412,  0.5596, 275.9978, 260.1842,  -15.8136,  -0.2199,  1.4905,  0.8504, 268.0910, 0.7826, 27.7941, 0.0000, 1.7246, 1.0383, 1.0100,  0.0000,  0.9082],
  ]
  const tol = pow(10, -4)

  for t in testCases
    const [L1, a1, b1]  = [t[0], t[1], t[2]]
    const [L2, a2, b2]  = [t[3], t[4], t[5]]
    const C_bar_        = t[6]
    const G_            = t[7]
    const a_prime_1     = t[8]
    const a_prime_2     = t[9]
    const C_prime_1     = t[10]
    const C_prime_2     = t[11]
    const h_prime_1     = t[12]
    const h_prime_2     = t[13]
    const delta_h_prime = t[14]
    const delta_H_prime = t[15]
    const L_bar_prime_  = t[16]
    const C_bar_prime_  = t[17]
    const H_bar_prime_  = t[18]
    const T_            = t[19]
    const delta_theta_  = t[20]
    const R_C_          = t[21]
    const S_L_          = t[22]
    const S_C_          = t[23]
    const S_H_          = t[24]
    const R_T_          = t[25]
    const CIE2000_      = t[26]

    var msg = printf('%s vs %s', [L1, a1, b1], [L2, a2, b2]) .. ': %s'

    tt.AssertApprox(C_bar_,        C_bar(        L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'C_bar'))
    tt.AssertApprox(G_,            G(            L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'G'))
    tt.AssertApprox(a_prime_1,     A_prime_i(1,  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'a_prime_1'))
    tt.AssertApprox(a_prime_2,     A_prime_i(2,  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'a_prime_2'))
    tt.AssertApprox(C_prime_1,     C_prime_i(1,  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'C_prime_1'))
    tt.AssertApprox(C_prime_2,     C_prime_i(2,  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'C_prime_2'))
    tt.AssertApprox(h_prime_1,     H_prime_i(1,  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'h_prime_1'))
    tt.AssertApprox(h_prime_2,     H_prime_i(2,  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'h_prime_2'))
    tt.AssertApprox(delta_h_prime, Delta_h_prime(L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'delta_h_prime'))
    tt.AssertApprox(delta_H_prime, Delta_H_prime(L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'delta_H_prime'))
    tt.AssertApprox(L_bar_prime_,  L_bar_prime(  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'L_prime_avg'))
    tt.AssertApprox(C_bar_prime_,  C_bar_prime(  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'C_prime_avg'))
    tt.AssertApprox(H_bar_prime_,  H_bar_prime(  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'H_bar_prime'))
    tt.AssertApprox(T_,            T(            L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'T'))
    tt.AssertApprox(delta_theta_,  Delta_theta(  L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'delta_theta'))
    tt.AssertApprox(R_C_,          R_C(          L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'R_C'))
    tt.AssertApprox(S_L_,          S_L(          L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'S_L'))
    tt.AssertApprox(S_C_,          S_C(          L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'S_C'))
    tt.AssertApprox(S_H_,          S_H(          L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'S_H'))
    tt.AssertApprox(R_T_,          R_T(          L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'R_T'))
    tt.AssertApprox(CIE2000_,      TestDeltaE(   L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'Delta (test)'))
    tt.AssertApprox(TestDeltaE(L1, a1, b1, L2, a2, b2), DeltaE2000(L1, a1, b1, L2, a2, b2), 0.0, tol, printf(msg, 'Delta (prod)'))
  endfor
enddef


def Test_Color_DeltaCIEDE2000Simplified()
  # Test data unchanged from https://hajim.rochester.edu/ece/sites/gsharma/ciede2000/dataNprograms/ciede2000testdata.txt
  const testCases = [
    [50.0000,   2.6772, -79.7751, 50.0000,   0.0000, -82.7485,  2.0425],
    [50.0000,   3.1571, -77.2803, 50.0000,   0.0000, -82.7485,  2.8615],
    [50.0000,   2.8361, -74.0200, 50.0000,   0.0000, -82.7485,  3.4412],
    [50.0000,  -1.3802, -84.2814, 50.0000,   0.0000, -82.7485,  1.0000],
    [50.0000,  -1.1848, -84.8006, 50.0000,   0.0000, -82.7485,  1.0000],
    [50.0000,  -0.9009, -85.5211, 50.0000,   0.0000, -82.7485,  1.0000],
    [50.0000,   0.0000,   0.0000, 50.0000,  -1.0000,   2.0000,  2.3669],
    [50.0000,  -1.0000,   2.0000, 50.0000,   0.0000,   0.0000,  2.3669],
    [50.0000,   2.4900,  -0.0010, 50.0000,  -2.4900,   0.0009,  7.1792],
    [50.0000,   2.4900,  -0.0010, 50.0000,  -2.4900,   0.0010,  7.1792],
    [50.0000,   2.4900,  -0.0010, 50.0000,  -2.4900,   0.0011,  7.2195],
    [50.0000,   2.4900,  -0.0010, 50.0000,  -2.4900,   0.0012,  7.2195],
    [50.0000,  -0.0010,   2.4900, 50.0000,   0.0009,  -2.4900,  4.8045],
    [50.0000,  -0.0010,   2.4900, 50.0000,   0.0010,  -2.4900,  4.8045],
    [50.0000,  -0.0010,   2.4900, 50.0000,   0.0011,  -2.4900,  4.7461],
    [50.0000,   2.5000,   0.0000, 50.0000,   0.0000,  -2.5000,  4.3065],
    [50.0000,   2.5000,   0.0000, 73.0000,  25.0000, -18.0000, 27.1492],
    [50.0000,   2.5000,   0.0000, 61.0000,  -5.0000,  29.0000, 22.8977],
    [50.0000,   2.5000,   0.0000, 56.0000, -27.0000,  -3.0000, 31.9030],
    [50.0000,   2.5000,   0.0000, 58.0000,  24.0000,  15.0000, 19.4535],
    [50.0000,   2.5000,   0.0000, 50.0000,   3.1736,   0.5854,  1.0000],
    [50.0000,   2.5000,   0.0000, 50.0000,   3.2972,   0.0000,  1.0000],
    [50.0000,   2.5000,   0.0000, 50.0000,   1.8634,   0.5757,  1.0000],
    [50.0000,   2.5000,   0.0000, 50.0000,   3.2592,   0.3350,  1.0000],
    [60.2574, -34.0099,  36.2677, 60.4626, -34.1751,  39.4387,  1.2644],
    [63.0109, -31.0961,  -5.8663, 62.8187, -29.7946,  -4.0864,  1.2630],
    [61.2901,   3.7196,  -5.3901, 61.4292,   2.2480,  -4.9620,  1.8731],
    [35.0831, -44.1164,   3.7933, 35.0232, -40.0716,   1.5901,  1.8645],
    [22.7233,  20.0904, -46.6940, 23.0331,  14.9730, -42.5619,  2.0373],
    [36.4612,  47.8580,  18.3852, 36.2715,  50.5065,  21.2231,  1.4146],
    [90.8027,  -2.0831,   1.4410, 91.1528,  -1.6435,   0.0447,  1.4441],
    [90.9257,  -0.5406,  -0.9208, 88.6381,  -0.8985,  -0.7239,  1.5381],
    [ 6.7747,  -0.2908,  -2.4247,  5.8714,  -0.0985,  -2.2286,  0.6377],
    [ 2.0776,   0.0795,  -1.1350,  0.9033,  -0.0636,  -0.5514,  0.9082],
  ]

  const tol = pow(10, -4)

  for t in testCases
    const [L1, a1, b1]  = [t[0], t[1], t[2]]
    const [L2, a2, b2]  = [t[3], t[4], t[5]]
    const delta = t[6]

    tt.AssertApprox(delta, TestDeltaE(L1, a1, b1, L2, a2, b2), 0.0, tol, printf('Test case: %s', t))
  endfor
enddef


tt.Run('_Color_')
