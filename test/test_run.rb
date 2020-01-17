require_relative 'helper'
require 'minitest/mock'

class TestRun < Kiba::Test
  def test_ensure_kiba_defaults_to_streaming_runner
    cb = -> (job) { "Streaming runner called" }
    Kiba::StreamingRunner.stub(:run, cb) do
      job = Kiba::Control.new
      assert_equal "Streaming runner called", Kiba.run(job)
    end
  end
end
