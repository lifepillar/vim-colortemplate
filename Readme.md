# Colortemplate: The Toolkit for Vim Colorscheme Designers!

Colortemplate is a plugin for Vim 8 that allows you to easily develop
colorschemes. Its ambitious goal is to become *the* way to create new
colorschemes for Vim!

Colortemplate is based on a very simple but very flexible template format.
This is a minimal template:

```
# vim: ft=colortemplate
Full name:  My Gorgeous Theme
Short name: gorgeous
Author:     Me <me@somewhere.org>
Maintainer: Me <me@somewhere.org>

Background: dark

# Color palette
Color:      black #000000 ~
Color:      white #ffffff ~

# Highlight group definitions
Normal white black
# Etc…
```

Save the template and use `:Colortemplate` to turn it into a full-fledged
colorscheme. For example:

```vim
:Colortemplate ~/.vim
```

will translate your template and write your new shining colorscheme into
`~/.vim/colors/gorgeous.vim`, ready to be used!

If you want to get a flavor of how Colortemplate can be used in the real world,
take a look at [Gruvbox 8](https://github.com/lifepillar/vim-gruvbox8) and
[Solarized 8](https://github.com/lifepillar/vim-solarized8).


## Main Features

- Generates colorschemes that support true colors and 256 colors by default.
- Generates colorschemes that load efficiently and have a consistent structure
  following best practices.
- Has syntax completion for highlight groups, keywords and common colors.
- Detects a few common mistakes, e.g., missing highlight group definitions.
- Supports generating any kind of auxiliary files (say,
  `autoload/gorgeous.vim` or `scripts/foo.sh`).
- Can display information about the highlight group under the cursor.
- …And more! To get started, see `:help ft-colortemplate`.

Colortemplate allows you to answer the following questions about your
colorscheme:

- Are those two colors different enough to be used as a foreground and
  background pair?
- Do they have enough contrast? What is their brightness difference?
- What are the four xterm colors most similar to color 88?
- How different are GUI colors from their xterm approximations?

Colortemplate also includes functions to generate good looking color palettes!


## Contributions

Do you want to contribute? Do you have any suggestions on how to improve
Colortemplate? Open an issue or submit a pull request!

See also [the discussion](https://github.com/vim/vim/issues/1665) that prompted
the creation of this script.

