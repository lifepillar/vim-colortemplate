# The Toolkit for Vim Color Scheme Designers!

Colortemplate is a 100% VimScript plugin for Vim 8 or later, which makes it easy
to develop color schemes. Its ambitious goal is to become *the* way to create
new color schemes for Vim!

<img src="https://raw.github.com/lifepillar/Resources/master/colortemplate/colortemplate.gif" width="520">

## Features

- Generates color schemes that support all environments, from black&white to
  millions of colors, and both terminal and GUI Vim.
- Generates color schemes that load efficiently and have a consistent structure
  following best practices.
- Automatically provides xterm approximations for GUI colors.
- Imports any color scheme. You do not have to start from scratch!
- Provides a sophisticated style picker. Create color schemes in real-time
  directly within Vim!
- Displays information about the highlight group under the cursor.
- Computes useful statistics about your color scheme.
- Supports generating any kind of auxiliary files (say,
  `autoload/gorgeous.vim` or `scripts/foo.sh`).
- Has syntax completion for highlight groups, keywords and common colors.
- …And a lot more!

Colortemplate is fully documented: to learn everything about it, read `:help
colortemplate.txt`.

## Quick Start

Installing this plugin does not require anything special. If you need help,
please first check the
[FAQ](https://github.com/lifepillar/vim-colortemplate/wiki/FAQs).

```vim
:edit templates/dark.colortemplate
:Colortemplate! ~/.vim
:colorscheme dark
```

The resulting color scheme will be written into `~/.vim/colors`. See `:help
colortemplate.txt` for detailed documentation.

**Note:** `:Colortemplate` and other plugin's commands are filetype-specific. That
means that they are available only if the filetype is set to `colortemplate`.
You may need to explicitly type `:set ft=colortemplate` to make them available
in new buffers.

Colortemplate is based on a very simple but very flexible template format.
This is a minimal template, which you can actually compile without warnings:

```
Full name:  My Gorgeous Theme
Short name: gorgeous
Author:     Me <me@somewhere.org>

Variant:    gui 256
Background: dark

; Color palette
Color:      myblack #333333 ~
Color:      mywhite #fafafa ~

; Highlight group definitions
Normal      mywhite myblack

Term colors: mywhite mywhite mywhite mywhite mywhite mywhite mywhite mywhite
Term colors: myblack myblack myblack myblack myblack myblack myblack myblack
```

If you want to get a flavor of how Colortemplate can be used in the real world,
take a look at some color schemes created with it:
[WWDC16](https://github.com/lifepillar/vim-wwdc16-theme) and
[WWDC17](https://github.com/lifepillar/vim-wwdc17-theme) (simple), or
[Gruvbox 8](https://github.com/lifepillar/vim-gruvbox8) and
[Solarized 8](https://github.com/lifepillar/vim-solarized8) (complex).


## Contributions

Do you want to contribute? Do you have any suggestions on how to improve
Colortemplate? Open an issue or submit a pull request!

