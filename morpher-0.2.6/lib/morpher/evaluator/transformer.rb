module Morpher
  class Evaluator
    # Abstract namespace class for transforming evaluators
    class Transformer < self
      include AbstractType

      # Error raised when transformation cannot continue
      class TransformError < RuntimeError
        include Concord.new(:transformer, :input)
      end

      # Test evaluator transformer is transitive
      #
      # A transitive evaluator allows to inverse an operation
      # via its #inverse evaluator.
      #
      # @return [true]
      #   if transformer is transitive
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      abstract_method :transitive?

      # Mixin for evaluators that are transitive by definition
      module Transitive

        # Test if evaluator is transitive
        #
        # @return [false]
        #
        # @api private
        #
        def transitive?
          true
        end

      end # Intransitive

      # Mixin for evaluators that are intransitive by definition
      module Intransitive

        # Test if evaluator is transitive
        #
        # @return [false]
        #
        # @api private
        #
        def transitive?
          false
        end

      end # Intransitive

    private

      # Raise transform error
      #
      # @param [Object] input
      #
      # @raise [TransformError]
      #
      # @return [undefined]
      #
      # @api private
      #
      def raise_transform_error(input)
        fail TransformError.new(self, input)
      end

    end # Transform
  end # Evaluator
end # Morpher
