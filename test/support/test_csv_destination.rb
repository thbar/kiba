require "csv"

# simple destination, not checking that each row has all the fields
class TestCsvDestination
  def initialize(output_file)
    # `encoding` is specified explicitely because otherwise,
    # TruffleRuby will crash right here (and not the other Rubies).
    # See https://github.com/truffleruby/truffleruby/issues/4081
    @csv = CSV.open(output_file, "w", encoding: "UTF-8")
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
