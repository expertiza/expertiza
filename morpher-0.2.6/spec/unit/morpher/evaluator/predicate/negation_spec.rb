describe Morpher::Evaluator::Predicate::Negation do
  let(:object) { described_class.new(operand) }

  let(:operand) { Morpher.compile(s(:input)) }

  let(:positive_input) { false }
  let(:negative_input) { true  }

  include_examples 'predicate evaluator'
end
