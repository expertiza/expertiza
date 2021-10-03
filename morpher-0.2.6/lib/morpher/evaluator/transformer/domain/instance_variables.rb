module Morpher
  class Evaluator
    class Transformer
      class Domain < self
        # Abstract namespace class for domain objects via instance variables
        class InstanceVariables < self
          include AbstractType

          # Evaluator for dumping domain objects via instance variables
          class Dump < self
            include Domain::Dump

            register :dump_instance_variables

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
                attributes[attribute.name] =
                  input.instance_variable_get(attribute.ivar_name)
              end
            end

          end # Dump

          # Evaluator for loading domain objects via instance variables
          class Load < self
            include Domain::Load

            register :load_instance_variables

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
                object.instance_variable_set(
                  attribute.ivar_name,
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
