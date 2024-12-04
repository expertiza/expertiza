require 'penalty_helper'
require 'active_support/all'
include PenaltyHelper
describe LatePolicy do
  let(:late_policy) { build(:late_policy) }
  let(:calculated_penalty) { build(:calculated_penalty) }
  let(:participant) { build(:participant) }
  let(:assignment_due_date) { build(:assignment_due_date) }
  let(:meta_review_response_map) { build(:meta_review_response_map) }
  let(:review_response_map) { build(:review_response_map) }
  let (:response) { build(:response) }
  let(:due_date) { build(:due_date) }
  let(:penalty_per_unit) { 10 }  # Example penalty per unit
  let(:max_penalty) { 100 }      # Example max penalty
  let(:penalty_unit) { 'Hour' }  # Example unit for penalty calculation

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

  describe '#calculate_penalty' do
  it 'returns the max penalty when calculated penalty exceeds max_penalty' do
    submission_time = Time.now + 10.days
    due_date = Time.now
    late_policy = LatePolicy.new(penalty_unit: 'Day', penalty_per_unit: 20, max_penalty: 50)

    # Time difference is 10 days, calculated penalty would be 10 * 20 = 200
    # But since the max penalty is 50, it should return 50
    expect(late_policy.calculate_penalty(submission_time, due_date)).to eq(50)
  end
end

  describe '#calculate_penalty' do
  it 'returns 0 penalty if submission is on time' do
    submission_time = Time.now
    due_date = submission_time + 1.hour
    late_policy = LatePolicy.new(penalty_unit: 'Hour', penalty_per_unit: 10, max_penalty: 100)
    
    # Expecting the penalty to be 0 if the submission is on time (due date + 1 hour)
    expect(late_policy.calculate_penalty(submission_time, due_date)).to eq(0)
  end
end

describe '#calculate_penalty' do
it 'calculates penalty in days if submission is late' do
  due_date = Time.now
  submission_time = Time.now + 2.days
  
  late_policy = LatePolicy.new(penalty_unit: 'Day', penalty_per_unit: 15, max_penalty: 100)

  # Time difference is 2 days, so penalty should be 2 * 15 = 30
  expect(late_policy.calculate_penalty(submission_time, due_date)).to eq(30)
end
end

describe '#calculate_penalty' do
  it 'raises an error if the penalty unit is invalid' do
    submission_time = Time.now + 1.hour
    due_date = Time.now
    late_policy = LatePolicy.new(penalty_unit: 'InvalidUnit', penalty_per_unit: 10, max_penalty: 100)

    # Expecting an error due to invalid penalty unit
    expect { late_policy.calculate_penalty(submission_time, due_date) }.to raise_error('Invalid. Penalty unit must be Minute, Hour or Day')
  end
end

describe '#calculate_penalty' do
    let(:late_policy) { LatePolicy.new(penalty_unit: 'Day', penalty_per_unit: 20, max_penalty: 50) }
    let(:due_date) { Time.now }

    before do
      # Stub the due_date object with the desired behavior
      allow(DueDate).to receive(:find_by).and_return(double('DueDate', due_at: due_date))
    end

    it 'returns the max penalty when calculated penalty exceeds max_penalty' do
      submission_time = Time.now + 10.days

      # Time difference is 10 days, calculated penalty would be 10 * 20 = 200
      # But since the max penalty is 50, it should return 50
      expect(late_policy.calculate_penalty(submission_time, due_date)).to eq(50)
    end
  end

  describe '#calculate_penalty' do
    let(:late_policy) { LatePolicy.new(penalty_unit: 'Hour', penalty_per_unit: 10, max_penalty: 100) }
    let(:due_date) { Time.now + 1.hour }

    before do
      # Stub the due_date object with the desired behavior
      allow(DueDate).to receive(:find_by).and_return(double('DueDate', due_at: due_date))
    end

    it 'returns 0 penalty if submission is on time' do
      submission_time = Time.now

      # Expecting the penalty to be 0 if the submission is on time (due date + 1 hour)
      expect(late_policy.calculate_penalty(submission_time, due_date)).to eq(0)
    end
  end

  describe '#calculate_penalty' do
    let(:late_policy) { LatePolicy.new(penalty_unit: 'Day', penalty_per_unit: 15, max_penalty: 100) }
    let(:due_date) { Time.now }

    before do
      # Stub the due_date object with the desired behavior
      allow(DueDate).to receive(:find_by).and_return(double('DueDate', due_at: due_date))
    end

    it 'calculates penalty in days if submission is late' do
      submission_time = Time.now + 2.days

      # Time difference is 2 days, so penalty should be 2 * 15 = 30
      expect(late_policy.calculate_penalty(submission_time, due_date)).to eq(30)
    end
  end

  describe '#calculate_penalty' do
    let(:late_policy) { LatePolicy.new(penalty_unit: 'InvalidUnit', penalty_per_unit: 10, max_penalty: 100) }
    let(:due_date) { Time.now }

    before do
      # Stub the due_date object with the desired behavior
      allow(DueDate).to receive(:find_by).and_return(double('DueDate', due_at: due_date))
    end

    it 'raises an error if the penalty unit is invalid' do
      submission_time = Time.now + 1.hour

      # Expecting an error due to invalid penalty unit
      expect { late_policy.calculate_penalty(submission_time, due_date) }.to raise_error('Invalid. Penalty unit must be Minute, Hour or Day')
    end
  end


end
