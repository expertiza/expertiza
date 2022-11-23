# These rpec will test the validity of the SubmissionRecord model. It tests for
# valid team_id, operation, user, assignment id.
describe SubmissionRecord do
  let(:team) { build(:team, id: 1, name: 'myTeam', parent_id: 1) }
  let(:team2) { build(:team, id: 2, name: 'myTeam2', parent_id: 2) }
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  let(:assignment2) { build(:assignment, id: 2, name: 'no assgt 2') }
  let(:submission_record) { build(:submission_record, id: 1, assignment_id: 1, team_id: 1) }

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

  describe '#copy_to_team' do
    it 'should copy submission record to a team' do
      new_submission_record = submission_record.copy_to_team(team2)
      puts new_submission_record.team_id
      puts new_submission_record.assignment_id
      expect(new_submission_record.assignment_id).to eq(assignment2.id)
      expect(new_submission_record.team_id).to eq(team2.id)
    end
  end
end
