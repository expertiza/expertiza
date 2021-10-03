describe Morpher::Evaluator::Transformer::Domain::AttributeAccessors do

  let(:model) do
    Class.new do
      include Equalizer.new(:foo, :bar)

      attr_accessor :foo, :bar
    end
  end

  let(:param) do
    described_class::Param.new(model, %i[foo bar])
  end

  describe Morpher::Evaluator::Transformer::Domain::AttributeAccessors::Dump do

    let(:object) { described_class::Dump.new(param) }

    let(:expected_output) { { foo: :foo, bar: :bar } }

    let(:valid_input) do
      object = model.allocate
      object.foo = :foo
      object.bar = :bar
      object
    end

    include_examples 'transforming evaluator on valid input'
    include_examples 'transitive evaluator'

  end

  describe Morpher::Evaluator::Transformer::Domain::AttributeAccessors::Load do
    let(:object) { described_class::Load.new(param) }

    let(:valid_input)     { { foo: :foo, bar: :bar } }

    let(:expected_output) do
      object = model.allocate
      object.foo = :foo
      object.bar = :bar
      object
    end

    include_examples 'transforming evaluator on valid input'
    include_examples 'transitive evaluator'
  end
end
