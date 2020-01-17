# encoding: utf-8
require 'kiba/version'

require 'kiba/control'
require 'kiba/context'
require 'kiba/parser'
require 'kiba/runner'
require 'kiba/streaming_runner'
require 'kiba/dsl_extensions/config'

Kiba.extend(Kiba::Parser)

module Kiba
  def self.run(job)
    # NOTE: use Hash#dig when Ruby 2.2 reaches EOL
    runner = job.config.fetch(:kiba, {}).fetch(:runner, Kiba::StreamingRunner)
    runner.run(job)
  end
end
