vim9script

var kUserSettings = {
  fancynames:         true,
  higroupcommandline: true,
  higrouppopup:       true,
  mappings:           true,
  toolbaritems: [
    'Build!',
    'BuildAll!',
    'Check',
    'Colortest',
    'HiTest',
    'Hide',
    'OutDir',
    'Show',
    'Source',
    'Stats',
  ],
  toolbaractions_: {
    'Build!':    ':Colortemplate!<cr>',
    'BuildAll!': ':ColortemplateAll!<cr>',
    'Check':     ':ColortemplateCheck<cr>',
    'Colortest': ':ColortemplateTest<cr>',
    'HiTest':    ':ColortemplateHiTest<cr>',
    'Hide':      ':ColortemplateHide<cr>',
    'OutDir':    ':ColortemplateOutdir<cr>',
    'Show':      ':ColortemplateShow<cr>',
    'Source':    ':ColortemplateSource<cr>',
    'Stats':     ':ColortemplateStats<cr>',
  }->extend(get(get(g:, 'colortemplate_options', {}), 'toolbaractions', {}), 'force'),
}->extend(get(g:, 'colortemplate_options', {}), 'force')

export def Settings(): dict<any>
  return kUserSettings
enddef

export class Config
  static var FancyNames         = () => kUserSettings.fancynames
  static var HiGroupCommandLine = () => kUserSettings.higroupcommandline
  static var HiGroupPopup       = () => kUserSettings.higrouppopup
  static var Mappings           = () => kUserSettings.mappings && !get(g:, 'no_plugin_maps', false)
  static var UseToolbar         = () => !empty(kUserSettings.toolbaritems) && has('menu')
  static var ToolbarItems       = () => kUserSettings.toolbaritems
  static var ToolbarActions     = () => kUserSettings.toolbaractions_
endclass
