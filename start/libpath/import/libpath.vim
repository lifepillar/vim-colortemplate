vim9script

export const SLASH: string = !exists("+shellslash") || &shellslash ? '/' : '\'

export def C(path1: string, path2: string): string
  return path1 .. SLASH .. path2
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
  return executable(path) == 1
enddef

export def Exists(path: string): bool
  return filereadable(path) || isdirectory(path)
enddef

export def IsFileReadable(path: string): bool
  return filereadable(path)
enddef

export def IsWritable(path: string): bool
  return filewritable(path) >= 1
enddef

export def Dirname(path: string): string
  return fnamemodify(path, ":p:h:t")
enddef

export def Basename(path: string): string
  return fnamemodify(path, ":p:t")
enddef

export def Parent(path: string): string
  return fnamemodify(Clean(path), ":h")
enddef

export def Split(path: string): list<string>
  return [Parent(path), Basename(path)]
enddef

export def Clean(path: string): string
  const path_ = simplify(path)
  return path_ =~ './$' ? slice(path_, 0, -1) : path_
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
    return path
  endif

  if isabsolutepath(base)
    return Clean(C(base, path))
  endif

  return Clean(getcwd()->C(base)->C(path))
enddef

export def IsEqual(path1: string, path2: string, base = ''): bool
  return Expand(path1, base) == Expand(path2, base)
enddef

export def Contains(path: string, subpath: string,  base = ''): bool
  const path_    = Parts(Expand(path, base))
  const subpath_ = Parts(Expand(subpath, base))
  const n_       = len(path_)

  return n_ < 1 || path_ == subpath_[0 : (n_ - 1)]
enddef

export def MakeDir(path: string, flags = ''): bool
  return mkdir(fnameescape(path), flags)
enddef

# vim: foldmethod=marker nowrap et ts=2 sw=2
