require 'minitest/mock'
require_relative 'support/test_enumerable_source'
require_relative 'support/test_destination_returning_nil'

module SharedRunnerTests
  def kiba_run(job)
    Kiba.run(job)
  end

  def rows
    @rows ||= [
      { identifier: 'first-row' },
      { identifier: 'second-row' }
    ]
  end
  
  def control
    @control ||= begin
      control = Kiba::Control.new
      # this will yield a single row for testing
      control.sources << {
        klass: TestEnumerableSource,
        args: [rows]
      }
      control
    end
  end
  
  def test_block_transform_processing
    # is there a better way to assert a block was called in minitest?
    control.transforms << { block: lambda { |r| @called = true; r } }
    kiba_run(control)
    assert_equal true, @called
  end

  def test_dismissed_row_not_passed_to_next_transform
    @called = nil
    control.transforms << { block: lambda { |_| nil } }
    control.transforms << { block: lambda { |_| @called = true; nil } }
    kiba_run(control)
    assert_nil @called
  end

  def test_post_process_runs_once
    assert_equal 2, rows.size
    @called = 0
    control.post_processes << { block: lambda { @called += 1 } }
    kiba_run(control)
    assert_equal 1, @called
  end

  def test_post_process_not_called_after_row_failure
    @called = nil
    control.transforms << { block: lambda { |_| fail 'FAIL' } }
    control.post_processes << { block: lambda { @called = true } }
    assert_raises(RuntimeError, 'FAIL') { kiba_run(control) }
    assert_nil @called
  end
  
  def test_pre_process_runs_once
    assert_equal 2, rows.size
    @called = 0
    control.pre_processes << { block: lambda { @called += 1 } }
    kiba_run(control)
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
    kiba_run(control)

    assert_equal [:pre_processor_executed, :source_instantiated], calls
    assert_mock mock_source_class
  end
  
  def test_no_error_raised_if_destination_close_not_implemented
    # NOTE: this fake destination does not implement `close`
    destination_instance = MiniTest::Mock.new

    mock_destination_class = MiniTest::Mock.new
    mock_destination_class.expect(:new, destination_instance)
    
    control = Kiba::Control.new
    control.destinations << { klass: mock_destination_class }
    kiba_run(control)
    assert_mock mock_destination_class
  end
  
  def test_destination_close_called_if_defined
    destination_instance = MiniTest::Mock.new
    destination_instance.expect(:close, nil)
    mock_destination_class = MiniTest::Mock.new
    mock_destination_class.expect(:new, destination_instance)

    control = Kiba::Control.new
    control.destinations << { klass: mock_destination_class }
    kiba_run(control)
    assert_mock destination_instance
    assert_mock mock_destination_class
  end
  
  def test_use_next_to_exit_early_from_block_transform
    assert_equal 2, rows.size

    # calling "return row" from a block is forbidden, but you can use "next" instead
    b = lambda do |row|
      if row.fetch(:identifier) == 'first-row'
        # demonstrate how to remove a row from the pipeline via next
        next
      else
        # demonstrate how you can reformat via next
        next({new_identifier: row.fetch(:identifier)})
      end
      fail "This should not be called"
    end
    control.transforms << { block: b }

    # keep track of the rows
    @remaining_rows = []
    checker = lambda { |row| @remaining_rows << row; row }
    control.transforms << { block: checker }

    kiba_run(control)
    
    # the first row should have been removed
    # and the second row should have been reformatted
    assert_equal [{new_identifier: 'second-row'}], @remaining_rows
  end
  
  def test_destination_returning_nil_does_not_remove_row_from_pipeline
    # safeguard to avoid modification on the support code
    assert_nil TestDestinationReturningNil.new.write("FOOBAR")

    destinations = []
    control = Kiba.parse do
      source TestEnumerableSource, [{key: 'value'}]
      2.times do
        destination TestDestinationReturningNil, on_init: lambda { |d| destinations << d }
      end
    end
    kiba_run(control)
    2.times do |i|
      assert_equal [{key: 'value'}], destinations[i].instance_variable_get(:@written_rows)
    end
  end

  def test_nil_transform_error_message
    control = Kiba.parse do
      transform
    end
    assert_raises(RuntimeError, 'Nil parameters not allowed here') { kiba_run(control) }
  end
end
