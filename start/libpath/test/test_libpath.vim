vim9script

import 'libtinytest.vim' as tt
import 'libpath.vim' as path

const TESTPATH = resolve(expand('<sfile>:p'))
const TESTFILE = fnamemodify(TESTPATH, ':t')
const TESTDIR  = fnamemodify(TESTPATH, ':h')

def Test_Path_Version()
  assert_true(match(path.version, '^\d\+\.\d\+\.\d\+') != -1)
enddef

def Test_Path_Clean()
  assert_equal('a',   path.Clean('a/'))
  assert_equal('a/b', path.Clean('a/b'))
  assert_equal('a/b', path.Clean('a/b//'))
  assert_equal('a/b', path.Clean('a/b///'))
  assert_equal('/a',  path.Clean('///a//b/../'))
  assert_equal('/',   path.Clean('/.'))
enddef

def Test_Path_IsAbsolute()
  assert_true(path.IsAbsolute('/'))
  assert_true(path.IsAbsolute('/a'))
  assert_true(path.IsAbsolute('~'))

  assert_false(path.IsAbsolute(''))
  assert_false(path.IsAbsolute('a'))
  assert_false(path.IsAbsolute('.'))
  assert_false(path.IsAbsolute('..'))
enddef

def Test_Path_IsRelative()
  assert_false(path.IsRelative('/'))
  assert_false(path.IsRelative('/a'))
  assert_false(path.IsRelative('~'))

  assert_true(path.IsRelative(''))
  assert_true(path.IsRelative('a'))
  assert_true(path.IsRelative('.'))
  assert_true(path.IsRelative('..'))
enddef

def Test_Path_IsDirectory()
  assert_true(path.IsDirectory(TESTDIR))
  assert_true(path.IsDirectory($VIMRUNTIME))
  assert_false(path.IsDirectory(TESTPATH))
enddef

def Test_Path_IsExecutable()
  assert_true(path.IsExecutable(v:progpath))
  assert_false(path.IsExecutable(TESTPATH))
  assert_false(path.IsExecutable(TESTDIR))
enddef

def Test_Path_Exists()
  assert_true(path.Exists(TESTDIR))
  assert_true(path.Exists(TESTDIR->path.Join(TESTFILE)))
  assert_true(path.Exists('~'))
  assert_false(path.Exists(path.Join(TESTPATH, '#$%^&*(')))
enddef

def Test_Path_IsReadable()
  assert_true(path.IsReadable(TESTPATH))
  assert_true(path.IsReadable(TESTDIR))
  assert_false(path.IsReadable(path.Join(TESTPATH, '#$%^&*(')))
enddef

def Test_Path_IsWritable()
  assert_true(path.IsWritable(TESTPATH))
  assert_true(path.IsWritable(TESTDIR))
  assert_false(path.IsWritable(path.Join(TESTPATH, '#$%^&*(')))
enddef

def Test_Path_Parent()
  assert_equal(TESTDIR, path.Parent(TESTPATH))
  assert_equal(TESTDIR, path.Parent(TESTPATH .. path.SLASH))
  assert_equal('/a/b',  path.Parent('/a/b/c'))
  assert_equal('/a/b',  path.Parent('/a/b/c/'))
  assert_equal('/',     path.Parent('/a'))
  assert_equal('a',     path.Parent('a/b'))
  assert_equal('.',     path.Parent('a'))
  assert_equal('.',     path.Parent('.'))
  assert_equal('.',     path.Parent(''))
enddef

def Test_Path_Basename()
  assert_equal('foo.vim',          path.Basename('a/foo.vim'))
  assert_equal('foo.vim',          path.Basename('/a/foo.vim'))
  assert_equal('foo.vim',          path.Basename('/a/foo.vim'))
  assert_equal('foo.vim',          path.Basename('/a/foo.vim/'))
  assert_equal('test_libpath.vim', path.Basename(TESTPATH))
  assert_equal('foo',              path.Basename('/bar/foo/'))
  assert_equal('test',             path.Basename(TESTDIR))
