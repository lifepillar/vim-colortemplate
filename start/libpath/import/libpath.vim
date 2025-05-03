vim9script

export var version = '0.0.1-alpha'

export const SLASH: string = !exists("+shellslash") || &shellslash ? '/' : '\'

export def C(path1: string, path2: string): string
  return path1 .. SLASH .. path2
enddef

export def Clean(path: string): string
  const path_ = simplify(path)
  return path_ =~ './$' ? slice(path_, 0, -1) : path_
enddef

export def IsAbsolute(path: string): bool
  return isabsolutepath(path)
enddef

export def IsRelative(path: string): bool
  return !IsAbsolute(path)
enddef

export def IsDirectory(path: string): bool
  return isdirectory(path)
enddef

export def IsExecutable(path: string): bool
  return !empty(exepath(path))
enddef

export def Exists(path: string): bool
  return filereadable(Expand(path)) || isdirectory(Expand(path))
enddef

export def IsReadable(path: string): bool
  if isdirectory(path)
    try
      readdir(path, (_) => -1)
      return true
    catch
      return false
    endtry
  endif
  return filereadable(path)
enddef

export def IsWritable(path: string): bool
  return filewritable(path) >= 1
enddef

export def Parent(path: string): string
  return fnamemodify(Clean(path), ":h")
enddef

export def Basename(path: string): string
  return fnamemodify(Clean(path), ":t")
enddef

export def Stem(path: string): string
  return fnamemodify(Clean(path), ":t:r")
enddef

export def Extname(path: string): string
  return fnamemodify(Clean(path), ":e")
enddef

export def Split(path: string): list<string>
  return [Parent(path), Basename(path)]
enddef

export def Parts(path: string): list<string>
  return split(path, SLASH)
enddef

export def Join(path: string, ...paths: list<string>): string
  if empty(paths)
    return Clean(path)
  endif

  var joinedPath = paths[-1]

  if isabsolutepath(joinedPath)
    return Clean(joinedPath)
  endif

  const n = len(paths)
  var i = 2

  while i <= n
    joinedPath = C(paths[-i], joinedPath)

    if isabsolutepath(joinedPath)
      return Clean(joinedPath)
    endif

    ++i
  endwhile

  return Clean(C(path, joinedPath))
enddef

export def Expand(path: string, base = ''): string
  if isabsolutepath(path)
    if path[0] == '~'
      return Clean(fnamemodify(path, ':p'))
    else
      return Clean(path)
    endif
  endif

  if isabsolutepath(base)
    return Clean(C(base, path))
  endif

  return Clean(getcwd()->C(base)->C(path))
enddef

export def Contains(path: string, subpath: string,  base = ''): bool
  const path_    = Parts(Expand(path, base))
  const subpath_ = Parts(Expand(subpath, base))
  const n_       = len(path_)

  return n_ < 1 || path_ == subpath_[0 : (n_ - 1)]
enddef

export def IsEqual(path1: string, path2: string, base = ''): bool
  return Expand(path1, base) == Expand(path2, base)
enddef

export def MakeDir(path: string, flags = ''): bool
  return mkdir(fnameescape(path), flags)
enddef

export def Children(path: string, globPattern = '*'): list<string>
  return glob(C(path, globPattern), true, true, true)
enddef

# vim: foldmethod=marker nowrap et ts=2 sw=2
