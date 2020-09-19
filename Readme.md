# Colortemplate: The Toolkit for Vim Color Scheme Designers!

![](https://raw.github.com/lifepillar/Resources/master/colortemplate/colortemplate-v2.png)

Colortemplate is a 100% VimScript plugin for Vim 8 that allows you to easily
develop color schemes. Its ambitious goal is to become *the* way to create new
color schemes for Vim!

## Quick Start

Installing this plugin does not require anything special. If you need help,
please first check the
[FAQ](https://github.com/lifepillar/vim-colortemplate/wiki/FAQs).

```vim
:edit templates/default_clone.colortemplate
:Colortemplate! ~/.vim
:colorscheme default_clone
```

The resulting color scheme will be written into `~/.vim/colors`.
The generated color scheme replicates Vim's `default` color scheme. Look inside
the `templates` folder for other templates.

**Note:** `:Colortemplate` and other plugin's commands are filetype-specific. That
means that they are available only if the filetype is set to `colortemplate`.
You may need to explicitly type `:set ft=colortemplate` to make them available
in new buffers.


## Features

- Generates color schemes that support all environments, from black&white to
  million colors, both terminal and GUI.
- Generates color schemes that load efficiently and have a consistent structure
  following best practices.
- Has syntax completion for highlight groups, keywords and common colors.
- Supports generating any kind of auxiliary files (say,
  `autoload/gorgeous.vim` or `scripts/foo.sh`).
- Automatically provides xterm approximations for GUI colors.
- Can display information about the highlight group under the cursor.
- Computes useful statistics about your color palette.
- Is fully documented!

To know everything about Colortemplate, read `:help colortemplate.txt`.

Colortemplate is based on a very simple but very flexible template format.
This is a minimal template:

```
# vim: ft=colortemplate
Full name:  My Gorgeous Theme
Short name: gorgeous
Author:     Me <me@somewhere.org>

Variant:    gui 256 8
Background: dark

# Color palette
Color:      black #000000 ~ Black
Color:      white #ffffff ~ White

# Highlight group definitions
Normal white black
# Etc…
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

See also [the discussion](https://github.com/vim/vim/issues/1665) that prompted
the creation of this script.

