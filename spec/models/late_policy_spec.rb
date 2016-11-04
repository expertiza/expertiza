require 'rails_helper'

describe 'LatePolicy' do
  let (:late_policy) {LatePolicy.new policy_name: "Test", instructor_id: 1234, max_penalty: 20, penalty_per_unit: 2, penalty_unit: "hours"}

  describe "#policy_name" do
    it "returns the name of late policy" do
      expect(late_policy.policy_name).to eq("Test")
    end
    it "validates that the policy_name is not blank" do
      late_policy.policy_name = ' '
      expect(late_policy).not_to be_valid
    end
  end
  
  describe "#instructor_id" do
    it "returns the instructor id" do
    expect(late_policy.instructor_id).to eq(1234)
    end
  end

  describe "#max_penalty" do
    it "returns the maximum penalty value" do
      expect(late_policy.max_penalty).to eq(20)
    end
    it "validate max penalty is a number" do
      expect(late_policy.max_penalty).to eq(20)
      late_policy.max_penalty = 'a'
      expect(late_policy).not_to be_valid
    end
    it "should be greater than 0" do
      expect(late_policy.max_penalty).to eq(20)
      late_policy.max_penalty = -20
      expect(late_policy).not_to be_valid
      late_policy.max_penalty = 20
    end
    it "should be less than 0" do
      expect(late_policy.max_penalty).to eq(20)
      late_policy.max_penalty = 51
      expect(late_policy).not_to be_valid
      late_policy.max_penalty = 20
    end
  end

  describe "#penalty_per_unit" do
    it "returns the penalty per unit value" do
      expect(late_policy.penalty_per_unit).to eq(2)
    end
    it "validate penalty per unit is a number" do
      expect(late_policy.penalty_per_unit).to eq(2)
      late_policy.penalty_per_unit = 'a'
      expect(late_policy).not_to be_valid
    end
    it "should be greater than 0" do
      expect(late_policy.penalty_per_unit).to eq(2)
      late_policy.penalty_per_unit = -2
      expect(late_policy).not_to be_valid
      late_policy.penalty_per_unit = 2
    end
  end

  describe "#penalty_unit" do
    it "returns the penalty unit value" do
      expect(late_policy.penalty_unit).to eq("hours")
    end
    it "validates that the penalty_unit is not blank" do
      late_policy.penalty_unit = ' '
      expect(late_policy).not_to be_valid
    end
  end

end
