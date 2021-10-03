module Morpher
  class Evaluator
    class Transformer
      class Domain < self

        # Domain specific transformer parameter
        class Param
          include Adamantium, Concord::Public.new(:model, :attribute_names)

          # Return attributes
          #
          # @return [Enumerable<Attribute>]
          #
          # @api private
          #
          def attributes
            attribute_names.map(&Attribute.method(:new))
          end
          memoize :attributes

          # Attribute on a domain transformer param
          class Attribute
            include Adamantium, Concord::Public.new(:name)

            # Return instance variable name
            #
            # @return [Symbol]
            #
            # @api private
            #
            def ivar_name
              :"@#{name}"
            end
            memoize :ivar_name

            # Return writer name
            #
            # @return [Symbol]
            #
            # @api private
            #
            def writer
              :"#{name}="
            end
            memoize :writer

          end # Attribute

        end # Param

      end # Domain
    end # Transformer
  end # Evaluator
end # Morpher
