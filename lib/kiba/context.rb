module Kiba
  class Context
    attr_accessor :block_self

    def initialize(control)
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

    def method_missing(method, *args, &block)
      if block_self
        block_self.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, *)
      if block_self
        block_self.respond_to?(method)
      else
        super
      end
    end
  end
end
