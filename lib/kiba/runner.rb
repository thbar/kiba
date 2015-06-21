module Kiba
  module Runner
    # allow to handle a block form just like a regular transform
    class AliasingProc < Proc
      alias_method :process, :call
    end
    
    def run(control)
      # instantiate early so that error are raised before any processing occurs
      pre_processes = to_instances(control.pre_processes, true, false)
      sources = to_instances(control.sources)
      destinations = to_instances(control.destinations)
      transforms = to_instances(control.transforms, true)
      post_processes = to_instances(control.post_processes, true, false)

      pre_processes.each(&:call)
      process_rows(sources, transforms, destinations)
      destinations.each(&:close)
      post_processes.each(&:call)
    end
    
    def process_rows(sources, transforms, destinations)
      sources.each do |source|
        source.each do |row|
          transforms.each do |transform|
            row = transform.process(row)
            break unless row
          end
          next unless row
          destinations.each do |destination|
            destination.write(row)
          end
        end
      end
    end

    # not using keyword args because JRuby defaults to 1.9 syntax currently
    def to_instances(definitions, allow_block = false, allow_class = true)
      definitions.map do |d|
        if d[:klass]
          fail 'Class form is not allowed here' unless allow_class
          d[:klass].new(*d[:args])
        elsif d[:block]
          fail 'Block form is not allowed here' unless allow_block
          AliasingProc.new(&d[:block])
        else
          # TODO: support block passing to a class form definition?
          fail "Class and block form cannot be used together at the moment"
        end
      end
    end
  end
end
