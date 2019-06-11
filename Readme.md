# Colortemplate: The Toolkit for Vim Color Scheme Designers!

![](https://raw.github.com/lifepillar/Resources/master/colortemplate/colortemplate-v2.png)

Colortemplate is a 100% VimScript plugin for Vim 8 that allows you to easily
develop color schemes. Its ambitious goal is to become *the* way to create new
color schemes for Vim!

## Quick Start

```vim
:edit templates/default_clone.colortemplate
:Colortemplate! ~/.vim
:colorscheme default_clone
```

The resulting color scheme will be written into `~/.vim/colors`.
The generated color scheme replicates Vim's `default` color scheme. Look inside
the `templates` folder for other templates.


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


## Migrating from v1

Users of Colortemplate v1 in most cases will still be able to build their color
schemes, with just a couple of additional warnings. Anyway, to fully migrate to
v2, the following must be taken into account:

- The `Terminal Colors` directive has been deprecated in favor of the much more
  flexible mechanism of *variants* (see below).
- The ambiguous `@term<color>` interpolation pattern has been removed: use
  `@term16<color>` or `@term256<color>` instead.
- There is a new `Term Colors` key, which allows you specify the 16 ASCII colors
  to be used in Vim terminal windows. If you were using `verbatim` blocks for
  this, you should remove them: Colortemplate v2 automatically defines
  `g:terminal_ansi_colors` (and the equivalent for NeoVim if enabled, see
  below).
- There is a new `Variant` directive, which specifies to which environments the
  subsequent definitions apply. Replace `Terminal Colors: 256` with `Variant:
  gui 256`; replace `Terminal Colors: 256 16` with `Variant: gui 256 16`; and so
  on. See `:help colortemplate-variants` for more information.
- There is a new `Neovim` key: when its value is `yes`, additional code to
  support Neovim is generated (default is `no`).
- The `Maintainer` key is now optional.
- If you were using `verbatim` blocks to check for italics, you should remove
  them: Colortemplate v2 deals with the `italic` attribute automatically. Just
  define your highlight groups as if italics is available, and let Colortemplate
  do the rest.
- Many `verbatim` blocks may now be replaced with `#if`, `#let`, …, commands
  (see `:help colortemplate-verbatim`).
- Colortemplate v2 does not generate any help file by default any more (color
  schemes have no settings by default). You may need to adjust your help
  templates (see `templates/_help.colortemplate`).
- `Background` directives accept a new value (`any`). You may switch between
  `dark`, `light` and `any` an arbitrary number of times.
- Anything before the first `Background` and `Variant` directives is considered
  to be “in global scope” and put at the start of the generated color scheme.
  You may put setup stuff in `verbatim` blocks there, or linked group
  definitions that apply to all variants.
- Validation is now performed with `$VIMRUNTIME/colors/tools/check_colors.vim`
  (`:ColortemplateCheck` command or Check menu entry in the toolbar).
- Statistics are generated separately from the color scheme
  (`:ColortemplateStats` or Stats menu entry in the toolbar).
- Try typing `3ga` with the cursor on a `Color` line!

## Contributions

Do you want to contribute? Do you have any suggestions on how to improve
Colortemplate? Open an issue or submit a pull request!

See also [the discussion](https://github.com/vim/vim/issues/1665) that prompted
the creation of this script.

