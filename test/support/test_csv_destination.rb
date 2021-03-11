require "csv"

# simple destination, not checking that each row has all the fields
class TestCsvDestination
  def initialize(output_file)
    @csv = CSV.open(output_file, "w")
    @headers_written = false
  end

  def write(row)
    unless @headers_written
      @headers_written = true
      @csv << row.keys
    end
    @csv << row.values
  end

  def close
    @csv.close
  end
end
