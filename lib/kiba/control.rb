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

    def post_processes
      @post_processes ||= []
    end
  end
end