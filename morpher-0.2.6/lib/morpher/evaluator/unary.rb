module Morpher
  class Evaluator

    # Mixin for unary evaluators
    module Unary
      CONCORD = Concord::Public.new(:operand)

      PRINTER = lambda do |_|
        name
        indent do
          visit(:operand)
        end
      end

      # Return node
      #
      # @return [AST::Node]
      #
      # @api private
      #
      def node
        s(type, operand.node)
      end

    private

      # Return success evaluation for input
      #
      # @param [Object] input
      #
      # @return [Evalation::Unary]
      #
      # @api private
      #
      def evaluation_success(input, operand_evaluation, output)
        Evaluation::Unary.success(
          evaluator:          self,
          input:              input,
          operand_evaluation: operand_evaluation,
          output:             output
        )
      end

      # Return error evaluation for input
      #
      # @param [Object] input
      #
      # @return [Evalation::Unary]
      #
      # @api private
      #
      def evaluation_error(input, operand_evaluation)
        Evaluation::Unary.error(
          evaluator:          self,
          input:              input,
          operand_evaluation: operand_evaluation
        )
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

    end # Unary

  end # Evaluator
end # Morpher
