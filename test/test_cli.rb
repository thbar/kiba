require_relative 'helper'
require 'kiba/cli'

class TestCli < Kiba::Test
  def test_cli_launches
    Kiba::Cli.run([fixture('valid.etl')])
  end
end