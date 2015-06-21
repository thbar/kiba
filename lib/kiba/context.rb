module Kiba
  class Context
    def initialize(control)
      # TODO: forbid access to control from context? use cleanroom?
      @control = control
    end

    def pre_process(&block)
      @control.pre_processes << { block: block }
    end

    def source(klass, *initialization_params)
      @control.sources << { klass: klass, args: initialization_params }
    end

    def transform(klass = nil, *initialization_params, &block)
      @control.transforms << { klass: klass, args: initialization_params, block: block }
    end

    def destination(klass, *initialization_params)
      @control.destinations << { klass: klass, args: initialization_params }
    end

    def post_process(&block)
      @control.post_processes << { block: block }
    end
  end
end
