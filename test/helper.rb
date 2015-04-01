require 'minitest/autorun'
require 'minitest/pride'
require 'kiba'

class Kiba::Test < Minitest::Test
  extend Minitest::Spec::DSL

  def remove_files(*files)
    files.each do |file|
      File.delete(file) if File.exists?(file)
    end
  end
end
