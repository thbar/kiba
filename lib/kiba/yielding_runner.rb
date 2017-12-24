module Kiba
  module YieldingRunner
    include Runner
    extend self
    
    def transform_stream(from, t)
      Enumerator::Lazy.new(from) do |yielder, input_row|
        returned_row = t.process(input_row) do |yielded_row|
          yielder << yielded_row
        end
        yielder << returned_row if returned_row
      end
    end
    
    def source_stream(sources)
      Enumerator::Lazy.new(sources) do |yielder, source|
        source.each { |r| yielder << r }
      end.lazy
    end

    def process_rows(sources, transforms, destinations)
      stream = source_stream(sources)
      recurser = lambda { |stream,t| transform_stream(stream, t) }
      transforms.inject(stream, &recurser).each do |r|
        destinations.each { |d| d.write(r) }
      end
    end
  end
end