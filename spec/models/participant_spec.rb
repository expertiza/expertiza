##
# CSC 517 OODD Fall 2018
# Project 3 OSS
#
# Team Name    : 
# Team Members :
#                Carmen Aiken Bentley (cnaiken)
#                Manjunath Gaonkar (mgaonka)
#                Zhikai Gao (zgao9)
##
describe Participant do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  let(:participant) { build(:participant, user: student) }

  # Carmen
  it '#team' do
    expect(participant.team).to eq('Fill this in by hand')
  end

  # Manjunath
  it '#responses' do
    expect(participant.responses).to eq('Fill this in by hand')
  end

  # Test Completed by instructor.
  describe "#name" do
    it "returns the name of the user" do
      expect(participant.name).to eq "Student"
    end
  end

  # Test Completed by instructor.
  describe "#fullname" do
    it "returns the full name of the user" do
      expect(participant.fullname).to eq "Test, Student"
    end
  end

  # Zhikai
  it '#handle' do
    expect(participant.handle(nil)).to eq('Fill this in by hand')
  end

  # Carmen
  it '#delete' do
    expect(participant.delete(nil)).to eq('Fill this in by hand')
  end

  # Manjunath
  it '#force_delete' do
    expect(participant.force_delete(ResponseMap.where)).to eq('Fill this in by hand')
  end

  #Zhikai
  it '#topic_name' do
    expect(participant.topic_name).to eq('Fill this in by hand')
  end

  # Carmen
  it '#able_to_review' do
    expect(participant.able_to_review).to eq('Fill this in by hand')
  end

  # Manjunath
  it '#email' do
    expect(participant.email('Missing "pw"', 'Missing "home_page"')).to eq('Fill this in by hand')
  end

  # Zhikai
  it '#scores' do
    expect(participant.scores('Missing "questions"')).to eq('Fill this in by hand')
  end

  # Carmen
  it '#get_permissions' do
    expect(Participant.get_permissions('participant')).to eq('Fill this in by hand')
  end

  # Manjunath
  it '#get_authorization' do
    expect(Participant.get_authorization(nil, nil, nil)).to eq('Fill this in by hand')
  end

  # Zhikai
  it '#sort_by_name' do
    expect(Participant.sort_by_name('Missing "participants"')).to eq('Fill this in by hand')
  end
end
