# a mock component to test Ruby 3 keyword argument support
class TestMixedArgumentsComponent
  def initialize(some_value, mandatory:, optional: nil, on_init:)
    @values = {}
    @values[:some_value] = some_value
    @values[:mandatory] = mandatory
    @values[:optional] = optional
    on_init&.call(@values)
  end
  
  def each
    # no-op
  end
end
