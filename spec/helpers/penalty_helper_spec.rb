require 'rails_helper'

describe "PenaltyHelper" do
  before(:each) do
    @course_participant = create(:course_participant)
    @instructor = create(:instructor)
    @late_policy = create(:late_policy, instructor_id: @instructor.id)
    @assignment = create(:assignment, is_penalty_calculated: true, late_policy_id: @late_policy.id, instructor: @instructor)
    @assignment_participant = create(:participant, assignment: @assignment)
    @calculated_penalty = create(:calculated_penalty, participant: @assignment_participant)
  end

  
  describe "#check_policy_with_same_name" do
    it "should return true when checking an existing policy name" do
      policy_exists = PenaltyHelper.check_policy_with_same_name(@late_policy.policy_name, @instructor.id)
      expect(policy_exists).to be true
    end

    it "should return false when checking a non-existant policy name" do
      late_policy_delete = create(:late_policy)
      late_policy_name = late_policy_delete.policy_name
      LatePolicy.destroy(late_policy_delete.id)
      policy_exists = PenaltyHelper.check_policy_with_same_name(late_policy_name, @instructor.id)
      expect(policy_exists).to be false
    end
  end
  
  describe "#check_penalty_points_validity" do
    it "should return true if penalty_points_per_unit is greater than the maximum allowed penalty" do
      valid_penalty_points = PenaltyHelper.check_penalty_points_validity(10, 11)
      expect(valid_penalty_points).to be true
    end

    it "should return false if penalty_points_per_unit is less than the maximum allowed penalty" do
      valid_penalty_points = PenaltyHelper.check_penalty_points_validity(10, 9)
      expect(valid_penalty_points).to be false
    end

    it "should return false if penalty_points_per_unit is equal to the maximum allowed penalty" do
      valid_penalty_points = PenaltyHelper.check_penalty_points_validity(10, 10)
      expect(valid_penalty_points).to be false
    end
  end
  
  describe "#calculate_penalty_units" do
    it "should return 1 when passed a 1 minute time difference and a penalty unit of 'Minute'" do
      penalty_unit = 'Minute'
      time_difference = ((DateTime.now.in_time_zone) - (DateTime.now.in_time_zone - 1.minute)) 
      penalty_minutes = PenaltyHelper.calculate_penalty_units(time_difference, penalty_unit)
      expect(penalty_minutes.round).to be == 1
    end
    
    it "should return 1 when passed a 1 hour time difference and a penalty unit of 'Hour'" do
      penalty_unit = 'Hour'
      time_difference = ((DateTime.now.in_time_zone) - (DateTime.now.in_time_zone - 1.hour)) 
      penalty_minutes = PenaltyHelper.calculate_penalty_units(time_difference, penalty_unit)
      expect(penalty_minutes.round).to be == 1
    end
    
    it "should return 1 when passed a 1 day time difference and a penalty unit of 'Day'" do
      penalty_unit = 'Day'
      time_difference = ((DateTime.now.in_time_zone) - (DateTime.now.in_time_zone - 1.day)) 
      penalty_minutes = PenaltyHelper.calculate_penalty_units(time_difference, penalty_unit)
      expect(penalty_minutes.round).to be == 1
    end
  end 

  it "has a valid factory" do
    factory = FactoryGirl.build(:late_policy)
    expect(factory).to be_valid
  end
end