module Kiba
  class Control
    def sources
      @sources ||= []
    end

    def transforms
      @transforms ||= []
    end

    def destinations
      @destinations ||= []
    end
  end

  class Context
    def initialize(control)
      # TODO: forbid access to control from context? use cleanroom?
      @control = control
    end

    def source(klass, *initialization_params)
      @control.sources << {klass: klass, args: initialization_params}
    end

    def transform(&block)
      @control.transforms << block
    end

    def destination(klass, *initialization_params)
      @control.destinations << {klass: klass, args: initialization_params}
    end
  end

  def self.parse(&block)
    control = Control.new
    context = Context.new(control)
    context.instance_eval(&block)
    control
  end

  def self.process(control)
    sources = to_instances(control.sources)
    destinations = to_instances(control.destinations)
    
    sources.each do |source|
      source.each do |row|
        # TODO: catch errors and redirect row to error handler
        # TODO: assert that we have a Hash here?
        control.transforms.each do |transform|
          row = transform.call(row)
          next unless row
        end
        next unless row
        destinations.each do |destination|
          destination.write(row)
        end
      end
    end

    destinations.each(&:close)
  end
  
  def self.to_instances(definitions)
    definitions.map { |d| d[:klass].new(*d[:args]) }
  end
end