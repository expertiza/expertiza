describe Morpher::Evaluator::Predicate::Primitive::Exact do
  let(:object) { described_class.new(Morpher::Evaluator) }

  let(:positive_input) { Morpher::Evaluator.allocate }
  let(:negative_input) { Morpher::Evaluator::Predicate.allocate }

  include_examples 'predicate evaluator'
end

describe Morpher::Evaluator::Predicate::Primitive::Permissive do
  let(:object) { described_class.new(Morpher::Evaluator) }

  let(:positive_input) { Morpher::Evaluator::Predicate.allocate }
  let(:negative_input) { '' }

  include_examples 'predicate evaluator'
end
