module Kiba
  module Runner
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
            # TODO: avoid the case completely by e.g. subclassing Proc
            # and aliasing `process` to `call`. Benchmark needed first though.
            if transform.is_a?(Proc)
              row = transform.call(row)
            else
              row = transform.process(row)
            end
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
        case d
        when Proc
          fail 'Block form is not allowed here' unless allow_block
          d
        else
          fail 'Class form is not allowed here' unless allow_class
          d[:klass].new(*d[:args])
        end
      end
    end
  end
end
