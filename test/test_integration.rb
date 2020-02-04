require_relative 'helper'

require_relative 'support/test_csv_source'
require_relative 'support/test_csv_destination'
require_relative 'support/test_rename_field_transform'
require_relative 'support/test_enumerable_source'
require_relative 'support/test_source_that_reads_at_instantiation_time'
require_relative 'support/test_keyword_arguments_source'

# End-to-end tests go here
class TestIntegration < Kiba::Test
  def output_file; 'test/tmp/output.csv'; end
  def input_file; 'test/tmp/input.csv'; end

  def sample_csv_data
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

  def test_csv_to_csv
    # parse the ETL script (this won't run it)
    control = Kiba.parse do
      source TestCsvSource, 'test/tmp/input.csv'

      transform do |row|
        row[:sex] = case row[:sex]
                    when 'M' then 'Male'
                    when 'F' then 'Female'
                    else 'Unknown'
        end
        row # must be returned
      end

      # returning nil dismisses the row
      transform do |row|
        row[:sex] == 'Female' ? row : nil
      end

      transform TestRenameFieldTransform, :sex, :sex_2015

      destination TestCsvDestination, 'test/tmp/output.csv'
    end

    # run the parsed ETL script
    Kiba.run(control)

    # verify the output
    assert_equal <<CSV, IO.read(output_file)
first_name,last_name,sex_2015
Mary,Johnson,Female
Cindy,Backgammon,Female
CSV
  end

  def test_variable_access
    message = nil

    control = Kiba.parse do
      source TestEnumerableSource, [1, 2, 3]

      # assign a first value at parsing time
      count = 0

      pre_process do
        # then change it from there (run time)
        count += 100
      end

      transform do |r|
        # increase it once per row
        count += 1
        r
      end

      post_process do
        # and save so we can assert
        message = "Count is now #{count}"
      end
    end

    Kiba.run(control)

    assert_equal 'Count is now 103', message
  end

  def test_file_created_by_pre_process_can_be_read_by_source_at_instantiation_time
    remove_files('test/tmp/eager.csv')

    control = Kiba.parse do
      pre_process do
        IO.write('test/tmp/eager.csv', 'something')
      end

      source SourceThatReadsAtInstantionTime, 'test/tmp/eager.csv'
    end

    Kiba.run(control)
  end
  
  def test_ruby_3_keyword_arguments
    job = Kiba.parse do
      source TestKeywordArgumentsSource,
        mandatory: "first"
    end
    
    # NOTE: a Ruby warning would be usually captured here
    assert_silent do
      Kiba.run(job)
    end
  end
end
