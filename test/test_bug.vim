let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'

fun! Test_CS_bug234()
  for l:col in ['Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'Brown', 'DarkYellow', 'LightGray', 'LightGrey', 'Gray', 'Grey', 'DarkGray', 'DarkGrey', 'Blue', 'LightBlue', 'Green', 'LightGreen', 'Cyan', 'LightCyan', 'Red', 'LightRed', 'Magenta', 'LightMagenta', 'Yellow', 'LightYellow', 'White']
    set background=dark
    execute "hi Normal ctermbg=".l:col
    call assert_equal('xxx', l:col)
    call assert_equal('dark', &bg)
  endfor
endf

fun! Test_CS_bug235()
  for l:col in ['Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'Brown', 'DarkYellow', 'LightGray', 'LightGrey', 'Gray', 'Grey', 'DarkGray', 'DarkGrey', 'Blue', 'LightBlue', 'Green', 'LightGreen', 'Cyan', 'LightCyan', 'Red', 'LightRed', 'Magenta', 'LightMagenta', 'Yellow', 'LightYellow', 'White']
    set background=light
    execute "hi Normal ctermbg=".l:col
    call assert_equal('xxx', l:col)
    call assert_equal('light', &bg)
  endfor
endf

call RunBabyRun('CS')
colo wwdc16

