describe Morpher::Evaluator::Transformer::Static do
  let(:object) { described_class.new(value) }

  let(:value) { double('Value') }

  let(:valid_input)     { double('Input') }
  let(:expected_output) { value           }

  include_examples 'transforming evaluator on valid input'
end
