require_relative 'helper'

require_relative 'support/test_enumerable_source'

class TestRunner < Kiba::Test
  let(:control) do
    control = Kiba::Control.new
    # this will yield a single row for testing
    control.sources << {
      klass: TestEnumerableSource,
      args: [[{ field: 'value' }]]
    }
    control
  end

  def test_block_transform_processing
    # is there a better way to assert a block was called in minitest?
    control.transforms << lambda { |r| @called = true; r }
    Kiba.run(control)
    assert_equal true, @called
  end

  def test_dismissed_row_not_passed_to_next_transform
    control.transforms << lambda { |_| nil }
    control.transforms << lambda { |_| @called = true; nil }
    Kiba.run(control)
    assert_nil @called
  end

  def test_post_process_runs
    control.post_processes << lambda { @called = true }
    Kiba.run(control)
    assert_equal true, @called
  end

  def test_post_process_not_called_after_row_failure
    control.transforms << lambda { |_| fail 'FAIL' }
    control.post_processes << lambda { @called = true }
    assert_raises(RuntimeError, 'FAIL') { Kiba.run(control) }
    assert_nil @called
  end
end
