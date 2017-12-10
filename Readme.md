# Colortemplate: The Toolkit for Vim Colorscheme Designers!

Colortemplate is a plugin for Vim 8 that allows you to easily develop
colorschemes. Its ambitious goal is to become *the* way to create new
colorschemes for Vim!

Colortemplate is based on a very simple but very flexible template format.
This is a minimal template:

```
# vim: colortemplate
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


## Main Features

- Generates colorschemes that support true colors and 256 colors by default.
- Generates colorschemes that load efficiently and have a consistent structure
  following best practices.
- Detects a few common mistakes, e.g., missing highlight group definitions.
- Supports generating any number of auxiliary files (say,
  `autoload/gorgeous.vim`).
- Much more! To get started, see `:help ft-colortemplate`.

Besides, Colortemplate has a few functions to help you develop your colorscheme,
in particular functions to find the best 256-color approximations for GUI colors
and to display information about the highlight group under the cursor.

Colortemplate also includes functions to generate good looking color palettes!


## Contributions

Do you want to contribute? Do you have any suggestions on how to improve
Colortemplate? Open an issue or submit a pull request!

See also [the discussion](https://github.com/vim/vim/issues/1665) that prompted
the creation of this script.

