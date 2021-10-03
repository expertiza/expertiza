describe Morpher::Evaluator do
  describe '.register' do
    let(:object) do
      Class.new(described_class) do
        public_class_method :register
      end
    end

    subject { object.register(:foo) }

    it 'registers evaluator' do
      expect { subject }.to change { Morpher::Evaluator::REGISTRY[:foo] }.from(nil).to(object)
    end
  end
end
