module Kiba
  class Control
    def sources
      @sources ||= []
    end

    def transforms
      @transforms ||= []
    end
  end

  class Context
    def initialize(control)
      # TODO: forbid access to control from context? use cleanroom?
      @control = control
    end

    def source(&block)
      @control.sources << block
    end

    def transform(&block)
      @control.transforms << block
    end
  end

  def self.parse(&block)
    control = Control.new
    context = Context.new(control)
    context.instance_eval(&block)
    control
  end
end