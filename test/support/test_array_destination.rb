class TestArrayDestination
  def initialize(array)
    @array = array
  end
  
  def write(row)
    @array << row
  end
end