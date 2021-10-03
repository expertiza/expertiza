module Morpher

  # Abstract namespace class for non tracking evaluators
  class Evaluator
    include Adamantium::Flat,
            Registry,
            AbstractType,
            Printer::Mixin,
            NodeHelpers

    # Call evaluator in non tracking mode
    #
    # @param [Object] input
    #
    # @return [Object]
    #
    # @api private
    #
    abstract_method :call

    # Call evaluator in tracking mode
    #
    # @param [Object] input
    #
    # @return [Evaluation]
    #
    # @api private
    #
    abstract_method :evaluation

    # Return inverse evaluator
    #
    # @return [Evaluator]
    #
    # @api private
    #
    abstract_method :inverse

  end # Evaluator
end # Morpher
