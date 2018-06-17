require_relative 'helper'
require 'kiba/cli'
require_relative 'support/test_aggregate_transform'
require_relative 'support/test_non_closing_transform'

class TestBufferingTransform < Kiba::Test
  def test_buffering_transform
    destination_array = []
    job = Kiba.parse do
      extend Kiba::DSLExtensions::Config
      config :kiba, runner: Kiba::StreamingRunner

      source TestEnumerableSource, (1..12)
      # ensure that a non closing transform won't raise an error
      transform NonClosingTransform
      transform AggregateTransform, aggregate_size: 5
      destination TestArrayDestination, destination_array
    end
    Kiba.run(job)
    assert_equal [
      [1, 2, 3, 4, 5],
      [6, 7, 8, 9, 10],
      [11, 12]
    ], destination_array
  end
end