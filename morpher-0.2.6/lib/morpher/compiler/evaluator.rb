module Morpher
  class Compiler
    # Compiler with evaluators as output
    class Evaluator < self
      include Concord.new(:evaluators, :emitters)

      # Return evaluator tree for node
      #
      # @param [Node] node
      #
      # @return [Evalautor]
      #   on success
      #
      # @raise [Compiler::Error]
      #   on error
      #
      # @api private
      #
      def call(node)
        evaluator = evaluator(node)
        emitter = emitter(evaluator)
        emitter.call(self, evaluator, node)
      end

    private

      # Lookup evaluator for node
      #
      # @param [Node]
      #
      # @return [Class:Evaluator]
      #   if found
      #
      # @raise [Error::UnknownNode]
      #   otherwise
      #
      # @api private
      #
      def evaluator(node)
        type = node.type
        evaluators.fetch(type) do
          fail Error::UnknownNode, type
        end
      end

      # Return emitter for evaluator
      #
      # @param [Class:Evalautor]
      #
      # @return [#call]
      #
      # @api private
      #
      def emitter(evaluator)
        emitters.each do |arity, emitter|
          return emitter if evaluator.ancestors.include?(arity)
        end
        fail Error::UnknownNode, evaluator
      end

    end # Evaluator
  end # Compiler
end # Morpher
