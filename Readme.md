# Vim Development Package

A package consisting of plugins and libraries that facilite the development of
modern Vim plugins and libraries.

## Installation

```sh
git clone --recurse-submodules https://github.com/lifepillar/vim-devel.git ~/.vim/pack/devel
```

Enable the plugins you need with `packadd`. For instance:

```vim
packadd vim9asm
```


## What's Included

- **libparser**: a simple library to write parsers.
- **librelalg:** an implementation of Relational Algebra in Vim 9 script
- **libtinytest**: a minimal unit-testing library.
- **[vim9asm](https://github.com/lacygoill/vim9asm):** Vim 9 disassembly on
  steroids.
