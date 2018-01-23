" Source this script to parse all the templates in the templates folder.
" Colorschemes are created inside this plugin's folder.

let s:curdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:errors = 0
let s:exceptions = []

execute 'lcd' s:curdir

for s:template in glob(s:curdir . '/templates/[a-z]*.colortemplate', 1, 1)
  let s:template_name = fnamemodify(s:template, ':t:r')
  if index(s:exceptions, s:template_name) > -1
    continue
  endif
  execute "edit" s:template
  execute "Colortemplate!" fnameescape(s:curdir)
  if g:colortemplate_exit_status != 0
    echoerr 'ERROR:' s:template_name 'could not be built'
    let s:errors = 1
  endif
endfor

if s:errors > 0
  redraw
  echo "\r"
  echoerr "There were errors: see messages"
endif
