require_relative 'helper'
require 'minitest/mock'
require_relative 'support/test_enumerable_source'
require_relative 'support/test_array_destination'
require_relative 'support/test_yielding_transform'
require_relative 'common/runner'

class TestAlternateRunner < Kiba::Test
  include SharedRunnerTests
  
  def kiba_run(job)
    runner = Object.new
    runner.extend(Kiba::AlternateRunner)
    runner.run(job)
  end
  
  
  def test_yielding_class_transform
    input_row = {tags: ["one", "two", "three"]}
    
    control = Kiba::Control.new
    control.sources << {
      klass: TestEnumerableSource,
      args: [[input_row]]
    }
    control.transforms << { 
      klass: TestYieldingTransform
    }
    array = []
    control.destinations << {
      klass: TestArrayDestination,
      args: [array]
    }
    
    kiba_run(control)
  
    assert_equal [
      {item: 'one'},
      {item: 'two'},
      {item: 'three'},
      {item: 'classic-return-value'}
    ], array
  end
end
