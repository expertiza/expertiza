module Morpher
  class Compiler
    # AST preprocessor
    class Preprocessor < self
      include Concord.new(:emitters)

      # Call preprocessor
      #
      # @param [Node] node
      #   the raw AST node after DSL
      #
      # @return [Node]
      #   the transformed ast node
      #
      # @api private
      #
      def call(node)
        loop do
          emitter = emitters.fetch(node.type, Emitter::Noop)
          node = emitter.call(self, node)
          break if emitter.equal?(Emitter::Noop)
        end

        node
      end

    end # Preprocessor
  end # Compiler
end # Morpher
