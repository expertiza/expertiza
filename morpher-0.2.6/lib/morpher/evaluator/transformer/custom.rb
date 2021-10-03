module Morpher
  class Evaluator
    class Transformer < self
      # Custom transformer with external injected behavior
      class Custom < self
        include Nullary::Parameterized, Transitive
        register :custom

        # Call transformer with input
        #
        # @param [Object]
        #
        # @return [undefinedo]
        #
        # @api private
        #
        def call(input)
          param.first.call(input)
        end

        # Return inverse transformer
        #
        # @return [Evaluator::Transformer]
        #
        # @api private
        #
        def inverse
          self.class.new(param.reverse)
        end

      end # Custom
    end # Transformer
  end # Evaluator
end # Morpher
