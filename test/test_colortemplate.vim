fun! Test_fine()
  edit test1.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
  bwipe!
  bwipe
endf

fun! Test_color_typo()
  edit test2.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Undefined color name: wwhite', l:loclist[0]['text'])
  lclose
  bwipe
endf

fun! Test_invalid_token()
  edit test3.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Invalid token', l:loclist[0]['text'])
  lclose
  bwipe
endf

fun! Test_fg_bg_none_colors()
  edit test4.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(5, len(l:loclist))
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:loclist[0]['text'])
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:loclist[1]['text'])
  call assert_equal("Colors 'none', 'fg', and 'bg' are reserved names and cannot be overridden", l:loclist[2]['text'])
  call assert_equal("The colors for Normal cannot be 'none', 'fg', or 'bg'", l:loclist[3]['text'])
  call assert_equal("Please define the Normal highlight group", l:loclist[4]['text'])
  lclose
  bwipe
endf

fun! Test_Normal_must_be_first()
  edit test5.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal("The Normal highlight group for dark background must be the first defined group", l:loclist[0]['text'])
  call assert_equal("Please define the Normal highlight group", l:loclist[1]['text'])
endf

fun! Test_Normal_alt_background()
  edit test6.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal("Alternate background for Normal group can only be 'none'", l:loclist[0]['text'])
  call assert_equal("Please define the Normal highlight group", l:loclist[1]['text'])
endf

fun! Test_Normal_reverse()
  edit test7.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal("Do not use reverse mode for the Normal group", l:loclist[0]['text'])
  call assert_equal("Please define the Normal highlight group", l:loclist[1]['text'])
endf

fun! Test_extra_chars_after_verbatim()
  edit test8.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal("Extra characters after 'verbatim'", l:loclist[0]['text'])
  call assert_equal(10, l:loclist[0]['lnum'])
  call assert_equal("Extra characters after 'endverbatim'", l:loclist[1]['text'])
  call assert_equal(11, l:loclist[1]['lnum'])
endf

fun! Test_undefined_color_in_verbatim_block()
  edit test9.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(4, len(l:loclist))
  call assert_equal("Undefined color", l:loclist[0]['text'])
  call assert_equal(11, l:loclist[0]['lnum'])
  call assert_equal("Undefined color", l:loclist[1]['text'])
  call assert_equal(12, l:loclist[1]['lnum'])
  call assert_equal("Undefined color", l:loclist[2]['text'])
  call assert_equal(13, l:loclist[2]['lnum'])
  call assert_equal("Undefined color", l:loclist[3]['text'])
  call assert_equal(14, l:loclist[3]['lnum'])
endf

fun! Test_unexpected_token_at_start_of_line()
  edit test10.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Unexpected token at start of line', l:loclist[0]['text'])
  call assert_equal(10, l:loclist[0]['lnum'])
  lclose
  bwipe
endf

fun! Test_invalid_chars_in_key()
  edit test11.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Only alphanumeric characters are allowed in keys', l:loclist[0]['text'])
  call assert_equal(5, l:loclist[0]['lnum'])
  lclose
  bwipe
endf

fun! Test_invalid_background()
  edit test12.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(1, len(l:loclist))
  call assert_equal('Background can only be dark or light.', l:loclist[0]['text'])
  call assert_equal(8, l:loclist[0]['lnum'])
  lclose
  bwipe
endf

fun! Test_unknown_key()
  edit test13.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Unknown key: shortname', l:loclist[0]['text'])
  call assert_equal(3, l:loclist[0]['lnum'])
  call assert_equal('Unknown key: xyz', l:loclist[1]['text'])
  call assert_equal(5, l:loclist[1]['lnum'])
  call assert_equal('Unknown key: abc def', l:loclist[2]['text'])
  call assert_equal(6, l:loclist[2]['lnum'])
  lclose
  bwipe
endf

