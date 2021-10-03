describe Morpher::Evaluator::Predicate::EQL do
  let(:object) { described_class.new(left, right) }

  let(:left)  { Morpher.compile(s(:static, 1.0)) }
  let(:right) { Morpher.compile(s(:input))       }

  let(:positive_input) { 1.0 }
  let(:negative_input) { 1   }

  include_examples 'predicate evaluator'
end
