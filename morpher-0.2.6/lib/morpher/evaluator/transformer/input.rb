module Morpher
  class Evaluator
    class Transformer

      # Identity transformer which always returns +input+
      class Input < self
        include Nullary, Transitive

        register :input

        # Call evaluator with input
        #
        # @param [Object] input
        #
        # @return [Object]
        #   always returns input
        #
        # @api private
        #
        def call(input)
          input
        end

        # Return inverse evaluator
        #
        # @return [Evaluator::Transformer]
        #
        # @api private
        #
        def inverse
          self
        end

      end # Input
    end # Transformer
  end # Evaluator
end # Morpher
