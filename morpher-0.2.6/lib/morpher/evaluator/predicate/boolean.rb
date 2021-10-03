module Morpher
  class Evaluator
    class Predicate
      # Evaluator for nary boolean predicates
      class Boolean < self
        include Nary

        # Call evaluator with input
        #
        # @param [Object] input
        #
        # @return [Boolean]
        #
        # @api private
        #
        def call(input)
          body .public_send(
            self.class::ENUMERABLE_METHOD
          ) { |evaluator| evaluator.call(input) }
        end

        # Return evaluation for input
        #
        # @param [Object] input
        #
        # @return [Evaluation::Nary]
        #
        # @api private
        #
        def evaluation(input)
          klass = self.class

          evaluations = body.each_with_object([]) do |evaluator, aggregate|
            evaluation = evaluator.evaluation(input)
            aggregate << evaluation
            next if evaluation.output.equal?(klass::OUTPUT_EXPECTATION)
            return send(klass::ERROR_METHOD, input, aggregate)
          end

          send(klass::SUCCESS_METHOD, input, evaluations)
        end

        # Evaluator for nary and predicates
        class And < self
          register :and

          ENUMERABLE_METHOD  = :all?
          OUTPUT_EXPECTATION = true
          ERROR_METHOD       = :evaluation_negative
          SUCCESS_METHOD     = :evaluation_positive
        end # And

        # Evaluator for nary or predicates
        class Or < self
          register :or

          ENUMERABLE_METHOD  = :any?
          OUTPUT_EXPECTATION = false
          ERROR_METHOD       = :evaluation_positive
          SUCCESS_METHOD     = :evaluation_negative
        end # Or

        # Evaluator for nary xor predicates
        class Xor < self
          register :xor

          ENUMERABLE_METHOD  = :one?
          OUTPUT_EXPECTATION = false
          ERROR_METHOD       = :evaluation_positive
          SUCCESS_METHOD     = :evaluation_negative
        end # Xor

      end # Boolean
    end # Predicate
  end # Evaluator
end # Morpher
