module Kiba
  module Runner
    def run(control)
      sources      = instantiate(control.sources)
      destinations = instantiate(control.destinations)
      transforms   = control.transforms
      transforms.each(&:prepare)

      sources.each do |source|
        source.each do |original_row|
          apply_transforms(transforms, original_row) do |transformed_row|
            destinations.each do |destination|
              destination.write(transformed_row)
            end
          end
        end
      end

      destinations.each(&:close)
    end

    protected

    def instantiate(definitions)
      definitions.map { |d| d[:klass].new(*d[:args]) }
    end

    def apply_transforms(transforms, row)
      transforms.each do |transform|
        row = transform.process(row)
        return unless row # We are done here, do not write this row
      end

      yield row
    end
  end
end
