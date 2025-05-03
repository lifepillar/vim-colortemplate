vim9script

export var version = '0.0.1-alpha'

# Utility class to parse and compare version numbers
# Based on rules from https://semver.org/

const digits     = '[0-9]\+'
const identifier = '[0-9A-Za-z][0-9A-Za-z-]*'
const dot        = '\.'
const coreRegex  = $'^\({digits}\){dot}\({digits}\){dot}\({digits}\)'
const preRegex   = $'\%(-\({identifier}\%({dot}{identifier}\)*\)\)\='
const buildRegex = $'\%(+\({identifier}\%({dot}{identifier}\)*\)\)\='

def Min(a: number, b: number): number
  return a <= b ? a : b
enddef

def Err(msg: string, throw: bool)
  if throw
    throw msg
  else
    echohl ErrorMsg
    echomsg msg
    echohl None
  endif
enddef

export class Version
  static const regex = coreRegex .. preRegex .. buildRegex
  var major:      number
  var minor:      number
  var patch:      number
  var prerelease: list<any>    = []  # TODO: use tuple
  var build:      list<string> = []

  var _version: list<any>

  def new(this.major, this.minor, this.patch, this.prerelease = v:none, this.build = v:none)
    this._version = flattennew([this.major, this.minor, this.patch, this.prerelease])
  enddef

  static def Parse(versionString: string): Version
    var match      = matchlist(versionString, Version.regex)
    var major      = str2nr(match[1])
    var minor      = str2nr(match[2])
    var patch      = str2nr(match[3])
    var prerelease = mapnew(split(match[4], dot), (_, v) => match(v, $'^{digits}$') == -1 ? v : str2nr(v))
    var build      = split(match[5], dot)

    return Version.new(major, minor, patch, prerelease, build)
  enddef

  def string(): string
    var pre           = join(this.prerelease, '.')
    var build         = join(this.build, '.')
    var versionString = $'{this.major}.{this.minor}.{this.patch}'

    if !empty(pre)
      versionString ..= "-" .. pre
    endif

    if !empty(build)
      versionString ..= "+" .. build
    endif

    return versionString
  enddef

  def IsPrerelease(): bool
    return !empty(this.prerelease)
  enddef

  def IsRelease(): bool
    return empty(this.prerelease)
  enddef

  def Equal(other: any): bool
    if type(other) == v:t_string
      var v = Version.Parse(other)
      return this._version == v._version
    endif

    return this._version == other._version
  enddef

  def Compare(other: any): number
    var otherVersion = type(other) == v:t_string ? Version.Parse(other) : other
    var v0 = this._version
    var v1 = otherVersion._version
    var n = Min(len(v0), len(v1))
    var i = 0
    var sametype: bool

    while i < n
      sametype = (type(v0[i]) == type(v1[i]))

      if !sametype || v0[i] != v1[i]
        break
      endif

      ++i
    endwhile

    if i < n
      if sametype
        return v0[i] < v1[i] ? -1 : 1
      else
        return type(v1[i]) == v:t_string ? -1 : 1
      endif
    endif

    if len(v0) == len(v1)
      return 0
    endif

    if this.IsRelease()
      return 1
    endif

    if otherVersion.IsRelease()
      return -1
    endif

    return len(v0) < len(v1) ? -1 : 1
  enddef

  def LessThan(other: any): bool
    return this.Compare(other) < 0
  enddef

  def LessThanOrEqual(other: any): bool
    return this.Compare(other) <= 0
  enddef

  def GreaterThan(other: any): bool
    return this.Compare(other) > 0
  enddef

  def GreaterThanOrEqual(other: any): bool
    return this.Compare(other) >= 0
  enddef
endclass


export def Require(name: string, versionString: string, minversion: string, args: dict<any> = {}): bool
  var ver        = Version.Parse(versionString)
  var min        = Version.Parse(minversion)
  var maxversion = args->get('max', '')

  if ver.LessThan(min)
    var msg = $"{name} v{versionString} is too old. "

    if empty(maxversion)
      msg ..= $'Please upgrade to v{minversion} or later.'
    else
      msg ..= $'Please upgrade to a version >={minversion} and <={maxversion}.'
    endif

    Err(msg, args->get('throw', true))

    return false
  endif

  if !empty(maxversion)
    var max = Version.Parse(maxversion)

    if ver.GreaterThan(max)
      var msg = $"{name} v{versionString} is not supported yet. " ..
        $'Please downgrade to a version >={minversion} and <={maxversion}.'

      Err(msg, args->get('throw', true))

      return false
    endif
  endif

  return true
enddef
