require "minitest/autorun"
require "minitest/pride"
require "minitest/focus"
require "kiba"

if ENV["CI"] == "true"
  puts "Running with Minitest version #{Minitest::VERSION}"
end

class Kiba::Test < Minitest::Test
  def remove_files(*files)
    files.each do |file|
      File.delete(file) if File.exist?(file)
    end
  end

  def fixture(file)
    File.join(File.dirname(__FILE__), "fixtures", file)
  end

  unless method_defined?(:assert_mock)
    def assert_mock(mock)
      mock.verify
    end
  end
end
