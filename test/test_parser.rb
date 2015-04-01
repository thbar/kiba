require_relative 'helper'

class DummyClass
end

class TestParser < Kiba::Test
  def test_source_definition
    control = Kiba.parse do
      source DummyClass, 'has', 'args'
    end
    
    assert_equal DummyClass, control.sources[0][:klass]
    assert_equal ['has', 'args'], control.sources[0][:args]
  end
  
  def test_transform_definition
    control = Kiba.parse do
      transform { |row| row }
    end

    assert_instance_of Proc, control.transforms[0]
  end
  
  def test_destination_definition
    control = Kiba.parse do
      destination DummyClass, 'has', 'args'
    end
    
    assert_equal DummyClass, control.destinations[0][:klass]
    assert_equal ['has', 'args'], control.destinations[0][:args]
  end
end