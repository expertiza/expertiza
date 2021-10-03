module Morpher
  class Evaluator
    class Transformer

      # Transformer that always returns the passed +param+
      class Static < self
        include Nullary::Parameterized, Intransitive

        register :static

        # Call evaluator with input
        #
        # @param [Object] _input
        #
        # @return [Object]
        #   alwasys returns the param
        #
        # @api private
        #
        def call(_input)
          param
        end

      end # Static
    end # Transformer
  end # Evaluator
end # Morpher
