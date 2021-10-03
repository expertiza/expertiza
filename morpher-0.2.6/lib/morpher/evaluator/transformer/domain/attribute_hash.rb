module Morpher
  class Evaluator
    class Transformer
      class Domain < self
        # Abstract namespace class for domain objects on attributes hash
        class AttributeHash < self
          include AbstractType

          # Evaluator for dumping domain objects via attributes hash
          class Dump < self
            include Domain::Dump

            register :dump_attribute_hash

            # Call evaluator
            #
            # @param [Object] input
            #
            # @return [Hash<Symbol, Object>]
            #
            # @api private
            #
            def call(input)
              input.to_h
            end

          end # Dump

          # Evaluator for loading domain objects via attributes hash
          class Load < self
            include Domain::Load

            register :load_attribute_hash

            # Call evaluator
            #
            # @param [Object] input
            #
            # @return [Object]
            #
            # @api private
            #
            def call(input)
              param.model.new(input)
            end

          end # Load
        end # Domain
      end # Anima
    end # Transformer
  end # Evaluator
end # Morpher
