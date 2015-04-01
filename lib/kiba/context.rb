module Kiba
  class Context
    def initialize(control)
      # TODO: forbid access to control from context? use cleanroom?
      @control = control
    end

    def source(klass, *initialization_params)
      @control.sources << {klass: klass, args: initialization_params}
    end

    def transform(&block)
      @control.transforms << block
    end

    def destination(klass, *initialization_params)
      @control.destinations << {klass: klass, args: initialization_params}
    end
  end
end