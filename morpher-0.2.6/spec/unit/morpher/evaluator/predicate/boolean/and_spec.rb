describe Morpher::Evaluator::Predicate::Boolean::And do
  let(:object) { described_class.new([body_a, body_b]) }

  let(:body_a) { Morpher.compile(s(:primitive, String))                          }
  let(:body_b) { Morpher.compile(s(:eql, s(:attribute, :length), s(:static, 1))) }

  let(:negative_input) { ''   }
  let(:positive_input) { 'a'  }

  include_examples 'predicate evaluator'
end
