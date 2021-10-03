describe Morpher::Evaluator::Transformer::Map do
  let(:object) { described_class.new(operand) }

  context '#intransitive' do
    let(:operand) { Morpher.compile(s(:attribute, :length)) }

    include_examples 'transforming evaluator on valid input'
    include_examples 'intransitive evaluator'

    let(:valid_input)     { ['foo'] }
    let(:expected_output) { [3]     }
  end

  context '#transitive' do
    let(:operand) { Morpher.compile(s(:guard, s(:primitive, String))) }

    include_examples 'transforming evaluator on valid input'
    include_examples 'transitive evaluator'

    let(:valid_input)     { ['foo'] }
    let(:invalid_input)   { [nil]   }
    let(:expected_output) { ['foo'] }
  end

end
