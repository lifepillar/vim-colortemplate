let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'

let s:eps = 0.000001

fun! s:round(num, digits)
  return str2float(printf('%.0'.a:digits.'f', a:num))
endf

fun! Test_CS_srgb2xyz238238239()
  let [x,y,z] = colortemplate#colorspace#srgb2xyz(238, 238, 239)
  " Values as computed by http://colormine.org/color-converter
  call assert_true(81.41441852841255 - s:eps < x && x < 81.41441852841255 + s:eps)
  call assert_true(85.55820926290504 - s:eps < y && y < 85.55820926290504 + s:eps)
  call assert_true(93.88474076133308 - s:eps < z && z < 93.88474076133308 + s:eps)
endf

fun! Test_CS_srgb2cielab238238239()
  let [L,a,b] = colortemplate#colorspace#rgb2cielab(238, 238, 239)
  " Values as computed by http://colormine.org/color-converter
  call assert_true(94.12313115610355 - s:eps < L && L < 94.12313115610355 + s:eps)
  call assert_true(0.18264247948240886 - s:eps < a && a < 0.18264247948240886 + s:eps)
  call assert_true(-0.49221569623207895 - s:eps < b && b < -0.49221569623207895 + s:eps)
endf

fun! Test_CS_delta_eeeeef()
  let l:res = colortemplate#colorspace#approx('#eeeeef')
  call assert_equal('#eeeeef', l:res['color'])
  call assert_equal(255, l:res['index'])
  call assert_equal('#eeeeee', l:res['approx'])
  call assert_true(0.54422 - s:eps <= l:res['delta'] && l:res['delta'] <= 0.54422 + s:eps)
endf

fun! Test_CS_hex_delta_e()
  let l:delta = colortemplate#colorspace#hex_delta_e('#767676', '#7c6f64')
  call assert_true(7.889685 - s:eps < l:delta && l:delta < 7.889685 + s:eps)
endf

fun! Test_CS_colors_within()
  let l:list = colortemplate#colorspace#colors_within(4.5, '#9e0006')
  call assert_equal(2, len(l:list))
  call assert_equal(88, l:list[0])
  call assert_equal(124, l:list[1])
endf

fun! Test_CS_2_neighbours()
  let l:list = colortemplate#colorspace#k_neighbours('#9e0006', 2)
  call assert_equal(2, len(l:list))
  call assert_equal(124, l:list[0]['index'])
  call assert_equal(88, l:list[1]['index'])
endf

fun! Test_CS_contrast_ratio()
  call assert_equal(1.0, colortemplate#colorspace#contrast_ratio([0,0,0],[0,0,0]))
  call assert_equal(1.0, colortemplate#colorspace#contrast_ratio([255,255,255],[255,255,255]))
  call assert_equal(1.0, colortemplate#colorspace#contrast_ratio([100,100,100],[100,100,100]))
  call assert_equal(21.0, colortemplate#colorspace#contrast_ratio([0,0,0],[255,255,255]))
  call assert_equal(21.0, colortemplate#colorspace#contrast_ratio([255,255,255],[0,0,0]))
  call assert_equal(4.54, s:round(colortemplate#colorspace#contrast_ratio('#707070', '#e1fafa'), 2))
  call assert_equal(4.54, s:round(colortemplate#colorspace#contrast_ratio('#e1fafa', '#707070'), 2))
  call assert_equal(4.52, s:round(colortemplate#colorspace#contrast_ratio('#fafa96', '#707070'), 2))
  call assert_equal(4.52, s:round(colortemplate#colorspace#contrast_ratio('#707070', '#fafa96'), 2))
  call assert_equal(4.56, s:round(colortemplate#colorspace#contrast_ratio('#707070', '#fafaaf'), 2))
  call assert_equal(4.56, s:round(colortemplate#colorspace#contrast_ratio('#fafaaf', '#707070'), 2))
  call assert_equal(4.62, s:round(colortemplate#colorspace#contrast_ratio('#707070', '#fafac8'), 2))
  call assert_equal(4.62, s:round(colortemplate#colorspace#contrast_ratio('#fafac8', '#707070'), 2))
  call assert_equal(4.68, s:round(colortemplate#colorspace#contrast_ratio('#707070', '#fafae1'), 2))
  call assert_equal(4.68, s:round(colortemplate#colorspace#contrast_ratio('#fafae1', '#707070'), 2))
  call assert_equal(4.74, s:round(colortemplate#colorspace#contrast_ratio('#707070', '#fafafa'), 2))
  call assert_equal(4.74, s:round(colortemplate#colorspace#contrast_ratio('#fafafa', '#707070'), 2))
endf

fun! Test_CS_xterm2hex()
  call assert_equal('#000000', colortemplate#colorspace#xterm256_hexvalue(16))
  call assert_equal('#ffffff', colortemplate#colorspace#xterm256_hexvalue(231))
endf

call RunBabyRun('CS')
