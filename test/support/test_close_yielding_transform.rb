class CloseYieldingTransform
  def initialize(yield_on_close:)
    @yield_on_close = yield_on_close
  end

  def close
    @yield_on_close.each do |item|
      yield item
    end
  end
end
