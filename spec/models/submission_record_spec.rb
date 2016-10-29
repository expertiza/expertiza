require 'rails_helper'

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
  it 'is invalid without an assingment id' do
    expect(build(:submission_record, assignment_id: nil)).to_not be_valid
  end
  it 'is invalid without an operation' do
    expect(build(:submission_record, operation: nil)).to_not be_valid
  end
end
