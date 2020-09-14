module Kiba
  class Context
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

    [:source, :transform, :destination].each do |m|
      ruby2_keywords(m) if respond_to?(:ruby2_keywords, true)
    end
  end
end
