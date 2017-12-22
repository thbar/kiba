# encoding: utf-8
require 'kiba/version'

require 'kiba/control'
require 'kiba/context'
require 'kiba/parser'
require 'kiba/runner'
require 'kiba/alternate_runner'

Kiba.extend(Kiba::Parser)
Kiba.extend(Kiba::Runner)
