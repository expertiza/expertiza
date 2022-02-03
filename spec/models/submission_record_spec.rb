# These rpec will test the validity of the SubmissionRecord model. It tests for
# valid team_id, operation, user, assignment id.
describe SubmissionRecord do
  it 'is invalid without a team id' do
    expect(build(:submission_record, team_id: nil)).to_not be_valid
  end
  it 'is invalid without an operation' do
    expect(build(:submission_record, operation: nil)).to_not be_valid
  end
  it 'is invalid without a user' do
    expect(build(:submission_record, user: nil)).to_not be_valid
  end
  it 'is invalid without an assignment id' do
    expect(build(:submission_record, assignment_id: nil)).to_not be_valid
  end
end
