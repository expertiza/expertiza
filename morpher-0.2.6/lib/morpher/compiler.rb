module Morpher
  # Abstract compiler base class
  class Compiler
    include AbstractType

    # Call compiler
    #
    # @param [Node] node
    #
    # @return [Object]
    #
    # @api private
    #
    abstract_method :call

  end # Compiler
end # Morpher
