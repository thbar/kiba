module Kiba
  module Runner
    def run(control)
      sources = to_instances(control.sources)
      destinations = to_instances(control.destinations)
      transforms = to_instances(control.transforms, true)
      
      sources.each do |source|
        source.each do |row|
          transforms.each_with_index do |transform, index|
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

      destinations.each(&:close)
    end

    def to_instances(definitions, allow_block = false)
      definitions.map do |d|
        case d
        when Proc
          raise "Block form is not allowed here" unless allow_block
          d
        else
          d[:klass].new(*d[:args])
        end
      end
    end
  end
end