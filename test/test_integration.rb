require_relative 'helper'

require_relative 'support/test_csv_source'
require_relative 'support/test_csv_destination'
require_relative 'support/test_rename_field_transform'

# End-to-end tests go here
class TestIntegration < Kiba::Test
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

  def setup
    remove_files(input_file, output_file)
    IO.write(input_file, sample_csv_data)
  end

  def teardown
    remove_files(input_file, output_file)
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
end
