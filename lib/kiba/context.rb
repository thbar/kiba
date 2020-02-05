module Kiba
  class Context
    def initialize(control)
      @control = control
    end

    def pre_process(&block)
      @control.pre_processes << { block: block }
    end

    if RUBY_VERSION >= '2.7'
      # Keyword arguments are processed as something specific and separate
      def source(klass, *initialization_params, **kwargs)
        @control.sources << { klass: klass, args: initialization_params, kwargs: kwargs }
      end

      def transform(klass = nil, *initialization_params, **kwargs, &block)
        @control.transforms << { klass: klass, args: initialization_params, kwargs: kwargs, block: block }
      end

      def destination(klass, *initialization_params, **kwargs)
        @control.destinations << { klass: klass, args: initialization_params, kwargs: kwargs }
      end
    else
      # Keyword arguments are handled as regular arguments
      def source(klass, *initialization_params)
        @control.sources << { klass: klass, args: initialization_params }
      end

      def transform(klass = nil, *initialization_params, &block)
        @control.transforms << { klass: klass, args: initialization_params, block: block }
      end

      def destination(klass, *initialization_params)
        @control.destinations << { klass: klass, args: initialization_params }
      end
    end

    def post_process(&block)
      @control.post_processes << { block: block }
    end
  end
end
