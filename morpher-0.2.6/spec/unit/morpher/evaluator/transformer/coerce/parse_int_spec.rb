describe Morpher::Evaluator::Transformer::Coerce::ParseInt do
  let(:object) { described_class.new(base) }

  context 'base 16' do
    let(:base) { 16 }

    include_examples 'transitive evaluator'

    let(:valid_input)     { 'ff'   }
    let(:invalid_input)   { '0xfg' }
    let(:expected_output) { 255    }
  end

  context 'base 10' do
    let(:base) { 10 }

    include_examples 'transitive evaluator'

    let(:valid_input)     { '100'   }
    let(:invalid_input)   { '100.0' }
    let(:expected_output) { 100     }
  end
end
