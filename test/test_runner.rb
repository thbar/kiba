require_relative 'helper'
require_relative 'shared_runner_tests'

class TestRunner < Kiba::Test
  def kiba_run(job)
    job.config[:kiba] = {runner: Kiba::Runner}
    Kiba.run(job)
  end

  include SharedRunnerTests
end
