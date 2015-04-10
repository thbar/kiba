require_relative 'helper'

require_relative 'support/test_rename_field_transform'

class TestTransform < Kiba::Test
  def test_class_transform
    transform = Kiba::Transform.new(TestRenameFieldTransform, :sex, :sex_2015)
    transform.prepare
    row      = { sex: 'M' }
    expected = { sex_2015: 'M' }
    transform.process(row)

    assert_equal expected, row
  end

  def test_proc_transform
    transform = Kiba::Transform.new do |row|
      row[:sex_2015] = row.delete(:sex)
    end

    transform.prepare
    row      = { sex: 'M' }
    expected = { sex_2015: 'M' }
    transform.process(row)

    assert_equal expected, row
  end

  def test_error_transform
    assert_raises(ArgumentError) { Kiba::Transform.new }
  end
end
