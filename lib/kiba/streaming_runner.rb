module Kiba
  module StreamingRunner
    include Runner
    extend self
    
    def transform_stream(stream, t)
      Enumerator.new do |y|
        stream.each do |input_row|
          returned_row = t.process(input_row) do |yielded_row|
            y << yielded_row
          end
          y << returned_row if returned_row
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
      recurser = lambda { |stream,t| transform_stream(stream, t) }
      transforms.inject(stream, &recurser).each do |r|
        destinations.each { |d| d.write(r) }
      end
    end
  end
end