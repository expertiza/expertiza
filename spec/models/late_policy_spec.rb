require 'rails_helper'

describe 'LatePolicy' do
  let (:late_policy) {LatePolicy.new policy_name: "Test", instructor_id: 1234, max_penalty: 20, penalty_per_unit: 2, penalty_unit: "hours"}

  describe "#policy_name" do

    it "returns the name of late policy" do
      expect(late_policy.policy_name).to eq("Test")
    end
  end
end