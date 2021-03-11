module Kiba
  module StreamingRunner
    extend self

    # allow to handle a block form just like a regular transform
    class AliasingProc < Proc
      alias_method :process, :call
    end

    def run(control)
      run_pre_processes(control)
      process_rows(
        to_instances(control.sources),
        to_instances(control.transforms, true),
        destinations = to_instances(control.destinations)
      )
      close_destinations(destinations)
      run_post_processes(control)
    end

    def run_pre_processes(control)
      to_instances(control.pre_processes, true, false).each(&:call)
    end

    def run_post_processes(control)
      to_instances(control.post_processes, true, false).each(&:call)
    end

    def close_destinations(destinations)
      destinations
      .find_all { |d| d.respond_to?(:close) }
      .each(&:close)
    end

    def transform_stream(stream, t)
      Enumerator.new do |y|
        stream.each do |input_row|
          returned_row = t.process(input_row) do |yielded_row|
            y << yielded_row
          end
          y << returned_row if returned_row
        end
        if t.respond_to?(:close)
          t.close do |close_row|
            y << close_row
          end
        end
      end
    end
    
    def source_stream(sources)
      Enumerator.new do |y|
        sources.each do |source|
          source.each { |r| y << r }
        end
      end
    end

    def process_rows(sources, transforms, destinations)
      stream = source_stream(sources)
      recurser = lambda { |s,t| transform_stream(s, t) }
      transforms.inject(stream, &recurser).each do |r|
        destinations.each { |d| d.write(r) }
      end
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
      if klass && block
        fail 'Class and block form cannot be used together at the moment'
      elsif klass
        fail 'Class form is not allowed here' unless allow_class
        klass.new(*args)
      elsif block
        fail 'Block form is not allowed here' unless allow_block
        AliasingProc.new(&block)
      else
        fail 'Nil parameters not allowed here'
      end
    end
  end
end