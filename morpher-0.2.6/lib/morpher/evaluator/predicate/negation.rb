module Morpher
  class Evaluator
    class Predicate
      # Predicate negation
      class Negation < self
        include Unary

        register :negate

        # Return evaluation for input
        #
        # @param [Object] input
        #
        # @return [Evaluation]
        #
        # @api private
        #
        def evaluation(input)
          operand_output = operand.call(input)
          evaluation_success(input, operand_output, !operand_output)
        end

        # Call evaluator
        #
        # @param [Object] input
        #
        # @return [true]
        #   if input NOT evaluated to true under operand
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def call(input)
          !operand.call(input)
        end

        # Return inverse evaluator
        #
        # @return [Evaluator]
        #
        # @api private
        #
        def inverse
          operand
        end

      end # Negation
    end # Predicate
  end # Evaluator
end # Morpher
