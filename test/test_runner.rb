require_relative 'helper'
require 'minitest/mock'
require_relative 'support/test_enumerable_source'

class TestRunner < Kiba::Test
  let(:rows) do
    [
      { field: 'value' },
      { field: 'other-value' }
    ]
  end
  
  let(:control) do
    control = Kiba::Control.new
    # this will yield a single row for testing
    control.sources << {
      klass: TestEnumerableSource,
      args: [rows]
    }
    control
  end

  def test_block_transform_processing
    # is there a better way to assert a block was called in minitest?
    control.transforms << { block: lambda { |r| @called = true; r } }
    Kiba.run(control)
    assert_equal true, @called
  end

  def test_dismissed_row_not_passed_to_next_transform
    @called = nil
    control.transforms << { block: lambda { |_| nil } }
    control.transforms << { block: lambda { |_| @called = true; nil } }
    Kiba.run(control)
    assert_nil @called
  end

  def test_post_process_runs_once
    assert_equal 2, rows.size
    @called = 0
    control.post_processes << { block: lambda { @called += 1 } }
    Kiba.run(control)
    assert_equal 1, @called
  end

  def test_post_process_not_called_after_row_failure
    @called = nil
    control.transforms << { block: lambda { |_| fail 'FAIL' } }
    control.post_processes << { block: lambda { @called = true } }
    assert_raises(RuntimeError, 'FAIL') { Kiba.run(control) }
    assert_nil @called
  end
  
  def test_pre_process_runs_once
    assert_equal 2, rows.size
    @called = 0
    control.pre_processes << { block: lambda { @called += 1 } }
    Kiba.run(control)
    assert_equal 1, @called
  end

  def test_pre_process_runs_before_source_is_instantiated
    calls = []

    mock_source_class = MiniTest::Mock.new
    mock_source_class.expect(:new, TestEnumerableSource.new([1, 2, 3])) do
      calls << :source_instantiated
    end

    control = Kiba::Control.new
    control.pre_processes << { block: lambda { calls << :pre_processor_executed } }
    control.sources << { klass: mock_source_class }
    Kiba.run(control)

    assert_equal [:pre_processor_executed, :source_instantiated], calls
  end
  
  def test_no_error_raised_if_destination_close_not_implemented
    # NOTE: this fake destination does not implement `close`
    destination_instance = MiniTest::Mock.new

    mock_destination_class = MiniTest::Mock.new
    mock_destination_class.expect(:new, destination_instance)
    
    control = Kiba::Control.new
    control.destinations << { klass: mock_destination_class }
    Kiba.run(control)
  end
end
