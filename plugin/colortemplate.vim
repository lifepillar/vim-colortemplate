if !has('vim9script')
  finish
endif
vim9script

# Name:        Colortemplate
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     MIT

import autoload '../autoload/colortemplate/importer.vim' as importer

command! -nargs=0 -bar ColortemplateImport importer.Import()
