require_relative 'helper'

class TestParser < Minitest::Test
  # first experiment at row-based DSL declaration and parsing
  def test_block_parsing
    control = Kiba.parse do
      source {
        (1..5).each do |i|
          yield(number: i)
        end
      }
      
      transform { |r|
        r[:sentence] = "Number #{r[:number]} is there"
        r
      }
    end

    assert_equal control.sources.size, 1
    assert_equal control.transforms.size, 1
  end
end