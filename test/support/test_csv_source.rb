require 'csv'

class TestCsvSource
  def initialize(input_file)
    @csv = CSV.open(input_file, headers: true, header_converters: :symbol)
  end

  def each
    @csv.each do |row|
      yield(row.to_h)
    end
    @csv.close
  end
end
