describe Morpher do

  class Foo
    include Anima.new(:attribute_a, :attribute_b)
  end

  class Bar
    include Anima.new(:baz)
  end

  class Baz
    include Anima.new(:value)
  end

  let(:tree_a) do
    Foo.new(
      attribute_a: Baz.new(value: :value_a),
      attribute_b: :value_b
    )
  end

  let(:transformer_ast) do
    s(
      :block,
      s(:guard, s(:primitive, Hash)),
      s(
        :hash_transform,
        s(
          :key_symbolize,
          :attribute_a,
          s(:guard, s(:primitive, String))
        ),
        s(
          :key_symbolize,
          :attribute_b,
          s(:guard, s(:primitive, Fixnum))
        )
      ),
      s(:load_attribute_hash, s(:param, Foo))
    )
  end

  let(:predicate_ast) do
    s(
      :block,
      s(:key_fetch, :attribute_a),
      s(:eql, s(:static, 'foo'), s(:input))
    )
  end

  specify 'allows to execute a transformation' do
    evaluator = Morpher.compile(transformer_ast)

    valid = {
      'attribute_a' => 'a string',
      'attribute_b' => 8015
    }

    expect(evaluator.call(valid)).to eql(
      Foo.new(attribute_a: 'a string', attribute_b: 8015)
    )

    evaluation = evaluator.evaluation(valid)

    expect(evaluation.output).to eql(
      Foo.new(attribute_a: 'a string', attribute_b: 8015)
    )

    invalid = {
      'attribute_a' => 0,
      'attribute_b' => 8015
    }

    expect { evaluator.call(invalid) }.to raise_error(Morpher::Evaluator::Transformer::TransformError)

    evaluation = evaluator.evaluation(invalid)
    expect(evaluation.success?).to be(false)
  end

  specify 'allows to inverse a transformations' do
    evaluator = Morpher.compile(transformer_ast)

    expect(evaluator.inverse.inverse).to eql(evaluator)

    input = Foo.new(attribute_a: 'a string', attribute_b: 8015)

    valid = {
      'attribute_a' => 'a string',
      'attribute_b' => 8015
    }

    expect(evaluator.inverse.call(input)).to eql(valid)
  end

  specify 'allows to merge inputs' do
    evaluator = Morpher.compile(s(:merge, foo: :bar))

    expect(evaluator.call(foo: :bar)).to eql(foo: :bar)
    expect(evaluator.call(bar: :baz)).to eql(foo: :bar, bar: :baz)
  end

  specify 'allows to coerce inputs from string to int and back' do
    evaluator = Morpher.compile(s(:parse_int, 10))

    expect(evaluator.call('42')).to be(42)
    expect(evaluator.inverse.call(42)).to eql('42')

    evaluator = Morpher.compile(s(:int_to_string, 10))

    expect(evaluator.call(42)).to eql('42')
    expect(evaluator.inverse.call('42')).to be(42)
  end

  specify 'allows to coerce inputs from ISO8601 string to DateTime and back' do
    evaluator = Morpher.compile(s(:parse_iso8601_date_time, 0))

    iso8601_string = '2014-08-04T00:00:00+00:00'
    date_time      = DateTime.new(2014, 8, 4)

    expect(evaluator.call(iso8601_string)).to eq(date_time)
    expect(evaluator.inverse.call(date_time)).to eq(iso8601_string)

    evaluator = Morpher.compile(s(:date_time_to_iso8601_string, 0))

    expect(evaluator.call(date_time)).to eq(iso8601_string)
    expect(evaluator.inverse.call(iso8601_string)).to eq(date_time)
  end

  specify 'allows custom transformations' do
    evaluator = Morpher.compile(s(:custom, [->(v) { "changed_#{v}" }]))

    expect(evaluator.call('test')).to eql('changed_test')
  end

  specify 'allows predicates to be run from sexp' do

    valid = { attribute_a: 'foo' }
    invalid = { attribute_a: 'bar' }

    evaluator = Morpher.compile(predicate_ast)

    expect(evaluator.call(valid)).to be(true)
    expect(evaluator.call(invalid)).to be(false)

    evaluation = evaluator.evaluation(valid)

    expect(evaluation.output).to be(true)
    expect(evaluation.input).to be(valid)
    expect(evaluation.description).to eql(strip(<<-TEXT))
      Morpher::Evaluation::Nary
        input: {:attribute_a=>"foo"}
        output: true
        success?: true
        evaluator: Morpher::Evaluator::Transformer::Block
        evaluations:
          Morpher::Evaluation::Nullary
            input: {:attribute_a=>"foo"}
            output: "foo"
            success?: true
            evaluator:
              Morpher::Evaluator::Transformer::Key::Fetch
                param: :attribute_a
          Morpher::Evaluation::Binary
            input: "foo"
            output: true
            success?: true
            left_evaluation:
              Morpher::Evaluation::Nullary
                input: "foo"
                output: "foo"
                success?: true
                evaluator:
                  Morpher::Evaluator::Transformer::Static
                    param: "foo"
            right_evaluation:
              Morpher::Evaluation::Nullary
                input: "foo"
                output: "foo"
                success?: true
                evaluator:
                  Morpher::Evaluator::Transformer::Input
    TEXT
  end
end
