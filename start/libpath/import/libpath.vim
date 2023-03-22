vim9script

export const SLASH: string = !exists("+shellslash") || &shellslash ? '/' : '\'

def IsAbsolute(path: string): bool
  return isabsolutepath(path)
enddef

def IsRelative(path: string): bool
  return !IsAbsolute()
enddef

def IsDirectory(path: string): bool
  return isdirectory(path)
enddef

def IsExecutable(path: string): bool
  return executable(path)
enddef

def Exists(path: string): bool
  return filereadable(path) || isdirectory(path)
enddef

def IsWritable(path: string): bool
  return filewritable(path) >= 1
enddef

def Dirname(path: string): string
  return fnamemodify(path, ":p:h:t")
enddef

def Basename(path: string): string
  return fnamemodify(path, ":p:t")
enddef

def Parent(path: string): string
  return fnamemodify(path, ":h")
enddef

def Split(path: string): list<string>
  return [Parent(path), Basename(path)]
enddef

def Components(path: string): list<string>
  return split(path, SLASH)
enddef

def Join(path: string, ...paths: list<string>): string
  if empty(paths)
    return simplify(path)
  endif

  var joinedPath = paths[-1]

  if isabsolutepath(joinedPath)
    return simplify(joinedPath)
  endif

  const n = len(paths)
  var i = 2

  while i <= n
    joinedPath = paths[-i] .. SLASH .. joinedPath

    if isabsolutepath(joinedPath)
      return simplify(joinedPath)
    endif

    ++i
  endwhile

  return simplify(path .. SLASH .. joinedPath)
enddef

def Expand(path: string, base = ''): string
  if isabsolutepath(path) || empty(base)
    return simplify(fnamemodify(path, ":p"))
  endif

  return simplify(fnamemodify(base .. SLASH .. path, ":p"))
enddef

def IsEqual(path1: string, path2: string, base = ''): bool
  return Expand(path1, base) == Expand(path2, base)
enddef

def Contains(outerPath: string, innerPath: string,  base: string = ''): bool
  const outer = Components(Expand(outerPath, base))
  const inner = Components(Expand(innerPath, base))

  if len(inner) < len(outer)
    return false
  endif

  for i in range(len(outer))
    if outer[i] != inner[i]
      return false
    endif
  endfor

  return true
enddef

def MakeDir(path: string, flags: string): bool
  return mkdir(fnameescape(path), flags)
enddef

const p1 = 'abc'
const paths = ['def', 'ghi/', 'lmn']
echo p1->Join('def', 'ghi/', 'lmn/')

# vim: foldmethod=marker nowrap et ts=2 sw=2
