module Morpher
  class Compiler
    class Preprocessor
      class Emitter
        # Abstract base class for anima emitters
        class Anima < self
          include AbstractType

          children :model

        private

          # Return domain param
          #
          # @return [Transformer::Domain::Param]
          #
          # @api private
          #
          def param
            Morpher::Evaluator::Transformer::Domain::Param.new(
              model,
              model.anima.attribute_names
            )
          end

          class Dump < self

            register :anima_dump

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
              s(:dump_attribute_hash, param)
            end

          end # Dump

          class Load < self

            register :anima_load

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
              s(:load_attribute_hash, param)
            end

          end # Load
        end # Anima
      end # Emitter
    end # Preprocessor
  end # Compiler
end # Morpher
