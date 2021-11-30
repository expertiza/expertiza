# These rpec will test the validity of the SubmissionRecord model. It tests for
# valid team_id, opeartion, user, assignment id.
describe SubmissionRecord do
  let(:submission_record) { build(:submission_record, id: 1, assignment_id: 1) }
  let(:assignment) { build(:assignment, id: 1) }

  it 'is invalid without a team id' do
    expect(build(:submission_record, team_id: nil)).to_not be_valid
  end
  it 'is invalid without an operation' do
    expect(build(:submission_record, operation: nil)).to_not be_valid
  end
  it 'is invalid without a user' do
    expect(build(:submission_record, user: nil)).to_not be_valid
  end
  it 'is invalid without an assingment id' do
    expect(build(:submission_record, assignment_id: nil)).to_not be_valid
  end

  describe '.copycalibratedsubmissions' do
    it 'copy a calibrated submissions' do
      allow(SubmissionRecord).to receive(:find).with(1).and_return(submission_record)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(SubmissionRecord).to receive(:where).with(assignment_id: 1).and_return([submission_record])
      old_submission_record = SubmissionRecord.find(1)
      SubmissionRecord.copycalibratedsubmissions(assignment, 2)
      allow(SubmissionRecord).to receive(:where).and_call_original
      new_submission_record = SubmissionRecord.find_by(assignment_id: 2)
      expect(new_submission_record.assignment_id).to eq(2)
      expect(new_submission_record.team_id).to eq(old_submission_record.team_id)
      expect(new_submission_record.operation).to eq(old_submission_record.operation)
      expect(new_submission_record.user).to eq(old_submission_record.user)
      expect(new_submission_record.content).to eq(old_submission_record.content)
    end
  end
end
