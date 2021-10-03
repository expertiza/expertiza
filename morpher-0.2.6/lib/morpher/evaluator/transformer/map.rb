module Morpher
  class Evaluator
    class Transformer

      # Transformer over each element in an enumerable
      class Map < self
        include Unary

        register :map

        # Test if evaluator is transitive
        #
        # @return [true]
        #   if evaluator is transitive
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def transitive?
          operand.transitive?
        end

        # Call evaluator
        #
        # @param [Enumerable#map] input
        #
        # @return [Enumerable]
        #   if input evaluates true under predicate
        #
        # @raise [TransformError]
        #   otherwise
        #
        # @api private
        #
        def call(input)
          input.map(&operand.method(:call))
        end

        # Return evaluation
        #
        # @param [Enumerable#map] input
        #
        # @return [Evaluation]
        #
        # @api private
        #
        # rubocop:disable MethodLength
        #
        def evaluation(input)
          evaluations = input.each_with_object([]) do |item, aggregate|
            evaluation = operand.evaluation(item)
            aggregate << evaluation
            unless evaluation.success?
              return evaluation_error(input, aggregate)
            end
          end

          Evaluation::Nary.success(
            evaluator:   self,
            input:       input,
            output:      evaluations.map(&:output),
            evaluations: evaluations
          )
        end

        # Return inverse evaluator
        #
        # @return [Evaluator::Transformer]
        #
        # @api private
        #
        def inverse
          self.class.new(operand.inverse)
        end

      private

        # Return evaluation error
        #
        # @param [Object] input
        # @param [Array<Evaluation>] evaluations
        #
        # @return [Evaluation]
        #
        # @api private
        #
        def evaluation_error(input, evaluations)
          Evaluation::Nary.error(
            evaluator: self,
            input:     input,
            evaluations: evaluations
          )
        end

      end # Guard
    end # Transformer
  end # Evaluator
end # Morpher
