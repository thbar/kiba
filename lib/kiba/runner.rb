module Kiba
  module Runner
    def run(control)
      sources = to_instances(control.sources)
      destinations = to_instances(control.destinations)
      
      sources.each do |source|
        source.each do |row|
          # TODO: catch errors and redirect row to error handler
          # TODO: assert that we have a Hash here?
          control.transforms.each do |transform|
            row = transform.call(row)
            next unless row
          end
          next unless row
          destinations.each do |destination|
            destination.write(row)
          end
        end
      end

      destinations.each(&:close)
    end

    def to_instances(definitions)
      definitions.map { |d| d[:klass].new(*d[:args]) }
    end
  end
end