module Morpher
  # Mixin for to provide a node registry
  module Registry

    # Hook called when module is included
    #
    # @param [Module, Class] descendant
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.included(descendant)
      descendant.const_set(:REGISTRY, {})
      descendant.class_eval do
        extend ClassMethods
      end
    end

    # Return node type
    #
    # @return [Symbol]
    #
    # @api private
    #
    def type
      self.class::TYPE
    end

    # Methods to get mixed in at singleton level
    module ClassMethods

      # Register evaluator under name
      #
      # TODO: Disallow duplicate registration under same name
      #
      # @param [Symbol] name
      #
      # @return [undefined]
      #
      # @api private
      #
      def register(name)
        const_set(:TYPE, name)
        self::REGISTRY[name] = self
      end

    end # ClassMethods

  end # Registry
end # Morpher
