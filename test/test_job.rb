require_relative 'helper'

require_relative 'support/test_csv_source'
require_relative 'support/test_csv_destination'
require_relative 'support/test_rename_field_transform'
require_relative 'support/test_enumerable_source'
require_relative 'support/test_source_that_reads_at_instantiation_time'

# End-to-end tests go here
class TestJob < Kiba::Test
  let(:output_file) { 'test/tmp/output.csv' }
  let(:input_file) { 'test/tmp/input.csv' }

  let(:sample_csv_data) do
    <<CSV
first_name,last_name,sex
John,Doe,M
Mary,Johnson,F
Cindy,Backgammon,F
Patrick,McWire,M
CSV
  end

  def clean
    remove_files(*Dir['test/tmp/*.csv'])
  end

  def setup
    clean
    IO.write(input_file, sample_csv_data)
  end

  def teardown
    clean
  end

  class CsvToCsvJob # < Kiba::Job
    include Kiba::Job
    source TestCsvSource, 'test/tmp/input.csv'
    transform do |row|
      row[:sex] = case row[:sex]
                  when 'M' then 'Male'
                  when 'F' then 'Female'
                  else 'Unknown'
      end
      row # must be returned
    end
    transform do |row|
      row[:sex] == 'Female' ? row : nil
    end
    transform TestRenameFieldTransform, :sex, :sex_2015
    destination TestCsvDestination, 'test/tmp/output.csv'
  end

  class VariableAccessJob
    include Kiba::Job
    source TestEnumerableSource, [1, 2, 3]
    def initialize
      @count = 0 # assign a first value
    end
    pre_process do
      @count += 100 # then change it from there (run time)
    end
    transform do |r|
      @count += 1 # increase it once per row
      r
    end
    def message
      "Count is now #{@count}"
    end
  end

  class FileCreationJob
    include Kiba::Job
    pre_process do
      IO.write('test/tmp/eager.csv', 'something')
    end
    source SourceThatReadsAtInstantionTime, 'test/tmp/eager.csv'
  end

  def test_csv_to_csv
    CsvToCsvJob.new.run

    # verify the output
    assert_equal <<CSV, IO.read(output_file)
first_name,last_name,sex_2015
Mary,Johnson,Female
Cindy,Backgammon,Female
CSV
  end

  def test_variable_access
    job = VariableAccessJob.new
    assert_equal 'Count is now 0', job.message
    job.run
    assert_equal 'Count is now 103', job.message
  end

  def test_file_created_by_pre_process_can_be_read_by_source_at_instantiation_time
    remove_files('test/tmp/eager.csv')
    FileCreationJob.new.run
  end

  class OptionsAccessJob
    include Kiba::Job
    source TestCsvSource, 'test/tmp/input.csv'
    pre_process do
      print "pre_process:#{options.inspect}"
    end
    transform do |row|
      print "transform:#{options.inspect}"
    end
    post_process do
      print "post_process:#{options.inspect}"
    end
    def initialize(more_options = {})
      @options ||= {}
      @options = @options.merge(more_options)
    end
  end


  def test_options_access
    real_stdout = $stdout
    $stdout = StringIO.new
    OptionsAccessJob.new(a: 1, b: 1).run(b: 2)
    output = $stdout.string
    $stdout = real_stdout
    assert_equal output, "pre_process:{:a=>1, :b=>2}transform:{:a=>1, :b=>2}transform:{:a=>1, :b=>2}transform:{:a=>1, :b=>2}transform:{:a=>1, :b=>2}post_process:{:a=>1, :b=>2}"
  end

end
