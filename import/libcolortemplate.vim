vim9script

export const VERSION = '3.0.0-beta3'

import './colortemplate/colorscheme.vim'    as colorscheme
import './colortemplate/parser/v3.vim'      as v3parser
import './colortemplate/generator/base.vim' as base
import './colortemplate/colorstats.vim'     as colorstats

export type  Colorscheme      = colorscheme.Colorscheme
export type  ParserResult     = v3parser.ParserResult
export const Parser           = v3parser.Template
export const Parse            = v3parser.Parse
export type  Generator        = base.IGenerator
export const ColorStats       = colorstats.ColorStats
