class TestYieldingTransform
  def process(row)
    row.fetch(:tags).each do |value|
      yield({item: value})
    end
    {item: "classic-return-value"}
  end
end