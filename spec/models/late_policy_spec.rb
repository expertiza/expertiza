require 'penalty_helper'
include PenaltyHelper
describe LatePolicy do
  let(:late_policy) { build(:late_policy) }
  let(:calculated_penalty) { build(:calculated_penalty) }
  let(:participant) { build(:participant) }
  let(:assignment_due_date) { build(:assignment_due_date) }
  let(:meta_review_response_map) { build(:meta_review_response_map) }
  let(:review_response_map) { build(:review_response_map) }
  let (:response) { build(:response) }

  describe 'validations' do
    it 'validates presence of policy_name' do
      late_policy.policy_name = ''
      expect(late_policy).not_to be_valid
    end
    it 'validates presence of instructor_id' do
      late_policy.instructor_id = ''
      expect(late_policy).not_to be_valid
    end
    it 'validates presence of max_penalty' do
      late_policy.max_penalty = ''
      expect(late_policy).not_to be_valid
    end
    it 'validates presence of penalty_per_unit' do
      late_policy.penalty_per_unit = ''
      expect(late_policy).not_to be_valid
    end
    it 'validates presence of penalty_unit' do
      late_policy.penalty_unit = ''
      expect(late_policy).not_to be_valid
    end
    it 'validates max_penalty is > 0 and < 100' do
      late_policy.max_penalty = -10
      expect(late_policy).not_to be_valid
      late_policy.max_penalty = 10
      expect(late_policy).to be_valid
      late_policy.max_penalty = 110
      expect(late_policy).not_to be_valid
    end
    it 'validates max_penalty is numerical' do
      late_policy.max_penalty = 'word'
      expect(late_policy).not_to be_valid
    end
    it 'validates penalty_per_unit is greater_than 0' do
      late_policy.penalty_per_unit = -10
      expect(late_policy).not_to be_valid
      late_policy.penalty_per_unit = 10
      expect(late_policy).to be_valid
    end
    it 'validates penalty_per_unit is numerical' do
      late_policy.penalty_per_unit = 'word'
      expect(late_policy).not_to be_valid
    end
    it 'validates policy_name has 2+ characters and is alphanumeric' do
      late_policy.policy_name = 'a'
      expect(late_policy).not_to be_valid
      late_policy.policy_name = 'a name'
      expect(late_policy).to be_valid
    end
  end

  # testing positive scenario where same policy name is found for an instructor.
  describe '#check_policy_same_name' do
    it 'returns true when policy with same name already exists' do
      allow(LatePolicy).to receive(:where).with(any_args).and_return(Array(late_policy))
      expect(LatePolicy.check_policy_with_same_name('Dummy Name', 1)).to eq(true)
    end
  end

  # testing negative scenario where same policy name is not found for an instructor.
  describe '#check_policy_same_name' do
    it 'returns false when policy with same name does not exist' do
      allow(LatePolicy).to receive(:where).with(any_args).and_return(Array(late_policy))
      expect(LatePolicy.check_policy_with_same_name('Dummy Name 2', 2)).to eq(false)
    end
  end

  # assignment has calculate_penalty set as false and thus there is no change in Array(calculated_penalty)
  describe '#check_update_calculated_penalty_points' do
    it 'does not update calculated penalty when deadline type id is nil' do
      calculated_penalty.deadline_type_id = nil
      allow(CalculatedPenalty).to receive(:all).and_return(Array(calculated_penalty))
      allow_any_instance_of(PenaltyHelper).to receive(:calculate_penalty).and_return(submission: 1, review: 2, meta_review: 3)
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      @old_penalty = calculated_penalty[:penalty_ponits]
      expect(LatePolicy.update_calculated_penalty_objects(late_policy)).to eq(Array(calculated_penalty))
    end
  end

  # when the deadline_type_id is set as 1, the final penalty points in calculated penalty are same as submission penalty (set here as 1)
  describe '#check_update_calculated_penalty_points' do
    it 'updates calculated penalty by submission penalty when deadline type id is 1' do
      calculated_penalty.deadline_type_id = 1
      allow(CalculatedPenalty).to receive(:all).and_return(Array(calculated_penalty))
      allow_any_instance_of(PenaltyHelper).to receive(:calculate_penalty).and_return(submission: 1, review: 2, meta_review: 3)
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      @old_penalty = calculated_penalty[:penalty_ponits]
      expect(LatePolicy.update_calculated_penalty_objects(late_policy)).to eq(Array(calculated_penalty))
    end
  end

  # when the deadline_type_id is set as 2, the final penalty points in calculated penalty are same as review penalty (set here as 2)
  describe '#check_update_calculated_penalty_points' do
    it 'updates calculated penalty by review penalty when deadline type id is 2' do
      calculated_penalty.deadline_type_id = 2
      allow(CalculatedPenalty).to receive(:all).and_return(Array(calculated_penalty))
      allow_any_instance_of(PenaltyHelper).to receive(:calculate_penalty).and_return(submission: 1, review: 2, meta_review: 3)
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      @old_penalty = calculated_penalty[:penalty_ponits]
      expect(LatePolicy.update_calculated_penalty_objects(late_policy)).to eq(Array(calculated_penalty))
    end
  end

  # when the eadline_type_id 5 is set as 5, the final penalty points in calculated penalty are same as meta_review penalty (set here as 3)
  describe '#check_update_calculated_penalty_points' do
    it 'updates calculated penalty by meta review penalty when deadline type id is 5' do
      calculated_penalty.deadline_type_id = 5
      allow(CalculatedPenalty).to receive(:all).and_return(Array(calculated_penalty))
      allow_any_instance_of(PenaltyHelper).to receive(:calculate_penalty).and_return(submission: 1, review: 2, meta_review: 3)
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      @old_penalty = calculated_penalty[:penalty_ponits]
      expect(LatePolicy.update_calculated_penalty_objects(late_policy)).to eq(Array(calculated_penalty))
    end
  end
end
