# Vim Development Package

A package consisting of plugins and libraries that facilitate the development
of modern Vim plugins and libraries.

## Installation

```sh
git clone --recurse-submodules https://github.com/lifepillar/vim-devel.git ~/.vim/pack/devel
```

Enable the plugins you need with `packadd`. For instance:

```vim
packadd vim9asm
```


## What's Included

**Libraries:**

- **libcolor**: functions and classes to work with colors (alpha level).
- **libparser**: a simple library to write parsers (alpha level).
- **libpath**: simplifies working with paths in Vim (alpha level).
- **libreactive:** a minimalist reactive library (alpha level).
- **librelalg:** an implementation of Relational Algebra in Vim 9 script (alpha
  level).
- **libtinytest**: a minimal unit-testing library (beta level).

“alpha level” means that the library generally works, but there may be serious
bugs and the interface is still WIP.

“beta level” means that the library is stable and has been tested, but some
issues may still exist.

You should not used alpha level libraries in your own plugins, and you should
use beta level libraries only if you feel adventurous.

**Plugins:**

- **[vim9asm](https://github.com/lacygoill/vim9asm):** Vim 9 disassembly on
  steroids.
