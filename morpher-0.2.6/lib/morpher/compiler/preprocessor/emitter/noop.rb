module Morpher
  class Compiler
    class Preprocessor
      class Emitter

        # Noop emitter just descending into children
        class Noop < self

        private

          # Return output
          #
          # @return [Node]
          #
          # @api private
          #
          def processed_node
            mapped_children = node.children.map do |child|
              if child.kind_of?(node.class)
                visit(child)
              else
                child
              end
            end
            s(node.type, *mapped_children)
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
          end

        end # Noop
      end # Emitter
    end # Preprocessor
  end # Compiler
end # Morpher
