module Kiba
  module Parser
    def parse(&source_as_block)
      control = Kiba::Control.new
      context = Kiba::Context.new(control)
      context.instance_eval(&source_as_block)
      control
    end
  end
end
