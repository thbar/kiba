module Kiba
  # WIP
  module AlternateRunner
    # allow to handle a block form just like a regular transform
    class AliasingProc < Proc
      alias_method :process, :call
    end

    def run(control)
      # TODO: add a dry-run (not instantiating mode) to_instances call
      # that will validate the job definition from a syntax pov before
      # going any further. This could be shared with the parser.
      run_pre_processes(control)
      process_rows(
        to_instances(control.sources),
        to_instances(control.transforms, true),
        to_instances(control.destinations)
      )
      # TODO: when I add post processes as class, I'll have to add a test to
      # make sure instantiation occurs after the main processing is done (#16)
      run_post_processes(control)
    end

    def run_pre_processes(control)
      to_instances(control.pre_processes, true, false).each(&:call)
    end

    def run_post_processes(control)
      to_instances(control.post_processes, true, false).each(&:call)
    end

    def lazy_transform(from, t)
      Enumerator::Lazy.new(from) do |yielder, input_row|
        final_row = t.process(input_row) do |yielded_row|
          yielder << yielded_row
        end
        yielder << final_row if final_row
      end
    end
    
    def process_rows(sources, transforms, destinations)
      source_rows = Enumerator::Lazy.new(sources) do |yielder, source|
        source.each do |row|
          yielder << row
        end
      end

      rows = source_rows.lazy
      
      transforms.each do |transform|
        rows = lazy_transform(rows, transform)
      end
      
      rows.each do |row|
        destinations.each do |destination|
          destination.write(row)
        end
      end
      destinations.find_all { |d| d.respond_to?(:close) }.each(&:close)
    end

    # not using keyword args because JRuby defaults to 1.9 syntax currently
    def to_instances(definitions, allow_block = false, allow_class = true)
      definitions.map do |definition|
        to_instance(
          *definition.values_at(:klass, :args, :block),
          allow_block, allow_class
        )
      end
    end

    def to_instance(klass, args, block, allow_block, allow_class)
      if klass
        fail 'Class form is not allowed here' unless allow_class
        klass.new(*args)
      elsif block
        fail 'Block form is not allowed here' unless allow_block
        AliasingProc.new(&block)
      else
        # TODO: support block passing to a class form definition?
        fail 'Class and block form cannot be used together at the moment'
      end
    end
  end
end
