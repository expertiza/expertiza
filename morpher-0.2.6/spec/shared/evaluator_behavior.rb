shared_examples_for 'inverse evaluator' do
  context '#inverse' do
    subject { object.inverse }

    it 'returns the expected inverse evaluator' do
      should eql(expected_inverse)
    end
  end
end

shared_examples_for 'evaluator' do
  it 'round trips transitive evaluators via #inverse' do
    if object.kind_of?(Morpher::Evaluator::Transformer) && object.transitive?
      object.inverse.inverse.should eql(object)
    end
  end

  it 'round trips evaluators via #node' do
    Morpher.compile(object.node).should eql(object)
  end
end

shared_examples_for 'predicate evaluator' do
  include_examples 'evaluator'

  let(:negative_example?)        { true           }
  let(:expected_output)          { true           }
  let(:valid_input)              { positive_input }
  let(:expected_positive_output) { true           }
  let(:expected_negative_output) { false          }

  context 'with positive input' do
    it 'evaluates to positive output' do
      expect(object.call(positive_input)).to be(expected_positive_output)
    end

    it 'evaluates to inverted positive output' do
      expect(object.inverse.call(positive_input)).to be(!expected_positive_output)
    end

    it 'evaluates to the same output under #evaluation' do
      evaluation = object.evaluation(positive_input)
      expect(evaluation.success?).to be(true)
      expect(evaluation.input).to be(positive_input)
      expect(evaluation.output).to be(expected_positive_output)
    end
  end

  context 'with negative input' do
    it 'evaluates to false' do
      expect(object.call(negative_input)).to be(false)
    end

    it 'evaluates to true on inverse' do
      expect(object.inverse.call(negative_input)).to be(true)
    end

    it 'evaluates to the same output under #evaluation' do
      evaluation = object.evaluation(negative_input)
      expect(evaluation.input).to be(negative_input)
      expect(evaluation.success?).to be(true)
      expect(evaluation.output).to be(false)
    end
  end
end

shared_examples_for 'transitive evaluator' do
  include_examples 'evaluator'

  let(:invalid_input_example?) { true }

  it 'signals transitivity via #transitive?' do
    expect(object.transitive?).to be(true)
  end

  it 'round trips valid inputs via #evaluation' do
    evaluation = object.evaluation(valid_input)
    expect(evaluation.success?).to be(true)
    evaluation = object.inverse.evaluation(evaluation.output)
    expect(evaluation.output).to eql(valid_input)
    expect(evaluation.success?).to be(true)
  end

  it 'round trips valid inputs via #call' do
    forward = object.call(valid_input)
    expect(object.inverse.call(forward)).to eql(valid_input)
  end
end

shared_examples_for 'intransitive evaluator' do
  include_examples 'evaluator'

  let(:invalid_input_example?) { true }

  it 'signals intransitivity via #transitive?' do
    expect(object.transitive?).to be(false)
  end
end

shared_examples_for 'transforming evaluator on valid input' do
  include_examples 'evaluator'

  it 'transforms to expected output via #call' do
    result = object.call(valid_input)
    expect(result).to eql(expected_output)
  end

  it 'transforms to expected output via #evaluation' do
    evaluation = object.evaluation(valid_input)
    expect(evaluation.success?).to eql(true)
    expect(evaluation.output).to eql(expected_output)
  end

  specify '#evaluation' do
    evaluation = object.evaluation(valid_input)
    expect(evaluation.success?).to be(true)
    expect(evaluation.evaluator).to eql(object)
    expect(evaluation.input).to eql(valid_input)
    expect(evaluation.output).to eql(expected_output)
  end

  specify '#call' do
    expect(object.call(valid_input)).to eql(expected_output)
  end
end

shared_examples_for 'transforming evaluator on invalid input' do
  it 'raises error for #call' do
    expect { object.call(invalid_input) }.to raise_error(
      Morpher::Evaluator::Transformer::TransformError
    )
  end

  it 'returns error evaluator for #evaluation' do
    evaluation = object.evaluation(invalid_input)
    expect(evaluation.success?).to eql(false)
    expect(evaluation.output).to be(Morpher::Undefined)
  end

  let(:expected_exception) do
    Morpher::Evaluator::Transformer::TransformError.new(object, invalid_input)
  end

  specify '#call' do
    expect { object.call(invalid_input) }.to raise_error(expected_exception)
  end

  specify '#evaluation' do
    evaluation = object.evaluation(invalid_input)
    expect(evaluation.success?).to be(false)
    expect(evaluation.evaluator).to eql(object)
    expect(evaluation.input).to eql(invalid_input)
    expect(evaluation.output).to eql(Morpher::Undefined)
  end
end
