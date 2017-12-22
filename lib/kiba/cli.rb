require 'kiba'
require 'optparse'

module Kiba
  class Cli
    def self.run(args)
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: kiba your-script.etl [options]"
        opts.on("-r", "--runner [RUNNER_CLASS]", "Specify Kiba runner class") do |runner|
          options[:runner] = runner
        end
      end.parse!(args)

      unless args.size == 1
        puts 'Usage: kiba your-script.etl'
        exit(-1)
      end
      filename = args[0]
      script_content = IO.read(filename)
      job_definition = Kiba.parse(script_content, filename)
      runner_instance(options).run(job_definition)
    end
    
    def self.runner_instance(options)
      runner_class = options[:runner]
      runner_class = runner_class ? Object.const_get(runner_class) : Kiba::Runner
      runner = Object.new
      runner.extend(runner_class)
      runner
    end
  end
end
