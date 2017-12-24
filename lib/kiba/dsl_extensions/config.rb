module Kiba
  module DSLExtensions
    module Config
      def config(context, context_config)
        (@control.config[context] ||= {}).merge!(context_config)
      end
    end
  end
end