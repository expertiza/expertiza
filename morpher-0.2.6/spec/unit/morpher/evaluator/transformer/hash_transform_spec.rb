describe Morpher::Evaluator::Transformer::HashTransform do

  let(:ast) do
    s(:hash_transform, body_a)
  end

  let(:object) do
    Morpher.compile(ast)
  end

  let(:evaluator_a) do
    Morpher.compile(body_a)
  end

  context 'intransitive' do

    let(:valid_input)     { { 'foo' => 'bar' } }
    let(:invalid_input)   { {}                 }
    let(:expected_output) { { foo: String    } }

    let(:body_a) do
      s(:key_symbolize, 'foo', s(:attribute, :class))
    end

    let(:expected_exception) do
      Morpher::Evaluator::Transformer::TransformError.new(object.body.first.body.first, invalid_input)
    end

    include_examples 'intransitive evaluator'
  end

  context 'transitive' do
    let(:body_a) do
      s(:key_symbolize, 'foo', s(:guard, s(:primitive, String)))
    end

    let(:valid_input)     { { 'foo' => 'bar' } }
    let(:invalid_input)   { {}                 }
    let(:expected_output) { { foo: 'bar'     } }

    let(:expected_exception) do
      Morpher::Evaluator::Transformer::TransformError.new(object.body.first.body.first, invalid_input)
    end

    include_examples 'transitive evaluator'
  end
end
