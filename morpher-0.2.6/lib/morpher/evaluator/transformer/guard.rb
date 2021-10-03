module Morpher
  class Evaluator
    class Transformer

      # Transformer that allows to guard transformation process
      # with a predicate on input
      class Guard < self
        include Unary, Transitive

        register :guard

        # Call evaluator
        #
        # @param [Object] input
        #
        # @return [Object]
        #   if input evaluates true under predicate
        #
        # @raise [TransformError]
        #   otherwise
        #
        # @api private
        #
        def call(input)
          if operand.call(input)
            input
          else
            fail TransformError.new(self, input)
          end
        end

        # Return evaluation
        #
        # @param [Object] input
        #
        # @return [Evaluation::Guard]
        #
        # @api private
        #
        def evaluation(input)
          operand_evaluation = operand.evaluation(input)
          if operand_evaluation.output
            evaluation_success(input, operand_evaluation, input)
          else
            evaluation_error(input, operand_evaluation)
          end
        end

        # Return inverse evaluator
        #
        # @return [self]
        #
        # @api private
        #
        def inverse
          self
        end

      end # Guard
    end # Transformer
  end # Evaluator
end # Morpher
