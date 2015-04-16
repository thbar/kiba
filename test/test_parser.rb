require_relative 'helper'

require_relative 'support/test_rename_field_transform'

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
  
  def test_block_transform_definition
    control = Kiba.parse do
      transform { |row| row }
    end

    assert_instance_of Proc, control.transforms[0]
  end

  def test_class_transform_definition
    control = Kiba.parse do
      transform TestRenameFieldTransform, :last_name, :name
    end

    assert_equal TestRenameFieldTransform, control.transforms[0][:klass]
    assert_equal [:last_name, :name], control.transforms[0][:args]
  end
  
  def test_destination_definition
    control = Kiba.parse do
      destination DummyClass, 'has', 'args'
    end
    
    assert_equal DummyClass, control.destinations[0][:klass]
    assert_equal ['has', 'args'], control.destinations[0][:args]
  end
  
  def test_block_post_process_definition
    control = Kiba.parse do
      post_process { }
    end
    
    assert_instance_of Proc, control.post_processes[0]
  end
  
  def test_source_as_string_parsing
    control = Kiba.parse <<RUBY
      source DummyClass, 'from', 'file'
RUBY
    
    assert_equal 1, control.sources.size
    assert_equal DummyClass, control.sources[0][:klass]
    assert_equal ['from', 'file'], control.sources[0][:args]
  end
  
  def test_source_as_file_doing_require
    IO.write 'test/tmp/etl-common.rb', <<RUBY
      def common_source_declaration
        source DummyClass, 'from', 'common'
      end
RUBY
    IO.write 'test/tmp/etl-main.rb', <<RUBY
      require './test/tmp/etl-common.rb'
      
      source DummyClass, 'from', 'main'
      common_source_declaration
RUBY
    control = Kiba.parse IO.read('test/tmp/etl-main.rb')
    
    assert_equal 2, control.sources.size

    assert_equal ['from', 'main'], control.sources[0][:args]
    assert_equal ['from', 'common'], control.sources[1][:args]
    
  ensure
    remove_files('test/tmp/etl-common.rb', 'test/tmp/etl-main.rb')
  end
end