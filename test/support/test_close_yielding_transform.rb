class CloseYieldingTransform
  def initialize(options)
    @yield_on_close = options.fetch(:yield_on_close)
  end

  def close
    @yield_on_close.each do |item|
      yield item
    end
  end
end
