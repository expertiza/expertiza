require 'rails_helper'

describe OnTheFlyCalc do
  context "cntxt1" do
    let(:dummy_class) do
      Class.new do
        include OnTheFlyCalc
        def self.name
          "DummyClass"
        end
      end
    end

    context "instances" do
      subject { dummy_class.new }

      it { subject.should be_an_instance_of(dummy_class) }
      it { should respond_to(:compute_total_score)}
      it { should respond_to(:compute_avg_and_ranges_hash)}
      it { should respond_to(:compute_reviews_hash)}
      it { should respond_to(:scores)}
      it { should be_a(OnTheFlyCalc) }
    end

    context "classes" do
      subject { dummy_class }
      it { should be_an_instance_of(Class) }
      it { defined?(DummyClass).should be_nil }
    end
  end

  context "cntxt2" do
    it "should not be possible to access let methods from another context" do
      defined?(dummy_class).should be_nil
    end
  end

  it "should not be possible to access let methods from a child context" do
    defined?(dummy_class).should be_nil
  end
end

