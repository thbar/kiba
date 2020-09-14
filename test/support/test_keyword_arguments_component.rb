# a mock component to test Ruby 3 keyword argument support
class TestKeywordArgumentsComponent
  def initialize(mandatory:, optional: nil, on_init: nil)
    values = {
      mandatory: mandatory,
      optional: optional
    }
    on_init&.call(values)
  end
  
  def each
    # no-op
  end
end
