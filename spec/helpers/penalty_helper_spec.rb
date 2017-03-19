require 'rails_helper'

describe "PenaltyHelper" do
  before(:each) do
    @late_policy = create(:late_policy)
    @assignment = create(:assignment, is_penalty_calculated: true, late_policy_id: @late_policy.id)
    @assignment_due_date = create(:assignment_due_date, assignment: @assignment, due_at: DateTime.now.in_time_zone - 1.day)
    @participant = create(:participant, assignment: @assignment)
    @calculated_penalty = create(:calculated_penalty, participant: @participant)
  end
  
  describe "#check_policy_with_same_name" do
    it "should return true when checking an existing policy name" do
      policy_exists = PenlatyHelper.check_policy_with_same_name(@late_policy.name)
      expect(policy_exists).to be true
    end

    it "should return false when checking a non-existant policy name" do
      late_policy_delete = create(:late_policy)
      late_policy_name = late_policy_delete.name
      LatePolicy.destroy(late_policy_delete.id)
      policy_exists = PenlatyHelper.check_policy_with_same_name(late_policy_name)
      expect(policy_exists).to be false
    end
  end
  
  describe "#update_calculated_penalty_objects" do
    it "increase calculated penalty for day late assignment to policy maximum when changing policy time unit from Hour to Minute" do
      @late_policy.update_attributes(:penalty_unit => 'Minute')
      PenaltyHelper.update_calculated_penalty_objects(@late_policy)
      penalty_points = @calculated_penalty.penalty_points
      expect(penalty_points).to be == @late_policy.max_penalty
    end
  end
  
  # Add tests to validate calculate_penalty
end