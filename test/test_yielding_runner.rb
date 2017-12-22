require_relative 'helper'
require 'minitest/mock'
require_relative 'support/test_enumerable_source'
require_relative 'support/test_array_destination'
require_relative 'support/test_yielding_transform'
require_relative 'common/runner'
require 'kiba/yielding_runner'

class TestYieldingRunner < Kiba::Test
  include SharedRunnerTests
  
  def kiba_run(job)
    runner = Object.new
    runner.extend(Kiba::YieldingRunner)
    runner.run(job)
  end

  def test_yielding_class_transform
    input_row = {tags: ["one", "two", "three"]}
    destination_array = []
    
    job = Kiba.parse do
      source TestEnumerableSource, [input_row]
      transform TestYieldingTransform
      destination TestArrayDestination, destination_array
    end
    
    kiba_run(job)
  
    assert_equal [
      {item: 'one'},
      {item: 'two'},
      {item: 'three'},
      {item: 'classic-return-value'}
    ], destination_array
  end
end