enddef

def Test_Path_Stem()
  assert_equal('foo',    path.Stem('/a/b/foo.vim'))
  assert_equal('foo',    path.Stem('/a/b/foo.vim/'))
  assert_equal('.vimrc', path.Stem('/home/me/.vim/.vimrc'))
  assert_equal('.vimrc', path.Stem('/home/me/.vim/.vimrc/'))
enddef

def Test_Path_Extname()
  assert_equal('vim', path.Extname('/a/b/foo.vim'))
  assert_equal('vim', path.Extname('/a/b/foo.vim/'))
  assert_equal('',    path.Extname('/home/me/.vim/.vimrc'))
  assert_equal('',    path.Extname('/home/me/.vim/.vimrc/'))
enddef

def Test_Path_Split()
  assert_equal(['/',    'a'],       path.Split('/a'))
  assert_equal(['/a/b', 'c'],       path.Split('/a/b/c'))
  assert_equal(['a/b',  'c'],       path.Split('a/b/c'))
  assert_equal([TESTDIR, TESTFILE], path.Split(TESTPATH))
enddef

def Test_Path_Parts()
  assert_equal(['a'],           path.Parts('/a'))
  assert_equal(['a', 'b', 'c'], path.Parts('/a/b/c'))
  assert_equal(['a', 'b', 'c'], path.Parts('a/b/c'))
enddef

def Test_Path_Join()
  assert_equal('a/b',    path.Join('a/', 'b/'))
  assert_equal('/a/b/c', path.Join('/a', 'b///', 'c//'))
  assert_equal('/lib',   path.Join('usr', '/lib'))
  assert_equal('/b/c',   path.Join('a', '/b', 'c'))
  assert_equal(getcwd(), getcwd()->path.Join('.'))
  assert_equal(TESTPATH, path.Join(TESTDIR, TESTFILE))
enddef

def Test_Path_Expand()
  assert_equal('/a',     path.Expand('/a'))
  assert_equal('/a/b',   path.Expand('b', '/a'))
  assert_equal('/a/b/c', path.Expand('c', '/a/b'))
  assert_equal(getcwd(), path.Expand(''))
  assert_equal(getcwd(), path.Expand('.'))
  echomsg printf("DEBUG: %s", TESTDIR)
  assert_equal(TESTDIR, path.Expand('../test', TESTDIR))
  assert_equal(
    getcwd()->path.C('a')->path.C('b'),
    path.Expand('b', 'a')
  )
  assert_equal($HOME, path.Expand('~'))
enddef

def Test_Path_ExpandPathWithSpaces()
  assert_equal('/a b/c d', path.Expand('/a b/c d'))
  assert_equal('/a b/c d', path.Expand('c d', '/a b'))
enddef

def Test_Path_Contains()
  assert_true('/usr/lib'->path.Contains('/usr/lib/foo'))
  assert_true('/'->path.Contains('/a'))
  assert_true('/a'->path.Contains('/a'))

  assert_false('/a'->path.Contains('/'))
  assert_false('/usr/lib/foo'->path.Contains('/usr/lib'))
enddef

def Test_Path_MakeDir()
  const dirname = 'emptydir'
  const dirpath = path.Join(TESTDIR, dirname)

  assert_true(path.Contains(TESTDIR, dirpath))
  assert_false(path.Exists(dirpath))

  try
    path.MakeDir(dirpath)

    assert_true(path.Exists(dirpath))

  finally
    delete(dirpath, 'd')
  endtry

  assert_false(path.Exists(dirpath))
enddef

def Test_Path_Children()
  assert_equal([TESTPATH], path.Children(TESTDIR))
  assert_equal([TESTPATH], path.Children(TESTDIR, '*.vim'))
enddef

tt.Run('_Path_')
