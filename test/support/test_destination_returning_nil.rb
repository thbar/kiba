class TestDestinationReturningNil
  def initialize(options = {})
    on_init = options[:on_init]
    # A little trick to allow outer references to this instance
    on_init.call(self) if on_init
  end
  
  def write(row)
    (@written_rows ||= []) << row
    nil
  end
end