module Morpher
  class Evaluator

    # Mixin for nary evaluators
    module Nary
      CONCORD = Concord::Public.new(:body)

      PRINTER = lambda do |_|
        name
        indent do
          visit_many(:body)
        end
      end

      # Return AST
      #
      # @return [AST::Node]
      #
      # @api private
      #
      def node
        s(type, *body.map(&:node))
      end

    private

      # Return positive evaluation
      #
      # @param [Object] input
      # @param [Array<Evaluation>] evaluations
      #
      # @return [Evaluation]
      #
      # @api private
      #
      def evaluation_positive(input, evaluations)
        Evaluation::Nary.success(
          evaluator:   self,
          input:       input,
          output:      true,
          evaluations: evaluations
        )
      end

      # Return negative evaluation
      #
      # @param [Object] input
      # @param [Array<Evaluation>] evaluations
      #
      # @return [Evaluation]
      #
      # @api private
      #
      def evaluation_negative(input, evaluations)
        Evaluation::Nary.success(
          evaluator:   self,
          input:       input,
          output:      false,
          evaluations: evaluations
        )
      end

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
          evaluator:   self,
          input:       input,
          evaluations: evaluations
        )
      end

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
