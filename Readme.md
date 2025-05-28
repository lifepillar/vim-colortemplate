# Vim Development Package

A package whose goal is to facilitate the development of modern Vim plugins and
libraries.


## Installation

```sh
git clone https://github.com/lifepillar/vim-devel.git ~/.vim/pack/devel
```


## What's Included

**Libraries:**

- **libcolor**: functions and classes to work with colors (alpha level).
- **libparser**: a simple library to write parsers (alpha level).
- **libpath**: simplifies working with paths in Vim (alpha level).
- **libreactive:** a minimalist reactive library (beta level).
- **librelalg:** an implementation of Relational Algebra in Vim 9 script (alpha
  level).
- **libtinytest**: a testing and benchmarking library (beta level).
- **libversion**: utility library for version comparisons and requirements
  (alpha level).

**Plugins:**

- [**Colortemplate**](https://github.com/lifepillar/vim-colortemplate/): the
  toolkit for developing Vim color schemes.
- [**StylePicker**](https://github.com/lifepillar/vim-stylepicker): a color and
  style picker inside Vim!

“alpha level” means that the library generally works, but there may be serious
bugs and the interface is still WIP.

“beta level” means that the library is stable and has been tested, but some
issues may still exist.

Using alpha-level libraries in your code means that you must be ready for
breaking changes. I do not guarantee that beta-level libraries have no breaking
changes either, but I strive to maintain backward-compatibility for beta-level
libraries.
