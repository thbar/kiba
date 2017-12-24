module Kiba
  module YieldingRunner
    include Runner
    extend self
    
    def lazy_transform(from, t)
      Enumerator::Lazy.new(from) do |yielder, input_row|
        returned_row = t.process(input_row) do |yielded_row|
          yielder << yielded_row
        end
        yielder << returned_row if returned_row
      end
    end
    
    def lazy_source_rows(sources)
      Enumerator::Lazy.new(sources) do |yielder, source|
        source.each do |row|
          yielder << row
        end
      end.lazy
    end

    def process_rows(sources, transforms, destinations)
      rows = lazy_source_rows(sources)
      
      transforms.each do |transform|
        rows = lazy_transform(rows, transform)
      end
      
      rows.each do |row|
        destinations.each do |destination|
          destination.write(row)
        end
      end
    end
  end
end