module Kiba
  # This is a wrapper class that stores either a reference to a class along
  # with initializtion arguments, or it stores a proc.
  #
  # It offers one interface for both cases and only delegates to the wrapped
  # class if it was passed.
  class Transform
    # Stored class to be instantiated later beforer running.
    #
    # @return [Class]
    attr_accessor :klass

    # Arguments to be passed to the stored class.
    #
    # @return [Array]
    attr_accessor :initialization_params

    # Instantiated transform class.
    #
    # @return [Object]
    attr_accessor :klass_instance

    # Stored block to run instead of delegating to a class instance.
    #
    # @return [Proc]
    attr_accessor :block

    # Store references to class or proc.
    def initialize(klass = nil, *initialization_params, &block)
      fail ArgumentError, 'Supply a block or provide a class' if
        !klass && !block

      self.klass                 = klass
      self.initialization_params = initialization_params
      self.block                 = block
    end

    # Instantiate the stored class if it was passed.
    def prepare
      return unless klass # We have a Proc in @block
      self.klass_instance = klass.new(*initialization_params)
    end

    # Delegate to stored class instance or call the proc.
    def process(row)
      if klass_instance
        klass_instance.process(row)
      else
        block.call(row)
      end
    end
  end
end
