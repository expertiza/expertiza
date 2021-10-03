module Morpher
  class Evaluator
    class Transformer
      # Abstract namespace class for transformers from/to domain
      class Domain < self
        include AbstractType, Nullary::Parameterized, Transitive

      private

        # Call block with param attributes
        #
        # @param [Object] aggregate
        #
        # @return [Object]
        #
        # @api private
        #
        def transform(aggregate, &block)
          param.attributes.each_with_object(aggregate, &block)
        end

        # Mixin for domain dumpers
        module Dump

          # Return inverse evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def inverse
            self.class::Load.new(param)
          end

        private

          # Dump object
          #
          # @param [Symbol] left
          # @param [Symbol] right
          #
          # @return [Object]
          #
          # @api private
          #
          def dump(&block)
            transform({}, &block)
          end

        end # Dump

        # Mixin for domain loaders
        module Load
          include AbstractType

          # Return inverse evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def inverse
            self.class::Dump.new(param)
          end

        private

          # Load object
          #
          # @param [Symbol] left
          # @param [Symbol] right
          #
          # @return [Object]
          #
          # @api private
          #
          def load(&block)
            transform(param.model.allocate, &block)
          end

        end # Load

      end # Domain
    end # Transformer
  end # Evaluator
end # Morpher
