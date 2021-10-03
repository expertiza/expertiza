describe Morpher::Evaluator::Transformer::Input do
  let(:object) { described_class.new }

  let(:valid_input)     { double('Input') }
  let(:expected_output) { valid_input     }

  include_examples 'transforming evaluator on valid input'
  include_examples 'inverse evaluator' do
    let(:expected_inverse) { object }
  end
end
