module Morpher

  class Evaluator

    # Mixin for binary evaluators
    module Binary
      CONCORD = Concord::Public.new(:left, :right)

      PRINTER = lambda do |_|
        name
        indent do
          visit(:left)
          visit(:right)
        end
      end

      # Return node
      #
      # @return [AST::Node]
      #
      # @api private
      #
      def node
        s(type, left.node, right.node)
      end

    private

      # Hook called when module gets included
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.included(descendant)
        descendant.class_eval do
          include CONCORD
          printer(&PRINTER)
        end
      end
      private_class_method :included

    end # Nary

  end # Evaluator
end # Morpher
