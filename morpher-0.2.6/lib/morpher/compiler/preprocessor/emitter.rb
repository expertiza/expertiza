module Morpher
  class Compiler
    class Preprocessor
      # Abstract preprocessor emitter
      class Emitter < Compiler::Emitter
        include Registry, Concord.new(:preprocessor, :node)

        # Return output
        #
        # @return [AST::Node]
        #
        # @api private
        #
        def output
          validate_node
          processed_node
        end
        memoize :output

      private

        # Visit node
        #
        # @param [Node] node
        #   original untransformed node
        #
        # @return [Node]
        #   transformed node
        #
        # @api private
        #
        def visit(node)
          preprocessor.call(node)
        end

        # Validate node
        #
        # @return [undefined]
        #   if successful
        #
        # @raise [Error]
        #   otherwise
        #
        # @api private
        #
        def validate_node
          assert_children_amount(named_children.length)
        end

      end # Emitter

    end # Preprocessor
  end # Compiler
end # Morpher
