class TestKeywordArgumentsSource
  def initialize(mandatory:, optional: nil)
    @mandatory = mandatory
    @optional = optional
  end
  
  def each
    yield @mandatory
    yield @optional if @optional
  end
end
