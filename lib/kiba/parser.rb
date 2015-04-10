module Kiba
  module Parser
    def parse(source_as_string = nil, source_file = nil, &source_as_block)
      control = Control.new
      context = Context.new(control)
      if source_as_string
        # this somewhat weird construct allows to remove a nil source_file
        context.instance_eval(*[source_as_string, source_file].compact)
      else
        context.instance_eval(&source_as_block)
      end
      control
    end
  end
end
