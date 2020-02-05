module Kiba
  class Context
    def initialize(control)
      @control = control
    end

    def pre_process(&block)
      @control.pre_processes << { block: block }
    end

    def source(klass, *initialization_params, **kwargs)
      @control.sources << { klass: klass, args: initialization_params, kwargs: kwargs }
    end

    def transform(klass = nil, *initialization_params, **kwargs, &block)
      @control.transforms << { klass: klass, args: initialization_params, kwargs: kwargs, block: block }
    end

    def destination(klass, *initialization_params, **kwargs)
      @control.destinations << { klass: klass, args: initialization_params, kwargs: kwargs }
    end

    def post_process(&block)
      @control.post_processes << { block: block }
    end
  end
end
