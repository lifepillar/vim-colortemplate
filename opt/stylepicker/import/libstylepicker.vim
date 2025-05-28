vim9script

import 'libreactive.vim' as react

# The content of a view is a list of dictionaries of the form:
#
#    {text: '...', props: [...]}
#
# where `props` is a list of text properties.
# See `:help popup_create-arguments` for details.
export type ViewContent = list<dict<any>>

export class TextProperty
  #   #
  #  # A simple abstraction on a Vim text property, working with characters
  # # instead of byte indexes. See :help text-properties.
  ##
  var type: string     # Text property type (created with prop_type_add())
  var xl:   number     # 0-based start position of the property, in characters (composed chars not counted separately)
  var xr:   number     # One past the last character of the property
  var id:   number = 1 # Optional property ID
endclass

def FormatTextProperties(text: string, textProperties: list<TextProperty>): list<dict<any>>
  #   #
  #  # Return the text properties in a format suitable for popup_settext().
  # #
  ##
  var props: list<dict<any>> = []

  for prop in textProperties
    var xl = byteidx(text, prop.xl)
    var xr = byteidx(text, prop.xr)
    props->add({col: 1 + xl, length: xr - xl, type: prop.type, id: prop.id})
  endfor

  return props
enddef

export class TextLine
  #   #
  #  # A string with attached text properties.
  # #
  ##
  var value: dict<any> # {text: '...', props: []}

  def new(text: string, props: list<TextProperty>= [])
    this.value = {text: text, props: FormatTextProperties(text, props)}
  enddef

  def Text(): string
    return this.value.text
  enddef

  def Add(...props: list<TextProperty>)
    this.value.props->extend(FormatTextProperties(this.value.text, props))
  enddef
endclass

