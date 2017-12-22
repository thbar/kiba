require_relative 'helper'
require 'minitest/mock'
require_relative 'support/test_enumerable_source'
require_relative 'common/runner'

class TestRunner < Kiba::Test
  include SharedRunnerTests
end
