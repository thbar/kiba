module Kiba
  module Job
    module ClassMethods
      def pre_process(&block)
        control.pre_processes << { block: block }
      end

      def source(klass, *initialization_params)
        control.sources << { klass: klass, args: initialization_params }
      end

      def transform(klass = nil, *initialization_params, &block)
        control.transforms << { klass: klass, args: initialization_params, block: block }
      end

      def destination(klass, *initialization_params)
        control.destinations << { klass: klass, args: initialization_params }
      end

      def post_process(&block)
        control.post_processes << { block: block }
      end

      def control
        instance_variable_get(:@control)
      end
    end

    module InstanceMethods
      def run(options = {})
        @options ||= {}
        @options = @options.merge(options)
        super self.class.control
      end
    end

    def self.included(base)
      base.send :include, Runner
      base.send :include, InstanceMethods
      base.send :attr_accessor, :options
      base.instance_variable_set :@control, Control.new
      base.extend ClassMethods
    end

  end
end
