let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'

fun! Test_CT_fine()
  edit test1.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_color_typo()
  edit test2.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Undefined color name: wwhite', l:loclist[0]['text'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_token()
  edit test3.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Invalid token', l:loclist[0]['text'])
  lclose
  bwipe
endf

fun! Test_CT_fg_bg_none_colors()
  edit test4.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(5, len(l:loclist))
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal(8, l:loclist[0]['col'])
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:loclist[1]['text'])
  call assert_equal(8, l:loclist[1]['lnum'])
  call assert_equal(9, l:loclist[1]['col'])
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:loclist[2]['text'])
  call assert_equal(9, l:loclist[2]['lnum'])
  call assert_equal(7, l:loclist[2]['col'])
  call assert_equal("The colors for Normal cannot be 'fg' or 'bg'", l:loclist[3]['text'])
  call assert_equal("Please define the Normal highlight group", l:loclist[4]['text'])
  lclose
  bwipe
endf

fun! Test_CT_Normal_must_be_first()
  edit test5.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_Normal_alt_background()
  edit test6.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal("Invalid token", l:loclist[0]['text'])
  call assert_equal(9, l:loclist[0]['lnum'])
  call assert_equal(19, l:loclist[0]['col'])
  call assert_equal("Please define the Normal highlight group", l:loclist[1]['text'])
endf

fun! Test_CT_Normal_reverse()
  edit test7.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal("Do not use reverse mode for the Normal group", l:loclist[0]['text'])
  call assert_equal("Please define the Normal highlight group", l:loclist[1]['text'])
endf

fun! Test_CT_extra_chars_after_verbatim()
  edit test8.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal("Extra characters after 'verbatim'", l:loclist[0]['text'])
  call assert_equal(10, l:loclist[0]['lnum'])
  call assert_equal("Extra characters after 'endverbatim'", l:loclist[1]['text'])
  call assert_equal(11, l:loclist[1]['lnum'])
endf

fun! Test_CT_undefined_color_in_verbatim_block()
  edit test9.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(4, len(l:loclist))
  call assert_equal("Undefined @ value", l:loclist[0]['text'])
  call assert_equal(11, l:loclist[0]['lnum'])
  call assert_equal("Undefined @ value", l:loclist[1]['text'])
  call assert_equal(12, l:loclist[1]['lnum'])
  call assert_equal("Undefined @ value", l:loclist[2]['text'])
  call assert_equal(13, l:loclist[2]['lnum'])
  call assert_equal("Undefined @ value", l:loclist[3]['text'])
  call assert_equal(14, l:loclist[3]['lnum'])
endf

