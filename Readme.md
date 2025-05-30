# The Toolkit for Vim Color Scheme Designers!

Colortemplate is a 100% Vim9 script plugin for Vim 9.1 or later, which makes it
easy to develop color schemes. Its ambitious goal is to become *the* way to
create new color schemes for Vim!


## Note for Users of Colortemplate v2

The current version of Colortemplate is a complete rewrite of v2.2.3,
introducing a better syntax for templates, which is unfortunately not fully
compatible with the old syntax. The old Colortemplate version, however, is not
disappearing anywhere: if you want to keep using it, just checkout the `v2`
branch of this repository.

For instructions on how to update your templates to the new syntax, see `:help
colortemplate-migrate-v2`.


## Features

- Generate color schemes that support all environments, from black&white to
  millions of colors, and both terminal and GUI Vim.
- Generate color schemes that load efficiently and have a consistent structure
  following best practices.
- Automatically compute xterm approximations for GUI colors.
- Import any color scheme. You do not have to start from scratch!
- Display information about the highlight group under the cursor or mouse.
- Compute useful statistics about your color scheme.
- Support generating any kind of auxiliary files (say,
  `autoload/gorgeous.vim` or `scripts/foo.sh`).

Colortemplate is fully documented: to learn everything about it, read `:help
colortemplate.txt`.


## Installation

Colortemplate is part of the
[vim-devel](https://github.com/lifepillar/vim-devel) package. Just clone the
repository:

    git clone https://github.com/lifepillar/vim-devel.git ~/.vim/pack/devel


## Quick Start

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
This is a minimal template (it doesn't define much, but it compiles):

```
Full name:    My Gorgeous Theme
Short name:   gorgeous
Author:       Me <me@somewhere.org>

Environments: gui 256
Background:   dark

; Color palette
Color:        myblack #333333 ~
Color:        mywhite #fafafa ~

; Highlight group definitions
Normal      mywhite myblack

Term colors: mywhite mywhite mywhite mywhite mywhite mywhite mywhite mywhite
             myblack myblack myblack myblack myblack myblack myblack myblack
```

If you want to get a flavor of how Colortemplate is used in the real world,
take a look at some color schemes created with it:
[WWDC16](https://github.com/lifepillar/vim-wwdc16-theme) and
[WWDC17](https://github.com/lifepillar/vim-wwdc17-theme) (simple), or
[Gruvbox 8](https://github.com/lifepillar/vim-gruvbox8) and
[Solarized 8](https://github.com/lifepillar/vim-solarized8) (complex).


## Contributions

Do you want to contribute? Do you have any suggestions on how to improve
Colortemplate? Open an issue or submit a pull request!