export abstract class View
  var  hidden:      bool           = false
  var  focusable:   bool           = false
  var  focused:     react.Property = react.Property.new(false)
  var  parent:      View           = this
  var  llink:       View           = this  # Left subtree
  var  rlink:       View           = this  # Right subtree
  var  ltag:        bool           = false # false=thread, true=link to first child
  var  rtag:        bool           = false # false=thread, true=link to right sibling

  var _keyAction:   dict<func()>
  var _mouseAction: dict<func(number, number)>

  abstract def Body(): list<dict<any>>

  def Height(): number
    return len(this.Body())
  enddef

  def Focusable(isFocusable: bool): View
    this.focusable = isFocusable
    return this
  enddef

  def Focused(isFocused: bool): View
    this.focused.Set(isFocused)
    return this
  enddef

  def SubViewWithFocus(): View
    var view: View = this.FirstLeaf()

    while view isnot this && !view.focused.value
      view = view.Next()
    endwhile

    return view
  enddef

  def FocusPrevious()
    react.Transaction(() => {
      var viewWithFocus: View = this.SubViewWithFocus()
      var view:          View = viewWithFocus.Previous()

      while view isnot viewWithFocus && (!view.focusable || view.hidden)
        view = view.Previous()
      endwhile

      viewWithFocus.Focused(false)
      view.Focused(true)
    })
  enddef

  def FocusNext()
    react.Transaction(() => {
      var viewWithFocus: View = this.SubViewWithFocus()
      var view:          View = viewWithFocus.Next()

      while view isnot viewWithFocus && (!view.focusable || view.hidden)
        view = view.Next()
      endwhile

      viewWithFocus.Focused(false)
      view.Focused(true)
    })
  enddef

  def FocusFirst()
    react.Transaction(() => {
      var view: View = this.FirstLeaf()

      while view isnot this && (!view.focusable || view.hidden)
        view = view.Next()
      endwhile

      this.SubViewWithFocus().Focused(false)
      view.Focused(true)
    })
  enddef

  def FocusLast()
    react.Transaction(() => {
      var view: View = this.LastLeaf()

      while view isnot this && (!view.focusable || view.hidden)
        view = view.Previous()
      endwhile

      this.SubViewWithFocus().Focused(false)
      view.Focused(true)
    })
  enddef

  def OnKeyPress(keyCode: string, F: func()): View
    this._keyAction[keyCode] = F
    return this
  enddef

  def OnMouseEvent(keyCode: string, F: func(number, number)): View
    this._mouseAction[keyCode] = F
    return this
  enddef

  def RespondToKeyEvent(keyCode: string): bool
    if this._keyAction->has_key(keyCode)
      this._keyAction[keyCode]()
      return true
    endif

    if this.IsRoot()
      return false
    endif

    return this.parent.RespondToKeyEvent(keyCode)
  enddef

  def RespondToMouseEvent(keyCode: string, lnum: number, col: number): bool
    if this._mouseAction->has_key(keyCode)
      this._mouseAction[keyCode](lnum, col)
      return true
    endif

    if this.IsLeaf()
      return false
    endif

    # Find the child containing lnum
    var lnum_ = lnum
    var child = this.FirstChild()

    while true
      var height = child.Height()

      if lnum_ <= height # Forward the event to the child
        return child.RespondToMouseEvent(keyCode, lnum_, col)
      endif

      if child.IsLastChild()
        break
      endif

      lnum_ -= height
      child = child.NextChild()
    endwhile

    return false
  enddef

  def Root(): View
    var node: View = this

    while !node.IsRoot()
      node = node.parent
    endwhile

    return node
  enddef

  def IsRoot(): bool
    return this.parent is this
  enddef

  def IsLeaf(): bool
    return !this.ltag
  enddef

  def IsLastChild(): bool
    return !this.rtag
  enddef

  def NumChildren(): number
    if this.IsLeaf()
      return 0
    endif

    var i = 1
    var child = this.llink

    while child.rtag
      ++i
      child = child.rlink
    endwhile

    return i
  enddef

  def Child(index: number): View
    var i = 0
    var child = this.llink

    while i < index
      child = child.rlink
      ++i
    endwhile

    return child
  enddef

  def FirstChild(): View
    return this.llink
  enddef

  def NextChild(): View
    return this.rlink
  enddef

  def FirstLeaf(): View
    var node: View = this

    while node.ltag
      node = node.llink
    endwhile

    return node
  enddef

  def LastLeaf(): View
    var node: View = this

    while !node.IsLeaf()
      node = node.Previous()
    endwhile

    return node
  enddef

  def Next(): View
    if this.rlink is this
      return this.FirstLeaf()
    endif

  var nextNode = this.rlink

    if !this.rtag
      return nextNode
    endif

    while nextNode.ltag
      nextNode = nextNode.llink
    endwhile

    return nextNode
  enddef

  def Previous(): View
    var prevNode = this.llink

    if !this.ltag
      return prevNode
    endif

    while prevNode.rtag
      prevNode = prevNode.rlink
    endwhile

    return prevNode
  enddef

  def AddView(view: View)
    view.parent = this

    # Adapted from TAOCP, §2.3.1 (Traversing Binary Trees), Algorithm I
    if this.IsLeaf() # Add view as the left subtree of this
      var leaf = view.FirstLeaf()

      leaf.llink = this.llink
      leaf.ltag  = this.ltag
      this.llink = view
      this.ltag  = true
      view.rlink = this
      view.rtag  = false
    else # Add view as the right subtree of the rightmost child of this
      var node = this.Previous() # Rightmost child of this
      var leaf = view.FirstLeaf()

      view.rlink = node.rlink
      view.rtag  = node.rtag
      node.rlink = view
      node.rtag  = true
      leaf.llink = node
      leaf.ltag  = false
    endif
  enddef

  def ApplyToChildren(F: func(View))
    if this.IsLeaf()
      return
    endif

    var node = this.llink

    while true
      F(node)

      if !node.rtag
        break
      endif

      node = node.rlink
    endwhile
  enddef
endclass

export class ReactiveView extends View
  #   #
  #  # A reactive view. The view's body is automatically recomputed
  # # every time any property which the view depends upon is updated.
  ##
  var _content: react.ComputedProperty

  def new(Fn: func(): list<TextLine>)
    this.Init(Fn)
  enddef

  def Init(Fn: func(): list<TextLine>)
    this._content = react.ComputedProperty.new(
      (): ViewContent => {
        var body = mapnew(Fn(), (_, l: TextLine): dict<any> => l.value)

        this.hidden = empty(body)

        return body
      }
    )
  enddef

  def Body(): ViewContent
    return this._content.Get()
  enddef
endclass

export class StaticView extends View
  #   #
  #  # A view whose content does not change.
  # #
  ##
  var _content: ViewContent

  def new(content: list<TextLine>, this.focusable = v:none)
    this._content = mapnew(content, (_, l: TextLine): dict<any> => l.value)
  enddef

  def Body(): ViewContent
    return this._content
  enddef
endclass

export class VStack extends View
  #   #
  #  # A container to vertically stack other views.
  # #
  ##
  def new(views: list<View> = [])
    for view in views
      this.AddView(view)
    endfor
  enddef

  def Body(): ViewContent
    var body: ViewContent = []

    this.ApplyToChildren((child: View) => {
      body += child.Body()
    })

    return body
  enddef
endclass
