require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.pattern = "test/test_*.rb"
end

# A simple check to verify TruffleRuby installation trick is really in effect
task :show_ruby_version do
  puts "Running with #{RUBY_DESCRIPTION}"
end

task default: [:show_ruby_version, :test]
