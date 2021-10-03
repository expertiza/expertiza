describe Morpher::Evaluator::Transformer::Block do

  let(:ast) do
    s(:block, body_a, body_b)
  end

  let(:object) do
    Morpher.compile(ast)
  end

  let(:evaluator_a) do
    Morpher.compile(body_a)
  end

  let(:evaluator_b) do
    Morpher.compile(body_b)
  end

  context 'transitive' do

    let(:body_a) do
      s(:guard, s(:primitive, String))
    end

    let(:body_b) do
      s(:guard, s(:primitive, String))
    end

    let(:valid_input)     { 'foo' }
    let(:expected_output) { 'foo' }
    let(:invalid_input)   { :foo  }

    let(:expected_exception) do
      Morpher::Evaluator::Transformer::TransformError.new(object.body.first, invalid_input)
    end

    include_examples 'transitive evaluator'

    context 'with invalid input' do
      specify '#evaluation' do
        evaluation = object.evaluation(invalid_input)
        expect(evaluation.evaluations.length).to eql(1)
      end
    end
  end

  context 'intransitive' do

    let(:valid_input)     { { 'foo' => 'bar' } }
    let(:invalid_input)   { {}                 }
    let(:expected_output) { true               }

    let(:body_a) do
      s(:key_fetch, 'foo')
    end

    let(:body_b) do
      s(:primitive, String)
    end

    let(:expected_exception) do
      Morpher::Evaluator::Transformer::TransformError.new(object.body.first, invalid_input)
    end

    include_examples 'intransitive evaluator'

    context '#evaluation' do
      subject { object.evaluation(valid_input) }

      let(:evaluations) do
        [
          evaluator_a.evaluation(valid_input),
          evaluator_b.evaluation('bar')
        ]
      end

      context 'with valid input' do
        it 'returns evaluation' do
          should eql(
            Morpher::Evaluation::Nary.new(
              input:       valid_input,
              evaluator:   object,
              evaluations: evaluations,
              output:      expected_output,
              success:     true
            )
          )
        end
      end
    end
  end
end
