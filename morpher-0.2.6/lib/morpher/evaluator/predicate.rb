module Morpher
  class Evaluator
    # Abstract namespace class for predicate evaluators
    class Predicate < self
      include Transformer::Intransitive

      # Return inverse evaluator
      #
      # This is a very naive implementation.
      # Subclasses can do a more elaborated choice.
      #
      # @return [Evaluator]
      #
      # @api private
      #
      def inverse
        Negation.new(self)
      end

    end # Predicate
  end # Evaluator
end # Morpher
