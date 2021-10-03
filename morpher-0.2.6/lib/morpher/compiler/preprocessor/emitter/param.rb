module Morpher
  class Compiler
    class Preprocessor
      class Emitter

        # Param domain transformer specific emitter
        class Param < self

          register :param

          children :model

        private

          # Return output
          #
          # @return [Node]
          #
          # @api private
          #
          def processed_node
            param = Morpher::Evaluator::Transformer::Domain::Param.new(
              model,
              remaining_children
            )
            s(:raw, param)
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
            remaining_children.each_with_index do |child, index|
              next if child.kind_of?(Symbol)
              fail Error::ChildType, Symbol, child, index
            end
          end

        end # Noop
      end # Emitter
    end # Preprocessor
  end # Compiler
end # Morpher
