" Source me!
let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:colordir = s:testdir . '/colors'
let s:docdir = s:testdir . '/doc'
execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'

let s:eps = 0.000001

"
" Helper functions
"

fun! s:round(num, digits)
  return str2float(printf('%.0'.a:digits.'f', a:num))
endf

fun! s:verify(f)
  let l:fail = assert_equalfile(s:testdir.'/expected/'.a:f.'.vim', s:testdir.'/colors/'.a:f.'.vim')
  if !l:fail
    call delete(s:testdir.'/colors/'.a:f.'.vim')
  endif
endf

fun! s:assert_build(name)
  execute 'edit' a:name.'.txt'
  Colortemplate!
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call s:verify(a:name)
  execute 'bwipe' a:name.'.txt'
endf

"
" The tests
"

fun! Test_CT_srgb2xyz238238239()
  let [x,y,z] = colortemplate#colorspace#srgb2xyz(238, 238, 239)
  " Values as computed by http://colormine.org/color-converter
  call assert_true(81.41441852841255 - s:eps < x && x < 81.41441852841255 + s:eps)
  call assert_true(85.55820926290504 - s:eps < y && y < 85.55820926290504 + s:eps)
  call assert_true(93.88474076133308 - s:eps < z && z < 93.88474076133308 + s:eps)
endf

fun! Test_CT_srgb2cielab238238239()
  let [L,a,b] = colortemplate#colorspace#rgb2cielab(238, 238, 239)
  " Values as computed by http://colormine.org/color-converter
  call assert_true(94.12313115610355 - s:eps < L && L < 94.12313115610355 + s:eps)
  call assert_true(0.18264247948240886 - s:eps < a && a < 0.18264247948240886 + s:eps)
  call assert_true(-0.49221569623207895 - s:eps < b && b < -0.49221569623207895 + s:eps)
endf

fun! Test_CT_delta_eeeeef()
  let l:res = colortemplate#colorspace#approx('#eeeeef')
  call assert_equal('#eeeeef', l:res['color'])
  call assert_equal(255, l:res['index'])
  call assert_equal('#eeeeee', l:res['approx'])
  call assert_true(0.54422 - s:eps <= l:res['delta'] && l:res['delta'] <= 0.54422 + s:eps)
endf

fun! Test_CT_hex_delta_e()
  let l:delta = colortemplate#colorspace#hex_delta_e('#767676', '#7c6f64')
  call assert_true(7.889685 - s:eps < l:delta && l:delta < 7.889685 + s:eps)
endf

fun! Test_CT_colors_within()
  let l:list = colortemplate#colorspace#colors_within(4.5, '#9e0006')
  call assert_equal(2, len(l:list))
  call assert_equal(88, l:list[0])
  call assert_equal(124, l:list[1])
endf

fun! Test_CT_2_neighbours()
  let l:list = colortemplate#colorspace#k_neighbours('#9e0006', 2)
  call assert_equal(2, len(l:list))
  call assert_equal(124, l:list[0]['index'])
  call assert_equal(88, l:list[1]['index'])
endf

fun! Test_CT_contrast_ratio()
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

