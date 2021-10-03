module Morpher
  class Evaluator
    class Predicate
      # Abstract namespace class for predicate evaluators on primitives
      class Primitive < self
        include Nullary::Parameterized

        # Evaluator for exact primitive match
        class Exact < self

          register :primitive

          # Call evaluator
          #
          # @param [Object] object
          #
          # @return [true]
          #   if object's type is #equal?
          #
          # @api private
          #
          def call(object)
            object.class.equal?(param)
          end

        end # Exact

        # Evaluator for permissive primtivie match
        class Permissive < self
          register :is_a

          # Call evaluator
          #
          # @param [Object] object
          #
          # @return [true]
          #   if objects type equals exactly
          #
          # @api private
          #
          def call(object)
            object.kind_of?(param)
          end

        end # Permissive
      end # Primitive
    end # Predicate
  end # Evaluator
end # Morpher
