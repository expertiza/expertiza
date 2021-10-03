describe Morpher::Evaluator::Predicate::Contradiction do
  let(:object)          { described_class.new }
  let(:valid_input)     { double('Input')     }
  let(:expected_output) { false               }

  include_examples 'transforming evaluator on valid input'
end