fun! Test_colon_after_color_key()
  edit test14.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Expected colon after Color keyword', l:loclist[0]['text'])
  call assert_equal(6, l:loclist[0]['lnum'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_invalid_color_name()
  edit test15.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Invalid color name', l:loclist[0]['text'])
  call assert_equal(6, l:loclist[0]['lnum'])
  call assert_equal(8, l:loclist[0]['col'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_invalid_gui_value()
  edit test16.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Invalid GUI color value', l:loclist[0]['text'])
  call assert_equal(6, l:loclist[0]['lnum'])
  call assert_equal(13, l:loclist[0]['col'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_invalid_gui_value_bis()
  edit test17.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(3, len(l:loclist))
  call assert_equal('Only hex and RGB values are allowed', l:loclist[0]['text'])
  call assert_equal(6, l:loclist[0]['lnum'])
  call assert_equal(13, l:loclist[0]['col'])
  call assert_equal("Undefined color name: black", l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[2]['text'])
  lclose
  bwipe
endf

fun! Test_invalid_rgb_values()
  edit test18.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(12, len(l:loclist))
  call assert_equal('Missing opening parenthesis', l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal(17, l:loclist[0]['col'])
  call assert_equal('Expected number', l:loclist[1]['text'])
  call assert_equal(8, l:loclist[1]['lnum'])
  call assert_equal(17, l:loclist[1]['col'])
  call assert_equal('RGB red component value is out of range', l:loclist[2]['text'])
  call assert_equal(9, l:loclist[2]['lnum'])
  call assert_equal(17, l:loclist[2]['col'])
  call assert_equal('Missing comma', l:loclist[3]['text'])
  call assert_equal(10, l:loclist[3]['lnum'])
  call assert_equal(18, l:loclist[3]['col'])
  call assert_equal('Expected number', l:loclist[4]['text'])
  call assert_equal(11, l:loclist[4]['lnum'])
  call assert_equal(19, l:loclist[4]['col'])
  call assert_equal('RGB green component value is out of range', l:loclist[5]['text'])
  call assert_equal(12, l:loclist[5]['lnum'])
  call assert_equal(19, l:loclist[5]['col'])
  call assert_equal('Missing comma', l:loclist[6]['text'])
  call assert_equal(13, l:loclist[6]['lnum'])
  call assert_equal(20, l:loclist[6]['col'])
  call assert_equal('Expected number', l:loclist[7]['text'])
  call assert_equal(14, l:loclist[7]['lnum'])
  call assert_equal(21, l:loclist[7]['col'])
  call assert_equal('RGB blue component value is out of range', l:loclist[8]['text'])
  call assert_equal(15, l:loclist[8]['lnum'])
  call assert_equal(21, l:loclist[8]['col'])
  call assert_equal('Missing closing parenthesis', l:loclist[9]['text'])
  call assert_equal(16, l:loclist[9]['lnum'])
  call assert_equal(23, l:loclist[9]['col'])
  call assert_equal("Undefined color name: black", l:loclist[10]['text'])
  call assert_equal(18, l:loclist[10]['lnum'])
  call assert_equal("Please define the Normal highlight group", l:loclist[11]['text'])
  lclose
  bwipe
endf

fun! Test_base_256_value()
  edit test19.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(6, len(l:loclist))
  call assert_equal('Base-256 color value is out of range', l:loclist[0]['text'])
  call assert_equal(7, l:loclist[0]['lnum'])
  call assert_equal(21, l:loclist[0]['col'])
  call assert_equal('Missing closing single quote', l:loclist[1]['text'])
  call assert_equal(8, l:loclist[1]['lnum'])
  call assert_equal(37, l:loclist[1]['col'])
  call assert_equal('Expected base-256 number or color name', l:loclist[2]['text'])
  call assert_equal(9, l:loclist[2]['lnum'])
  call assert_equal(21, l:loclist[2]['col'])
  call assert_equal("Empty quoted color name", l:loclist[3]['text'])
  call assert_equal(10, l:loclist[3]['lnum'])
  call assert_equal(22, l:loclist[3]['col'])
  call assert_equal("Undefined color name: white", l:loclist[4]['text'])
  call assert_equal(12, l:loclist[4]['lnum'])
  call assert_equal(8, l:loclist[4]['col'])
  call assert_equal("Please define the Normal highlight group", l:loclist[5]['text'])
  lclose
  bwipe
endf

fun! Test_base_16_value()
  edit test20.txt
  Colortemplate
  let l:loclist = getloclist(0)
  call assert_equal(2, len(l:loclist))
  call assert_equal('Expected base-16 number or color name', l:loclist[0]['text'])
  call assert_equal(8, l:loclist[0]['lnum'])
  call assert_equal(23, l:loclist[0]['col'])
  call assert_equal('Base-16 color value is out of range', l:loclist[1]['text'])
  call assert_equal(9, l:loclist[1]['lnum'])
  call assert_equal(23, l:loclist[1]['col'])
  lclose
  bwipe
endf

fun! Test_parse_hi_group_def()
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
  call assert_equal('Missing transparent color name', l:loclist[2]['text'])
  call assert_equal(12, l:loclist[2]['lnum'])
  call assert_equal(18, l:loclist[2]['col'])
  call assert_equal('Undefined color name: reverse', l:loclist[3]['text'])
  call assert_equal(13, l:loclist[3]['lnum'])
  call assert_equal(20, l:loclist[3]['col'])
  lclose
  bwipe
endf

fun! Test_attributes_ok()
  edit test22.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
  bwipe!
  bwipe
endf

fun! Test_attributes_errors()
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

fun! Test_parse_linked_group_ok()
  edit test24.txt
  let l:src = bufnr('%')
  Colortemplate
  let l:tgt = bufnr('%')
  call assert_equal(0, get(g:, 'colortemplate_exit_status', 1))
  call assert_notequal(l:src, l:tgt)
  bwipe!
  bwipe
endf

fun! Test_parse_linked_group_errors()
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

" -----------------------------------------------------------------------------
" DO NOT MODIFY BELOW THIS LINE
" -----------------------------------------------------------------------------
let s:messages = []
let s:errors = []
let s:done = 0
let s:fail = 0

fun! RunTheTest(test)
  let l:message = a:test . '… '
  let s:done += 1
  try
    exe 'call ' . a:test
  catch
    call add(v:errors, 'Caught exception in ' . a:test . ': ' . v:exception . ' @ ' . v:throwpoint)
  endtry

  if len(v:errors) > 0
    let s:fail += 1
    let l:message .= 'FAILED'
    call add(s:errors, a:test)
    call extend(s:errors, v:errors)
    let v:errors = []
  else
    let l:message .= 'ok'
  endif
  call add(s:messages,  l:message)
endfunc

fun! FinishTesting()
  call add(s:messages, '')
  call add(s:messages, 'Run ' . s:done . (s:done > 1 ? ' tests' : ' test'))
  if s:fail == 0
    call add(s:messages, 'ALL TESTS PASSED!')
  else
    call add(s:messages, s:fail . (s:fail > 1 ? ' tests' : ' test') . ' failed')
  endif

  botright new +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile\ wrap
  call append(line('$'), s:messages)
  call append(line('$'), '')
  call append(line('$'), s:errors)
endf

fun! RunBabyRun()
  " Locate Test_ functions and execute them.
  redir @q
  silent function /^Test_
  redir END
  let s:tests = split(substitute(@q, 'function \(\k*()\)', '\1', 'g'))

  for s:test in sort(s:tests) " Run the tests in lexicographic order
    call RunTheTest(s:test)
  endfor

  call FinishTesting()
endf

call RunBabyRun()
