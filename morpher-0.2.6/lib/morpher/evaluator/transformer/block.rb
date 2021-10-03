module Morpher
  class Evaluator
    class Transformer

      # Evaluator to perform n transformations in a row
      class Block < self
        include Nary

        register :block

        # Test if evaluator is transitive
        #
        # @return [true]
        #   if block is transitive
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def transitive?
          body.all?(&:transitive?)
        end

        # Call transformer
        #
        # @param [Object] input
        #
        # @return [Object]
        #
        # @api private
        #
        def call(input)
          body.reduce(input) do |state, evaluator|
            evaluator.call(state)
          end
        end

        # Return inverse evaluator
        #
        # @return [Evaluator]
        #
        # @api private
        #
        def inverse
          self.class.new(body.reverse.map(&:inverse))
        end

        # Return evaluation for input
        #
        # @param [Object] input
        #
        # @return [Evaluation::Nary]
        #
        # @api private
        #
        # rubocop:disable MethodLength
        #
        def evaluation(input)
          state = input

          evaluations = body.each_with_object([]) do |evaluator, aggregate|
            evaluation = evaluator.evaluation(state)
            aggregate << evaluation
            unless evaluation.success?
              return evaluation_error(input, aggregate)
            end
            state = evaluation.output
          end

          Evaluation::Nary.success(
            evaluator:   self,
            input:       input,
            output:      state,
            evaluations: evaluations
          )
        end
      end # Block
    end # Transformer
  end # Evaluato
end # Morpher
