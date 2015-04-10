module Kiba
  class Control
    def sources
      @sources ||= []
    end

    def transforms
      @transforms ||= []
    end

    def destinations
      @destinations ||= []
    end
  end
end
