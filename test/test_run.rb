require_relative "helper"
require "minitest/mock"
require_relative "support/test_enumerable_source"
require_relative "support/test_array_destination"

class TestRun < Kiba::Test
  def test_ensure_kiba_defaults_to_streaming_runner
    cb = ->(job) { "Streaming runner called" }
    Kiba::StreamingRunner.stub(:run, cb) do
      job = Kiba::Control.new
      assert_equal "Streaming runner called", Kiba.run(job)
    end
  end

  def test_run_allows_block_arg
    rows = []
    Kiba.run do
      source TestEnumerableSource, (1..10)
      destination TestArrayDestination, rows
    end
    assert_equal (1..10).to_a, rows
  end

  def test_forbids_no_arg
    assert_raises ArgumentError do
      Kiba.run
    end
  end

  def test_forbids_multiple_args
    assert_raises ArgumentError do
      job = Kiba.parse {}
      Kiba.run(job) do
      end
    end
  end
end
