describe Morpher::Compiler::Preprocessor do
  subject { Morpher::Compiler::Preprocessor::DEFAULT.call(input) }

  shared_examples_for 'a preprocessor' do
    it { should eql(expected) }

    it 'is able to compile output' do
      Morpher.compile(subject)
    end
  end

  context 'with s(:boolean)' do

    it_should_behave_like 'a preprocessor' do
      let(:input)    { s(:boolean) }
      let(:expected) { s(:xor, s(:primitive, TrueClass), s(:primitive, FalseClass)) }
    end

  end

  class Example
    include Anima.new(:foo, :bar)
  end

  let(:param) do
    Morpher::Evaluator::Transformer::Domain::Param.new(Example, %i[foo bar])
  end

  context 'with s(:anima_load)' do

    it_should_behave_like 'a preprocessor' do
      let(:input)    { s(:anima_load, Example) }
      let(:expected) { s(:load_attribute_hash, param) }
    end

  end

  context 'with s(:anima_dump)' do

    it_should_behave_like 'a preprocessor' do
      let(:input)    { s(:anima_dump, Example) }
      let(:expected) { s(:dump_attribute_hash, param) }
    end

  end
end
