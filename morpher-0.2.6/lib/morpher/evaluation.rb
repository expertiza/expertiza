module Morpher
  # Abstract namespace class for evaluation states
  class Evaluation
    include AbstractType, Printer::Mixin, Adamantium::Flat, Anima.new(
      :evaluator,
      :input,
      :output,
      :success
    )

    private :success

    # Test if evaluation was successful
    #
    # @return [true]
    #   if evaluation was successful
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    alias_method :success?, :success
    public :success?

    ERROR_DEFAULTS = IceNine.deep_freeze(
      output: Undefined,
      success: false
    )

    SUCCESS_DEFAULTS = IceNine.deep_freeze(
      success: true
    )

    # Return error instance
    #
    # @param [Hash<Symbol, Object>] attributes
    #
    # @return [Evaluation]
    #
    # @api private
    #
    def self.error(attributes)
      new(ERROR_DEFAULTS.merge(attributes))
    end

    # Return successful instance
    #
    # @param [Hash<Symbol, Object>] attributes
    #
    # @return [Evaluation]
    #
    # @api private
    #
    def self.success(attributes)
      new(SUCCESS_DEFAULTS.merge(attributes))
    end

    # Evaluation state for nullary evaluators
    class Nullary < self

      printer do
        name
        indent do
          attributes :input, :output, :success?
          visit :evaluator
        end
      end

    end

    # Evaluation state for nary evaluators
    class Nary < self
      include anima.add(:evaluations)

      printer do
        name
        indent do
          attributes :input, :output, :success?
          attribute_class :evaluator
          visit_many :evaluations
        end
      end

    end # Evaluation

    # Evaluation state for unary evaluators
    class Binary < self
      include anima.add(:left_evaluation, :right_evaluation)

      printer do
        name
        indent do
          attributes :input, :output, :success?
          visit :left_evaluation
          visit :right_evaluation
        end
      end

    end # Unary

    # Evaluation state for unary evaluators
    class Unary < self
      include anima.add(:operand_evaluation)

      printer do
        name
        indent do
          attributes :input, :output, :success?
          visit :operand_evaluation
          visit :evaluator
        end
      end

    end # Unary

  end # Evaluation
end # Morpher
