require 'csv'

class TestCsvSource
  def initialize(input_file, csv_options = {})
    @csv = CSV.open(input_file, {headers: true, header_converters: :symbol}.merge(csv_options))
  end

  def each
    @csv.each do |row|
      yield(row.to_hash)
    end
    @csv.close
  end
end
