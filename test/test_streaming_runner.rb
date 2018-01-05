require_relative 'helper'
require_relative 'support/test_enumerable_source'
require_relative 'support/test_array_destination'
require_relative 'support/test_yielding_transform'
require_relative 'support/test_duplicate_row_transform'

require_relative 'common/runner'

class TestStreamingRunner < Kiba::Test
  include SharedRunnerTests
  
  def test_yielding_class_transform
    input_row = {tags: ["one", "two", "three"]}
    destination_array = []
    
    job = Kiba.parse do
      extend Kiba::DSLExtensions::Config

      config :kiba, runner: Kiba::StreamingRunner

      # provide a single row as the input
      source TestEnumerableSource, [input_row]

      # explode tags in one row each
      transform TestYieldingTransform

      # generate two rows out of each exploded tags row
      transform TestDuplicateRowTranform

      destination TestArrayDestination, destination_array
    end
    
    kiba_run(job)
  
    assert_equal [
      {item: 'one'},
      {item: 'one'},

      {item: 'two'},
      {item: 'two'},

      {item: 'three'},
      {item: 'three'},

      {item: 'classic-return-value'},
      {item: 'classic-return-value'}
    ], destination_array
  end
end
