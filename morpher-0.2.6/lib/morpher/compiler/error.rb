module Morpher
  class Compiler

    # Abstract error class for compiler errors
    class Error < RuntimeError
      include AbstractType

      # Error raised when node children have incorrect amount
      class NodeChildren < self
        include Concord.new(:node, :expected_amount)

        # Return exception message
        #
        # @return [String]
        #
        # @api private
        #
        def message
          "Expected #{expected_amount} #{_children} for #{type}, got #{actual_amount}: #{children}"
        end

        private

        # Return inspected type
        #
        # @return [String]
        #
        # @api private
        #
        def type
          node.type.inspect
        end

        # Return actual amount of children
        #
        # @return [String]
        #
        # @api private
        #
        def actual_amount
          children.length
        end

        # Return children
        #
        # @return [Array]
        #
        # @api private
        #
        def children
          node.children
        end

        # Return user firendly children message
        #
        # @return [String]
        #
        # @api private
        #
        def _children
          expected_amount.equal?(1) ? 'child' : 'children'
        end

      end # NodeChildren

      # Error raised on compiling unknown nodes
      class UnknownNode < self
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

      end # UnknownNode

    end # Error
  end # Compiler
end # Morpher
