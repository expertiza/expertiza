module Morpher
  class Evaluator
    class Transformer
      # Transformer to merge input into defaults
      class Merge < self
        include Intransitive, Nullary::Parameterized

        register :merge

        # Call evaluator for input
        #
        # @param [Object] input
        #
        # @return [Object] output
        #
        # @api private
        #
        def call(input)
          param.merge(input)
        end

      end # Merge
    end # Transformer
  end # Evaluator
end # Morpher
