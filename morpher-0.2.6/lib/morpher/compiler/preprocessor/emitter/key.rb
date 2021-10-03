module Morpher
  class Compiler
    class Preprocessor
      class Emitter

        # Namespace class for key preprocessors
        class Key < self
          include AbstractType

          # Key symbolization preprocessor
          class Symbolize < self

            register :key_symbolize

            children :key, :operand

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
              s(:key_transform, key.to_s, key.to_sym, operand)
            end

          end # Symbolize

          # Neutral key preprocessor
          class Neutral < self

            register :key

            children :key, :operand

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
              s(:key_transform, key, key, operand)
            end

          end # Neutral

          # Key transformation preprocessor
          class Transform < self
            register :key_transform

            children :from, :to, :operand

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
              s(
                :block,
                s(:key_fetch, from),
                visit(operand),
                s(:key_dump, to)
              )
            end

          end # Transform

        end # Key
      end # Emitter
    end # Preprocessor
  end # Compiler
end # Morpher
