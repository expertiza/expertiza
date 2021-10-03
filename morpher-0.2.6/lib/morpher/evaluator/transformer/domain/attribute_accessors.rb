module Morpher
  class Evaluator
    class Transformer
      class Domain
        # Abstract namespace class for domain objects via attribute accessors
        class AttributeAccessors < self
          include AbstractType

          # Evaluator for dumping domain objects via instance variables
          class Dump < self
            include Domain::Dump

            register :dump_attribute_accessors

            # Call evaluator
            #
            # @param [Object] input
            #
            # @return [Hash<Symbol, Object>]
            #
            # @api private
            #
            def call(input)
              dump do |attribute, attributes|
                name = attribute.name
                attributes[name] = input.public_send(name)
              end
            end

          end # Dump

          # Evaluator for loading domain objects via attributes hash
          class Load < self
            include Domain::Load

            register :load_attribute_accessors

            # Call evaluator
            #
            # @param [Object] input
            #
            # @return [Object]
            #
            # @api private
            #
            def call(input)
              load do |attribute, object|
                object.public_send(
                  attribute.writer,
                  input.fetch(attribute.name)
                )
              end
            end

          end # Load
        end # Domain
      end # Anima
    end # Transformer
  end # Evaluator
end # Morpher
