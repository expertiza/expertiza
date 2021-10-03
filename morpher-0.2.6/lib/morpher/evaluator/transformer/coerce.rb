module Morpher
  class Evaluator
    class Transformer
      # Abstract namespace class for coercing transformers
      class Coerce < self
        include AbstractType, Nullary::Parameterized, Transitive

        # Parse mixin for cases the parsing possibly results
        # in Argument and Type errors.
        module Parse

          # Call evaluator
          #
          # @param [Object] input
          #
          # @return [Object]
          #
          # @api private
          #
          def call(input)
            invoke(input)
          rescue ArgumentError, TypeError
            raise_transform_error(input)
          end

          # Return evaluation
          #
          # @param [Object] input
          #
          # @return [Evaluation]
          #
          # @api private
          #
          def evaluation(input)
            evaluation_success(input, invoke(input))
          rescue ArgumentError, TypeError
            evaluation_error(input)
          end
        end # Parse

        # Evaluator for parsing an integer
        class ParseInt < self

          include Parse

          register :parse_int

          # Return inverse evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def inverse
            IntToString.new(param)
          end

        private

          # Invoke coercion
          #
          # @return [Integer]
          #
          # @raise [ArgumentError, TypeError]
          #   if coercion does not succeed
          #
          # @api private
          #
          def invoke(input)
            Integer(input, param)
          end

        end # ParseInt

        # Evaluator for dumping fixnums to strings
        class IntToString < self

          register :int_to_string

          # Call evaluator
          #
          # @param [Object] input
          #
          # @return [Hash<Symbol, Object>]
          #
          # @api private
          #
          def call(input)
            input.to_s(param)
          end

          # Return inverse evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def inverse
            ParseInt.new(param)
          end

        end # IntToString

        # Evaluator for parsing an ISO8601 String into a DateTime
        class ParseIso8601DateTime < self

          include Parse

          register :parse_iso8601_date_time

          # Return inverse evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def inverse
            DateTimeToIso8601String.new(param)
          end

        private

          # Invoke coercion
          #
          # @return [DateTime]
          #
          # @raise [ArgumentError, TypeError]
          #   if coercion does not succeed
          #
          # @api private
          #
          def invoke(input)
            DateTime.iso8601(input)
          end
        end # ParseIso8601DateTime

        # Evaluator for dumping a DateTime to an ISO8601 string
        class DateTimeToIso8601String < self
          register :date_time_to_iso8601_string

          # Call evaluator
          #
          # @param [Object] input
          #
          # @return [Object]
          #
          # @api private
          #
          def call(input)
            input.iso8601(param)
          end

          # Return inverse evaluator
          #
          # @return [Evaluator]
          #
          # @api private
          #
          def inverse
            ParseIso8601DateTime.new(param)
          end
        end # DateTimeToIso8601String
      end # Fixnum
    end # Transformer
  end # Evaluator
end # Morpher
