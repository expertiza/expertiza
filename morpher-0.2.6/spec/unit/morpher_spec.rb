describe Morpher do
  let(:object) { described_class }

  describe '.sexp' do
    subject { object.sexp(&block) }

    context 'with no block given' do
      let(:block) { nil }

      it 'raises an exception' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'with block given' do
      let(:block) do
        proc do
          s(:foo)
          s(:bar)
        end
      end

      it 'allows to use sexp dsl and returns last value' do
        should == AST::Node.new(:bar)
      end
    end
  end

  describe '.build' do
    subject { object.build(&block) }

    context 'with no block given' do
      let(:block) { nil }

      it 'raises an exception' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'with block given' do
      let(:block) do
        proc do
          s(:foo)
          s(:true)
        end
      end

      it 'allows to use sexp dsl and returns last value compiled' do
        should eql(Morpher.compile(s(:true)))
      end
    end
  end
end