fun! Test_CT_xterm2hex()
  call assert_equal('#000000', colortemplate#colorspace#xterm256_hexvalue(16))
  call assert_equal('#ffffff', colortemplate#colorspace#xterm256_hexvalue(231))
endf

fun! Test_CT_hex2gray()
  call assert_equal(0, colortemplate#colorspace#hex2gray('#000000'))
  call assert_equal(64, colortemplate#colorspace#hex2gray('#404040'))
  call assert_equal(127, colortemplate#colorspace#hex2gray('#7f7f7F'))
  call assert_equal(191, colortemplate#colorspace#hex2gray('#bfbfbf'))
  call assert_equal(255, colortemplate#colorspace#hex2gray('#ffffff'))
  call assert_equal(84, colortemplate#colorspace#hex2gray('#405952'))
  call assert_equal(153, colortemplate#colorspace#hex2gray('#9c9b7a'))
  call assert_equal(218, colortemplate#colorspace#hex2gray('#ffd393'))
  call assert_equal(177, colortemplate#colorspace#hex2gray('#ff974f'))
  call assert_equal(137, colortemplate#colorspace#hex2gray('#f54f29'))
endf

fun! Test_CT_fine()
  call s:assert_build('test1')
endf

fun! Test_CT_color_typo()
  edit test2.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Undefined color name: wwhite', l:qflist[0]['text'])
  cclose
  bwipe test2.txt
endf

fun! Test_CT_invalid_token()
  edit test3.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Invalid token', l:qflist[0]['text'])
  cclose
  bwipe test3.txt
endf

fun! Test_CT_fg_bg_none_colors()
  edit test4.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal("'none' is a reserved name and cannot be overridden", l:qflist[0]['text'])
  call assert_equal(7, l:qflist[0]['lnum'])
  call assert_equal(8, l:qflist[0]['col'])
  call assert_equal("'fg' is a reserved name and cannot be overridden", l:qflist[1]['text'])
  call assert_equal(8, l:qflist[1]['lnum'])
  call assert_equal(9, l:qflist[1]['col'])
  call assert_equal("'bg' is a reserved name and cannot be overridden", l:qflist[2]['text'])
  call assert_equal(9, l:qflist[2]['lnum'])
  call assert_equal(7, l:qflist[2]['col'])
  cclose
  bwipe test4.txt
endf

fun! Test_CT_Normal_must_be_first()
  call s:assert_build('test5')
endf

fun! Test_CT_Normal_alt_background()
  edit test6.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal("Invalid token", l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(19, l:qflist[0]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[1]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[2]['text'])
  cclose
  bwipe test6.txt
endf

" reverse in Normal is accepted by Colortemplate! v2.0, but should be
" detected by Vim's check_colors.vim script.
fun! Test_CT_Normal_reverse()
  call s:assert_build('test7')
endf

fun! Test_CT_extra_chars_after_verbatim()
  edit test8.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Extra characters after 'verbatim'", l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal("Extra characters after 'endverbatim'", l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  cclose
  bwipe test8.txt
endf

fun! Test_CT_undefined_color_in_verbatim_block()
  edit test9.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal("Undefined @ value", l:qflist[0]['text'])
  call assert_equal(12, l:qflist[0]['lnum'])
  call assert_equal("Undefined @ value", l:qflist[1]['text'])
  call assert_equal(13, l:qflist[1]['lnum'])
  call assert_equal("Undefined @ value", l:qflist[2]['text'])
  call assert_equal(14, l:qflist[2]['lnum'])
  call assert_equal("Undefined @ value", l:qflist[3]['text'])
  call assert_equal(15, l:qflist[3]['lnum'])
  cclose
  bwipe test9.txt
endf

fun! Test_CT_unexpected_token_at_start_of_line()
  edit test10.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Unexpected token at start of line', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  cclose
  bwipe test10.txt
endf

fun! Test_CT_invalid_chars_in_key()
  edit test11.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Only letters from a to z and underscores are allowed in keys', l:qflist[0]['text'])
  call assert_equal(5, l:qflist[0]['lnum'])
  cclose
  bwipe test11.txt
endf

fun! Test_CT_invalid_background()
  edit test12.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Background can only be 'dark', 'light' or 'any'", l:qflist[0]['text'])
  call assert_equal("Cannot define highlight group before Variant or Background is set", l:qflist[1]['text'])
  cclose
  bwipe test12.txt
endf

fun! Test_CT_unknown_key()
  edit test13.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Metadata value cannot be empty', l:qflist[0]['text'])
  call assert_equal(5, l:qflist[0]['lnum'])
  call assert_equal(4, l:qflist[0]['col'])
  call assert_equal('Unknown key: abcdef', l:qflist[1]['text'])
  call assert_equal(6, l:qflist[1]['lnum'])
  call assert_equal(8, l:qflist[1]['col'])
  cclose
  bwipe test13.txt
endf

fun! Test_CT_colon_after_color_key()
  edit test14.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal('Expected colon after Color keyword', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  cclose
  bwipe test14.txt
endf

fun! Test_CT_invalid_color_name()
  edit test15.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal('Invalid color name', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal(8, l:qflist[0]['col'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal("Please define the Normal highlight group for 16-color variant", l:qflist[2]['text'])
  cclose
  bwipe test15.txt
endf

fun! Test_CT_invalid_gui_value()
  edit test16.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(5, len(l:qflist))
  call assert_equal('Invalid GUI color value', l:qflist[0]['text'])
  call assert_equal(7, l:qflist[0]['lnum'])
  call assert_equal(13, l:qflist[0]['col'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  call assert_equal("Please define the Normal highlight group for 2-color variant", l:qflist[4]['text'])
  cclose
  bwipe test16.txt
endf

fun! Test_CT_invalid_gui_value_bis()
  edit test17.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(5, len(l:qflist))
  call assert_equal('Expected number or tilde', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal(17, l:qflist[0]['col'])
  call assert_equal("Undefined color name: black", l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  call assert_equal("Please define the Normal highlight group for 8-color variant", l:qflist[4]['text'])
  cclose
  bwipe test17.txt
endf

fun! Test_CT_invalid_rgb_values()
  edit test18.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(14, len(l:qflist))
  call assert_equal('Missing opening parenthesis', l:qflist[0]['text'])
  call assert_equal(8, l:qflist[0]['lnum'])
  call assert_equal(17, l:qflist[0]['col'])
  call assert_equal('Expected number', l:qflist[1]['text'])
  call assert_equal(9, l:qflist[1]['lnum'])
  call assert_equal(17, l:qflist[1]['col'])
  call assert_equal('RGB red component value is out of range', l:qflist[2]['text'])
  call assert_equal(10, l:qflist[2]['lnum'])
  call assert_equal(17, l:qflist[2]['col'])
  call assert_equal('Missing comma', l:qflist[3]['text'])
  call assert_equal(11, l:qflist[3]['lnum'])
  call assert_equal(18, l:qflist[3]['col'])
  call assert_equal('Expected number', l:qflist[4]['text'])
  call assert_equal(13, l:qflist[4]['lnum'])
  call assert_equal(19, l:qflist[4]['col'])
  call assert_equal('RGB green component value is out of range', l:qflist[5]['text'])
  call assert_equal(14, l:qflist[5]['lnum'])
  call assert_equal(19, l:qflist[5]['col'])
  call assert_equal('Missing comma', l:qflist[6]['text'])
  call assert_equal(15, l:qflist[6]['lnum'])
  call assert_equal(20, l:qflist[6]['col'])
  call assert_equal('Expected number', l:qflist[7]['text'])
  call assert_equal(16, l:qflist[7]['lnum'])
  call assert_equal(21, l:qflist[7]['col'])
  call assert_equal('RGB blue component value is out of range', l:qflist[8]['text'])
  call assert_equal(17, l:qflist[8]['lnum'])
  call assert_equal(21, l:qflist[8]['col'])
  call assert_equal('Missing closing parenthesis', l:qflist[9]['text'])
  call assert_equal(18, l:qflist[9]['lnum'])
  call assert_equal(23, l:qflist[9]['col'])
  call assert_equal("Undefined color name: black", l:qflist[10]['text'])
  call assert_equal(19, l:qflist[10]['lnum'])
  call assert_equal(14, l:qflist[10]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[11]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[12]['text'])
  call assert_equal("Please define the Normal highlight group for 88-color variant", l:qflist[13]['text'])
  cclose
  bwipe test18.txt
endf

fun! Test_CT_base_256_value()
  edit test19.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal('Color value is out of range [0,255]', l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(21, l:qflist[0]['col'])
  call assert_equal('Expected number or tilde', l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(21, l:qflist[1]['col'])
  call assert_equal("Undefined color name: white", l:qflist[2]['text'])
  call assert_equal(11, l:qflist[2]['lnum'])
  call assert_equal(8, l:qflist[2]['col'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  cclose
  bwipe test19.txt
endf

fun! Test_CT_base_16_value()
  edit test20.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Expected number or color name', l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(23, l:qflist[0]['col'])
  call assert_equal('Color value is out of range [0,15]', l:qflist[1]['text'])
  call assert_equal(10, l:qflist[1]['lnum'])
  call assert_equal(23, l:qflist[1]['col'])
  cclose
  bwipe test20.txt
endf

fun! Test_CT_parse_hi_group_def()
  edit test21.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal('Foreground color name missing', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(11, l:qflist[0]['col'])
  call assert_equal('Background color name missing', l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal('Invalid token', l:qflist[2]['text'])
  call assert_equal(12, l:qflist[2]['lnum'])
  call assert_equal(18, l:qflist[2]['col'])
  call assert_equal('Invalid token', l:qflist[3]['text'])
  call assert_equal(13, l:qflist[3]['lnum'])
  call assert_equal(18, l:qflist[3]['col'])
  cclose
  bwipe test21.txt
endf

fun! Test_CT_attributes_ok()
  call s:assert_build('test22')
endf

fun! Test_CT_attributes_errors()
  edit test23.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(7, len(l:qflist))
  call assert_equal('Invalid attributes', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(19, l:qflist[0]['col'])
  call assert_equal('Invalid attributes', l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(19, l:qflist[1]['col'])
  call assert_equal('Invalid attribute list', l:qflist[2]['text'])
  call assert_equal(12, l:qflist[2]['lnum'])
  call assert_equal(24, l:qflist[2]['col'])
  call assert_equal('Invalid attribute list', l:qflist[3]['text'])
  call assert_equal(13, l:qflist[3]['lnum'])
  call assert_equal(24, l:qflist[3]['col'])
  call assert_equal("Expected = symbol after 'term'", l:qflist[4]['text'])
  call assert_equal(14, l:qflist[4]['lnum'])
  call assert_equal(20, l:qflist[4]['col'])
  call assert_equal('Invalid attribute', l:qflist[5]['text'])
  call assert_equal(15, l:qflist[5]['lnum'])
  call assert_equal(21, l:qflist[5]['col'])
  call assert_equal("Expected = symbol after 'gui'", l:qflist[6]['text'])
  call assert_equal(16, l:qflist[6]['lnum'])
  call assert_equal(20, l:qflist[6]['col'])
  cclose
  bwipe test23.txt
endf

fun! Test_CT_parse_linked_group_ok()
  call s:assert_build('test24')
endf

fun! Test_CT_parse_linked_group_errors()
  edit test25.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(3, len(l:qflist))
  call assert_equal('Expected highlight group name', l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(14, l:qflist[0]['col'])
  call assert_equal('Expected ->', l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(14, l:qflist[1]['col'])
  call assert_equal('Expected highlight group name', l:qflist[2]['text'])
  call assert_equal(12, l:qflist[2]['lnum'])
  call assert_equal(17, l:qflist[2]['col'])
  cclose
  bwipe test25.txt
endf

fun! Test_CT_minimal()
  call s:assert_build('test27')
endf

fun! Test_CT_verbatim_interpolation()
  call s:assert_build('test28')
endf

fun! Test_CT_doc_interpolation()
  call s:assert_build('test29')
  " Check help file
  let l:fail = assert_equalfile(s:testdir.'/expected/test29.txt', s:testdir.'/doc/test29.txt')
  if !l:fail
    call delete(s:testdir.'/doc/test29.txt')
  endif
endf

fun! Test_CT_keyword_followed_by_underscore_in_doc()
  call s:assert_build('test30')
endf

fun! Test_CT_empty_short_name()
  edit test31.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Metadata value cannot be empty", l:qflist[0]['text'])
  call assert_equal("Please specify the short name of your color scheme", l:qflist[1]['text'])
  cclose
  bwipe test31.txt
endf

fun! Test_CT_invalid_short_name()
  edit test32.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("The short name may contain only letters, numbers and underscore", l:qflist[0]['text'])
  call assert_equal(3, l:qflist[0]['lnum'])
  call assert_equal(11, l:qflist[0]['col'])
  cclose
  bwipe test32.txt
endf

fun! Test_CT_commented_hex_color()
  call s:assert_build('test33')
endf

fun! Test_CT_comments_after_hi_group_defs()
  call s:assert_build('test34')
endf

fun! Test_CT_color_already_defined()
  edit test35.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("Color already defined for dark background", l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(25, l:qflist[0]['col'])
  cclose
  bwipe test35.txt
endf
"
fun! Test_CT_color_def_before_background_is_set()
  edit test36.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Undefined color name: black', l:qflist[0]['text'])
  call assert_equal(14, l:qflist[0]['lnum'])
  call assert_equal(19, l:qflist[0]['col'])
  cclose
  bwipe test36.txt
endf

fun! Test_CT_background_selected_twice()
  call s:assert_build('test37')
endf

fun! Test_CT_template_with_included_files()
  call s:assert_build('test38a')
endf

fun! Test_CT_error_in_included_file()
  edit test39a.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Undefined color name: pink', l:qflist[0]['text'])
  call assert_equal('test39b.txt', bufname(l:qflist[0]['bufnr']))
  call assert_equal(5, l:qflist[0]['lnum'])
  call assert_equal(14, l:qflist[0]['col'])
  cclose
  bwipe test39a.txt
endf

fun! Test_CT_short_name_too_long()
  edit test40.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("The short name must be at most 24 characters long", l:qflist[0]['text'])
  call assert_equal(3, l:qflist[0]['lnum'])
  call assert_equal(11, l:qflist[0]['col'])
  cclose
  bwipe test40.txt
endf

fun! Test_CT_comment_after_base256_color()
  call s:assert_build('test41')
endf

fun! Test_CT_colors_from_rgb_txt()
  call s:assert_build('test42')
endf

fun! Test_CT_trailing_spaces_are_skipped()
  call s:assert_build('test43')
endf

fun! Test_CT_first_line_of_included_file_is_not_skipped()
  call s:assert_build('test44a')
endf

fun! Test_CT_check_for_missing_short_name()
  edit test45.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Please specify the short name of your color scheme', l:qflist[0]['text'])
  cclose
  bwipe test45.txt
endf

fun! Test_CT_include_empty_file()
  call s:assert_build('test46a')
endf

" Palette keyword no longer supported in v2.0.0
fun! Test_CT_use_vimspectr_palette()
  edit test47.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Unknown key: palette', l:qflist[0]['text'])
  cclose
  bwipe test47.txt
endf

fun! Test_CT_multiple_nested_inclusions()
  edit test48a.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal("Unexpected token at start of line", l:qflist[0]['text'])
  call assert_equal(3, l:qflist[0]['lnum'])
  call assert_equal(3, l:qflist[0]['col'])
  call assert_equal("Unexpected token at start of line", l:qflist[1]['text'])
  call assert_equal(9, l:qflist[1]['lnum'])
  call assert_equal(6, l:qflist[1]['col'])
  cclose
  bwipe test48a.txt
endf

fun! Test_CT_sequential_inclusions()
  edit test49a.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal("Unexpected token at start of line", l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(6, l:qflist[0]['col'])
  cclose
  bwipe test49a.txt
endf

" If terminal colors are not defined, v2.0.0 raises only a warning
fun! Test_CT_terminal_ansi_colors_not_defined()
  call s:assert_build('test50a')
endf

" Ditto
fun! Test_CT_terminal_ansi_colors_defined_verbatim()
  call s:assert_build('test50b')
endf

fun! Test_CT_rgb_color_names_stats_issue_12()
  edit test51.txt
  " ColortemplateStats parses the file: parsing should not give errors
  ColortemplateStats
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  execute 'write' s:testdir.'/colors/test51.txt'
  let l:fail = assert_equalfile(s:testdir.'/expected/test51.txt', s:testdir.'/colors/test51.txt')
  if !l:fail
    call delete(s:testdir.'/colors/test51.txt')
  endif
  wincmd c " Wipe out stat scratch buffer
  bwipe test51.txt
endf

fun! Test_CT_out_of_range_base256_colors()
  edit test52.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(4, len(l:qflist))
  call assert_equal("Color value is out of range [0,255]", l:qflist[0]['text'])
  call assert_equal(10, l:qflist[0]['lnum'])
  call assert_equal(21, l:qflist[0]['col'])
  call assert_equal("Undefined color name: white", l:qflist[1]['text'])
  call assert_equal(11, l:qflist[1]['lnum'])
  call assert_equal(8, l:qflist[1]['col'])
  call assert_equal("Please define the Normal highlight group for true-color variant", l:qflist[2]['text'])
  call assert_equal("Please define the Normal highlight group for 256-color variant", l:qflist[3]['text'])
  cclose
  bwipe test52.txt
endf

fun! Test_CT_colon_in_comment_is_not_kv_pair()
  call s:assert_build('test53')
endf

fun! Test_CT_color_typo()
  edit test54.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Invalid attribute', l:qflist[0]['text'])
  call assert_equal(17, l:qflist[0]['lnum'])
  call assert_equal(25, l:qflist[0]['col'])
  cclose
  bwipe test54.txt
endf

fun! Test_CT_color_typo()
  edit test57.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Cannot define highlight group before Variant or Background is set', l:qflist[0]['text'])
  call assert_equal(9, l:qflist[0]['lnum'])
  call assert_equal(24, l:qflist[0]['col'])
  cclose
  bwipe test57.txt
endf

fun! Test_CT_conditional_commands()
  call s:assert_build('test58')
endf

fun! Test_CT_italic_is_flushed_before_command()
  call s:assert_build('test59')
endf

fun! Test_CT_let_unlet()
  call s:assert_build('test60')
endf

fun! Test_CT_global_interpolation()
  call s:assert_build('test61')
endf

fun! Test_CT_call_command()
  call s:assert_build('test63')
endf

fun! Test_CT_if_in_multiple_variants()
  call s:assert_build('test64')
endf

fun! Test_CT_guifg_guibg_none()
  call s:assert_build('test65')
endf

fun! Test_CT_unbalanced_if()
  edit test66.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('#if without #endif', l:qflist[0]['text'])
  cclose
  bwipe test66.txt
endf

fun! Test_CT_include_without_suffix()
  call s:assert_build('test68a')
endf

fun! Test_CT_undefined_base16_value()
  edit test69.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(1, len(l:qflist))
  call assert_equal('Base-16 value undefined for color black', l:qflist[0]['text'])
  cclose
  bwipe test69.txt
endf

fun! Test_CT_omit_keyword_basic()
  call s:assert_build('test70')
endf

fun! Test_CT_vacuous_hi_group()
  edit test71.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Vacuous definition for Normal (8 colors, dark background)', l:qflist[0]['text'])
  call assert_equal('Vacuous definition for CursorLine (2 colors, dark background)', l:qflist[1]['text'])
  cclose
  bwipe test71.txt
endf

fun! Test_CT_terminal_colors_in_preamble()
  call s:assert_build('test72')
endf

fun! Test_CT_use_tabs()
  call s:assert_build('test73')
endf

fun! Test_CT_ctermfg_ctermbg_is_none()
  call s:assert_build('test74')
endf

fun! Test_CT_linked_group_with_multiple_tokens()
  edit test75.txt
  Colortemplate!
  let l:qflist = getqflist()
  call assert_equal(2, len(l:qflist))
  call assert_equal('Extra token in linked group definition', l:qflist[0]['text'])
  call assert_equal(11, l:qflist[0]['lnum'])
  call assert_equal(13, l:qflist[0]['col'])
  call assert_equal('Extra token in linked group definition', l:qflist[1]['text'])
  call assert_equal(13, l:qflist[1]['lnum'])
  call assert_equal(20, l:qflist[1]['col'])
  cclose
  bwipe test75.txt
endf

fun! Test_CT_ignore_missing_linked_groups()
  call s:assert_build('test76')
endf

" See: https://github.com/lifepillar/vim-colortemplate/issues/36
" When defining a base 256 color as 0 (code for terminal black) with Color and
" then setting a highlight to it, it used to be ignored.
fun! Test_CT_zero_on_256_colors_is_not_ignored()
  call s:assert_build('test77')
endf

fun! Test_CT_arrows_in_comments_are_not_parsed_as_linked_groups()
  call s:assert_build('test78')
endf

fun! Test_CT_colors_0_16_in_base256_do_not_cause_base16_color_undefined()
  call s:assert_build('test79')
endf

fun! Test_CT_silent_call_command()
  call s:assert_build('test80')
endf

fun! Test_CT_upper_case_hex_colors()
  call s:assert_build('test82')
endf


"
" Runner!
"
let s:exit = RunBabyRun('CT')

call delete(s:colordir, "d") " Delete if empty
call delete(s:docdir, "rf")

if get(g:, 'autotest', 0)
  if s:exit > 0
    execute "write" s:testdir.'/test.log'
    cquit
  else
    call delete(s:testdir.'/test.log')
    qall!
  endif
endif

" vim: nowrap et ts=2 sw=2
