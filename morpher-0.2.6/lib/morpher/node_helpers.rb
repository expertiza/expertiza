module Morpher
  # Node helpers
  module NodeHelpers

    # Build node
    #
    # @param [Symbol] type
    #
    # @return [Parser::AST::Node]
    #
    # @api private
    #
    def s(type, *children)
      AST::Node.new(type, children)
    end
    module_function :s

  end # NodeHelpers
end # Morpher
