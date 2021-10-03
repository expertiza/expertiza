describe Morpher::Evaluator::Predicate::Tautology do
  let(:object)          { described_class.new }
  let(:valid_input)     { double('Input')     }
  let(:expected_output) { true                }

  include_examples 'transforming evaluator on valid input'
end
