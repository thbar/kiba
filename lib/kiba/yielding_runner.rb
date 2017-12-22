module Kiba
  module YieldingRunner
    include Runner
    extend self
    
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
  end
end