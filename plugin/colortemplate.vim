vim9script

# Name:        Colortemplate
# Author:      Lifepillar <lifepillar@lifepillar.me>
# Maintainer:  Lifepillar <lifepillar@lifepillar.me>
# License:     Vim license (see `:help license`)

import '../autoload/v3/importer.vim' as importer

command! -nargs=0 -bar ColortemplateImport importer.Import()
