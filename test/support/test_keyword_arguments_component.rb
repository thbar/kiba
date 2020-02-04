# a mock component to test Ruby 3 keyword argument support
class TestKeywordArgumentsComponent
  def initialize(mandatory:, optional: nil)
    @mandatory = mandatory
    @optional = optional
  end
  
  def each
    # no-op
  end
end
