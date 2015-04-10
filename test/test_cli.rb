require_relative 'helper'
require 'kiba/cli'

class TestCli < Kiba::Test
  def test_cli_launches
    Kiba::Cli.run([fixture('valid.etl')])
  end

  def test_cli_reports_filename_and_lineno
    exception = assert_raises(NameError) do
      Kiba::Cli.run([fixture('bogus.etl')])
    end

    assert_match /uninitialized constant (.*)UnknownThing/, exception.message
    assert_includes exception.backtrace.to_s, 'test/fixtures/bogus.etl:2:in'
  end
end