fun! Test_CT_unexpected_token_at_start_of_line()
  edit test10.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Unexpected token at start of line', l:loclist[0]['text'])
  call assert_equal(10, l:loclist[0]['lnum'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_chars_in_key()
  edit test11.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Only letters from a to z are allowed in keys', l:loclist[0]['text'])
  call assert_equal(5, l:loclist[0]['lnum'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_background()
  edit test12.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(5, len(l:loclist))
  call assert_equal('Background can only be dark or light.', l:loclist[0]['text'])
  call assert_equal(6, l:loclist[0]['lnum'])
  call assert_equal('Missing Background directive before color definition', l:loclist[1]['text'])
  call assert_equal(7, l:loclist[1]['lnum'])
  call assert_equal('Missing Background directive before color definition', l:loclist[2]['text'])
  call assert_equal(8, l:loclist[2]['lnum'])
  call assert_equal('Undefined color name: white', l:loclist[3]['text'])
  call assert_equal(9, l:loclist[3]['lnum'])
  call assert_equal('Please define the Normal highlight group', l:loclist[4]['text'])
  lclose
  bwipe
endf

fun! Test_CT_unknown_key()
  edit test13.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal('Unknown key: xyz', l:loclist[0]['text'])
  call assert_equal(5, l:loclist[0]['lnum'])
  call assert_equal(4, l:loclist[0]['col'])
  call assert_equal('Unknown key: abcdef', l:loclist[1]['text'])
  call assert_equal(6, l:loclist[1]['lnum'])
  call assert_equal(8, l:loclist[1]['col'])
  lclose
  bwipe
endf

fun! Test_CT_colon_after_color_key()
  edit test14.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Expected colon after Color keyword', l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_color_name()
  edit test15.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Invalid color name', l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal(8, l:loclist[0]['col'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_gui_value()
  edit test16.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Invalid GUI color value', l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal(13, l:loclist[0]['col'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_gui_value_bis()
  edit test17.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Only hex and RGB values are allowed', l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal(13, l:loclist[0]['col'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_rgb_values()
  edit test18.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(12, len(l:loclist))
  call assert_equal('Missing opening parenthesis', l:loclist[0]['text'])
  call assert_equal(8, l:loclist[0]['lnum'])
  call assert_equal(17, l:loclist[0]['col'])
  call assert_equal('Expected number', l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal(17, l:loclist[1]['col'])
  call assert_equal('RGB red component value is out of range', l:loclist[2]['text'])
  call assert_equal(10, l:loclist[2]['lnum'])
  call assert_equal(17, l:loclist[2]['col'])
  call assert_equal('Missing comma', l:loclist[3]['text'])
  call assert_equal(11, l:loclist[3]['lnum'])
  call assert_equal(18, l:loclist[3]['col'])
  call assert_equal('Expected number', l:loclist[4]['text'])
  call assert_equal(12, l:loclist[4]['lnum'])
  call assert_equal(19, l:loclist[4]['col'])
  call assert_equal('RGB green component value is out of range', l:loclist[5]['text'])
  call assert_equal(13, l:loclist[5]['lnum'])
  call assert_equal(19, l:loclist[5]['col'])
  call assert_equal('Missing comma', l:loclist[6]['text'])
  call assert_equal(14, l:loclist[6]['lnum'])
  call assert_equal(20, l:loclist[6]['col'])
  call assert_equal('Expected number', l:loclist[7]['text'])
  call assert_equal(15, l:loclist[7]['lnum'])
  call assert_equal(21, l:loclist[7]['col'])
  call assert_equal('RGB blue component value is out of range', l:loclist[8]['text'])
  call assert_equal(16, l:loclist[8]['lnum'])
  call assert_equal(21, l:loclist[8]['col'])
  call assert_equal('Missing closing parenthesis', l:loclist[9]['text'])
  call assert_equal(17, l:loclist[9]['lnum'])
  call assert_equal(23, l:loclist[9]['col'])
  call assert_equal("Undefined color name: black", l:loclist[10]['text'])
  call assert_equal(18, l:loclist[10]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[11]['text'])
  lclose
  bwipe
endf

fun! Test_CT_base_256_value()
  edit test19.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(6, len(l:loclist))
  call assert_equal('Base-256 color value is out of range', l:loclist[0]['text'])
  call assert_equal(8, l:loclist[0]['lnum'])
  call assert_equal(21, l:loclist[0]['col'])
  call assert_equal('Missing closing single quote', l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal(37, l:loclist[1]['col'])
  call assert_equal('Expected base-256 number or color name', l:loclist[2]['text'])
  call assert_equal(10, l:loclist[2]['lnum'])
  call assert_equal(21, l:loclist[2]['col'])
  call assert_equal("Empty quoted color name", l:loclist[3]['text'])
  call assert_equal(11, l:loclist[3]['lnum'])
  call assert_equal(22, l:loclist[3]['col'])
  call assert_equal("Undefined color name: white", l:loclist[4]['text'])
  call assert_equal(12, l:loclist[4]['lnum'])
  call assert_equal(8, l:loclist[4]['col'])
  call assert_equal("Please define the Normal highlight group", l:loclist[5]['text'])
  lclose
  bwipe
endf

fun! Test_CT_base_16_value()
  edit test20.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal('Expected base-16 number or color name', l:loclist[0]['text'])
  call assert_equal(9, l:loclist[0]['lnum'])
  call assert_equal(23, l:loclist[0]['col'])
  call assert_equal('Base-16 color value is out of range', l:loclist[1]['text'])
  call assert_equal(10, l:loclist[1]['lnum'])
  call assert_equal(23, l:loclist[1]['col'])
  lclose
  bwipe
endf

fun! Test_CT_parse_hi_group_def()
  edit test21.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(4, len(l:loclist))
  call assert_equal('Foreground color name missing', l:loclist[0]['text'])
  call assert_equal(10, l:loclist[0]['lnum'])
  call assert_equal(11, l:loclist[0]['col'])
  call assert_equal('Background color name missing', l:loclist[1]['text'])
  call assert_equal(11, l:loclist[1]['lnum'])
  call assert_equal(14, l:loclist[1]['col'])
  call assert_equal('Invalid token', l:loclist[2]['text'])
  call assert_equal(12, l:loclist[2]['lnum'])
  call assert_equal(18, l:loclist[2]['col'])
  call assert_equal('Invalid token', l:loclist[3]['text'])
  call assert_equal(13, l:loclist[3]['lnum'])
  call assert_equal(18, l:loclist[3]['col'])
  lclose
  bwipe
endf

fun! Test_CT_attributes_ok()
  edit test22.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_attributes_errors()
  edit test23.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(7, len(l:loclist))
  call assert_equal('Invalid attributes', l:loclist[0]['text'])
  call assert_equal(10, l:loclist[0]['lnum'])
  call assert_equal(19, l:loclist[0]['col'])
  call assert_equal('Invalid attributes', l:loclist[1]['text'])
  call assert_equal(11, l:loclist[1]['lnum'])
  call assert_equal(19, l:loclist[1]['col'])
  call assert_equal('Invalid attribute list', l:loclist[2]['text'])
  call assert_equal(12, l:loclist[2]['lnum'])
  call assert_equal(24, l:loclist[2]['col'])
  call assert_equal('Invalid attribute list', l:loclist[3]['text'])
  call assert_equal(13, l:loclist[3]['lnum'])
  call assert_equal(24, l:loclist[3]['col'])
  call assert_equal("Expected = symbol after 'term'", l:loclist[4]['text'])
  call assert_equal(14, l:loclist[4]['lnum'])
  call assert_equal(20, l:loclist[4]['col'])
  call assert_equal('Invalid attribute', l:loclist[5]['text'])
  call assert_equal(15, l:loclist[5]['lnum'])
  call assert_equal(21, l:loclist[5]['col'])
  call assert_equal("Expected = symbol after 'gui'", l:loclist[6]['text'])
  call assert_equal(16, l:loclist[6]['lnum'])
  call assert_equal(20, l:loclist[6]['col'])
  lclose
  bwipe
endf

fun! Test_CT_parse_linked_group_ok()
  edit test24.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_parse_linked_group_errors()
  edit test25.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Expected highlight group name', l:loclist[0]['text'])
  call assert_equal(10, l:loclist[0]['lnum'])
  call assert_equal(14, l:loclist[0]['col'])
  call assert_equal('Expected ->', l:loclist[1]['text'])
  call assert_equal(11, l:loclist[1]['lnum'])
  call assert_equal(14, l:loclist[1]['col'])
  call assert_equal('Expected highlight group name', l:loclist[2]['text'])
  call assert_equal(12, l:loclist[2]['lnum'])
  call assert_equal(17, l:loclist[2]['col'])
  lclose
  bwipe
endf

fun! Test_CT_minimal()
  edit test27.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_verbatim_interpolation()
  edit test28.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_wrong_keyword_in_doc()
  edit test29.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal("Undefined keyword", l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal(1, l:loclist[0]['col'])
  lclose
  bwipe
endf

fun! Test_CT_keyword_followed_by_underscore_in_doc()
  edit test30.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_empty_short_name()
  edit test31.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal("Please specify a short name for your colorscheme", l:loclist[0]['text'])
  lclose
  bwipe
endf

fun! Test_CT_invalid_short_name()
  edit test32.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal("The short name may contain only letters, numbers and underscore.", l:loclist[0]['text'])
  lclose
  bwipe
endf

fun! Test_CT_commented_hex_color()
  edit test33.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_comments_after_hi_group_defs()
  edit test34.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
endf

fun! Test_CT_color_already_defined()
  edit test35.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal("Color already defined for dark background", l:loclist[0]['text'])
  call assert_equal(9, l:loclist[0]['lnum'])
  call assert_equal(7, l:loclist[0]['col'])
  lclose
  bwipe
endf

fun! Test_CT_background_after_color()
  edit test36.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Missing Background directive before color definition', l:loclist[0]['text'])
  call assert_equal(6, l:loclist[0]['lnum'])
  call assert_equal(6, l:loclist[0]['col'])
  lclose
  bwipe
endf

fun! Test_CT_background_selected_twice()
  edit test37.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Cannot select dark background more than once', l:loclist[0]['text'])
  call assert_equal(8, l:loclist[0]['lnum'])
  call assert_equal(11, l:loclist[0]['col'])
  lclose
  bwipe
endf

call RunBabyRun('CT')
