class AggregateTransform
  def initialize(aggregate_size:)
    @aggregate_size = aggregate_size
  end
  
  def process(row)
    @buffer ||= []
    @buffer << row
    if @buffer.size == @aggregate_size
      yield @buffer
      @buffer = []
    end
    nil
  end
  
  def close
    yield @buffer unless @buffer.empty?
  end
end
