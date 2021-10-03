module Morpher
  class Compiler
    class Preprocessor
      class Emitter
        # Preprocessor for boolean primitive
        class Boolean < self
          register :boolean

          children

          NODE = s(:xor, s(:primitive, TrueClass), s(:primitive, FalseClass))

        private

          # Return transformed node
          #
          # @param [Node] node
          #
          # @return [Node]
          #
          # @api private
          #
          def processed_node
            NODE
          end

        end # Boolean
      end # Emitter
    end # Preprocessor
  end # Compiler
end # Morpher
