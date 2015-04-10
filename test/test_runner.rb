require_relative 'helper'

require_relative 'support/test_enumerable_source'

class TestRunner < Kiba::Test
  let(:control) do
    control = Kiba::Control.new
    # this will yield a single row for testing
    control.sources << {klass: TestEnumerableSource, args: [[{field: 'value'}]]}
    control
  end

  def test_block_transform_processing
    # is there a better way to assert a block was called in minitest?
    control.transforms << Kiba::Transform.new { |r| @called = true; r }
    Kiba.run(control)
    assert_equal true, @called
  end

  def test_dismissed_row_not_passed_to_next_transform
    control.transforms << Kiba::Transform.new { |r| nil }
    control.transforms << Kiba::Transform.new { |r| @called = true; nil}
    Kiba.run(control)
    assert_nil @called
  end

end
