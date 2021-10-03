module Morpher
  class Evaluator
    class Predicate
      # Binary equal evaluator
      class EQL < self
        include Binary

        register :eql

        # Call evaluator
        #
        # @param [Object] input
        #
        # @return [true]
        #   if input is semantically equivalent to expectation
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def call(input)
          left.call(input).eql?(right.call(input))
        end

        # Return evaluation
        #
        # @param [Object] input
        #
        # @return [Evaluation]
        #
        # @api private
        #
        def evaluation(input)
          left_evaluation  = left.evaluation(input)
          right_evaluation = right.evaluation(input)

          Evaluation::Binary.success(
            evaluator: self,
            input: input,
            output: left_evaluation.output.eql?(right_evaluation.output),
            left_evaluation: left_evaluation,
            right_evaluation: right_evaluation
          )
        end

      end # EQL
    end # Predicate
  end # Evaluator
end # Morpher
