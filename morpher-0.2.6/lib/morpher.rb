require 'abstract_type'
require 'concord'
require 'anima'
require 'ast'
require 'procto'

# Library namespace module
module Morpher

  Undefined = Module.new.freeze

  # Return evaluator from node
  #
  # @param [Node]
  #
  # @return [Evaluator]
  #
  # @api private
  #
  def self.compile(node)
    node = Compiler::Preprocessor::DEFAULT.call(node)
    Compiler::Evaluator::DEFAULT.call(node)
  end

  # Return evaluate block to produce an AST node
  #
  # @return [AST::Node]
  #
  # @api private
  #
  def self.sexp(&block)
    NodeHelpers.module_eval(&block)
  end

  # Build morpher from yielding sexp blog
  #
  # @return [Evaluator]
  #
  # @api private
  #
  def self.build(&block)
    compile(sexp(&block))
  end

end # Morpher

require 'morpher/node_helpers'
require 'morpher/registry'
require 'morpher/printer'
require 'morpher/printer/mixin'
require 'morpher/evaluator'
require 'morpher/evaluator/nullary'
require 'morpher/evaluator/nullary/parameterized'
require 'morpher/evaluator/unary'
require 'morpher/evaluator/binary'
require 'morpher/evaluator/nary'
require 'morpher/evaluator/transformer'
require 'morpher/evaluator/transformer/block'
require 'morpher/evaluator/transformer/key'
require 'morpher/evaluator/transformer/guard'
require 'morpher/evaluator/transformer/attribute'
require 'morpher/evaluator/transformer/hash_transform'
require 'morpher/evaluator/transformer/map'
require 'morpher/evaluator/transformer/static'
require 'morpher/evaluator/transformer/input'
require 'morpher/evaluator/transformer/merge'
require 'morpher/evaluator/transformer/coerce'
require 'morpher/evaluator/transformer/custom'
require 'morpher/evaluator/transformer/domain'
require 'morpher/evaluator/transformer/domain/param'
require 'morpher/evaluator/transformer/domain/attribute_hash'
require 'morpher/evaluator/transformer/domain/instance_variables'
require 'morpher/evaluator/transformer/domain/attribute_accessors'
require 'morpher/evaluator/predicate'
require 'morpher/evaluator/predicate/eql'
require 'morpher/evaluator/predicate/primitive'
require 'morpher/evaluator/predicate/negation'
require 'morpher/evaluator/predicate/tautology'
require 'morpher/evaluator/predicate/contradiction'
require 'morpher/evaluator/predicate/boolean'
require 'morpher/evaluation'
require 'morpher/evaluation'
require 'morpher/type_lookup'
require 'morpher/compiler'
require 'morpher/compiler/error'
require 'morpher/compiler/emitter'
require 'morpher/compiler/evaluator'
require 'morpher/compiler/evaluator/emitter'
require 'morpher/compiler/preprocessor'
require 'morpher/compiler/preprocessor/emitter'
require 'morpher/compiler/preprocessor/emitter/noop'
require 'morpher/compiler/preprocessor/emitter/key'
require 'morpher/compiler/preprocessor/emitter/param'
require 'morpher/compiler/preprocessor/emitter/boolean'
require 'morpher/compiler/preprocessor/emitter/anima'

module Morpher
  class Compiler

    class Preprocessor
      # Default preprocessor compiler
      DEFAULT = new(Emitter::REGISTRY.freeze)
    end # Preprocessor

    class Evaluator
      # Default evaluator compiler
      DEFAULT = new(Morpher::Evaluator::REGISTRY, Emitter::REGISTRY.freeze)
    end # Evaluator

  end # Compiler
end # Morpher
