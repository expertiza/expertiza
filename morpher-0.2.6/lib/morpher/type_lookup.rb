module Morpher

  # Type lookup via registry and superclass chaining
  #
  # TODO: Cache results.
  #
  class TypeLookup
    include Adamantium::Flat, Concord.new(:registry)

    # Error raised on compiling unknown nodes
    class TypeNotFoundError < RuntimeError
      include Concord.new(:type)

      # Return exception error message
      #
      # @return [String]
      #
      # @api private
      #
      def message
        "Node type: #{type.inspect} is unknown"
      end

    end # TypeNotFoundError

    # Perform type lookup
    #
    # @param [Object] object
    #
    # @return [Object]
    #   if found
    #
    # @raise [TypeNotFoundError]
    #   otherwise
    #
    # @api private
    #
    def call(object)
      current = target = object.class
      while current != Object
        if registry.key?(current)
          return registry.fetch(current)
        end
        current = current.superclass
      end

      fail TypeNotFoundError, target
    end

  end # TypeLookup
end # Morpher
