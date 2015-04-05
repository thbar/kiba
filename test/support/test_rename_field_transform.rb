class TestRenameFieldTransform
  def initialize(from, to)
    @from = from
    @to = to
  end

  def process(row)
    row[@to] = row.delete(@from)
    row
  end
end
