module Kiba
  def self.parse(source_as_string = nil, &source_as_block)
    control = Control.new
    context = Context.new(control)
    if source_as_string 
      context.instance_eval(source_as_string)
    else
      context.instance_eval(&source_as_block)
    end
    control
  end
end