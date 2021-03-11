class TestDuplicateRowTranform
  def process(row)
    2.times do
      # NOTE: it's a good idea to carefully avoid data reuse between rows
      yield({item: row.fetch(:item).dup})
    end
    nil
  end
end
