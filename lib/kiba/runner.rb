module Kiba
  module Runner
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
