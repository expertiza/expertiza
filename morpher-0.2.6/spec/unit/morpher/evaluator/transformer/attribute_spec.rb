describe Morpher::Evaluator::Transformer::Attribute do
  let(:object) { described_class.new(:length) }

  include_examples 'transforming evaluator on valid input'
  include_examples 'intransitive evaluator'

  let(:valid_input)     { 'foo' }
  let(:expected_output) { 3     }
end
