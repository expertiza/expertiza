describe Morpher::Evaluator::Predicate::Boolean::Or do
  let(:object) { described_class.new([body_a, body_b]) }

  let(:body_a) { Morpher.compile(s(:primitive, String)) }
  let(:body_b) { Morpher.compile(s(:primitive, Symbol)) }

  let(:negative_input) { Object.new }
  let(:positive_input) { ''         }

  include_examples 'predicate evaluator'

  context '#evalaution' do

    context 'on positive input' do
      subject { object.evaluation(positive_input) }

      its(:evaluations) { should eql([body_a.evaluation(positive_input)]) }
    end

    context 'on negative input' do
      subject { object.evaluation(negative_input) }

      its(:evaluations) { should eql(object.body.map { |node| node.evaluation(negative_input) }) }
    end
  end
end
