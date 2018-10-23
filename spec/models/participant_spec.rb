##
# CSC 517 OODD Fall 2018
# Project 3 OSS
#
# Team Name :
# Team Members :
# Carmen Aiken Bentley (cnaiken)
# Manjunath Gaonkar (mgaonka)
# Zhikai Gao (zgao9)
##
describe Participant do
###
# Please do not share this file with other teams.
# Use factories to `build` necessary objects.
# Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
# RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
# RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
###
# let() creates a variable to access in testing.
let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
let(:student2) { build(:student, name: "A", fullname: "A, A") }
let(:student3) { build(:student, name: "B", fullname: "B, B") }

let(:participant) { build(:participant, user: student) }
let(:participant2) { build(:participant, user: student2) }
let(:participant3) { build(:participant, can_review: false, user: student3) }
let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
#create user 
let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
let(:team) { build(:assignment_team, id: 1, name: 'myTeam', users: [user]) }
let(:team_user) { build(:team_user, id: 1, user: user) }
#create review response
let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
 
#create question
let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }

#before(:each) do
#    allow(participant).to receive(:team) { [team] }
#  end

# can_submit true
# can_review true
# assignment { Assignment.first || association(:assignment) }
# association :user, factory: :student
# submitted_at nil
# permission_granted nil
# penalty_accumulated 0
# grade nil
# type "AssignmentParticipant"
# handle "handle"
# time_stamp nil
# digital_signature nil
# duty nil
# can_take_quiz true
# Carmen Bentley--->Manjunath
describe '#team' do
it 'returns the team of the participant' do
	
allow(participant).to receive(:team).and_return(team.name)
expect(participant.team).to eq('myTeam')
end
end
# Manjunath
it '#responses' do
allow(participant).to receive(:responses).and_return(response)
expect(participant.responses).to eq(response)
end
# Test Completed by instructor.
describe "#name" do
it "returns the name of the user" do
expect(participant.name).to eq "Student"
end
end
## Test Completed by instructor.
describe "#fullname" do
it "returns the full name of the user" do
expect(participant.fullname).to eq "Test, Student"
end
end

describe '#handle' do
it 'returns the handle of the participant' do
expect(participant.handle(nil)).to eq('handle')
end
end
# Carmen
#it '#delete' do
# expect(participant.delete(nil)).to eq('Fill this in by hand')
#end
# Manjunath
#it '#force_delete' do
# expect(participant.force_delete(ResponseMap.where)).to eq('Fill this in by hand')
#end
#Zhikai
#it '#topic_name' do
# expect(participant.topic_name).to eq('Fill this in by hand')
#end
# Carmen-->Manjunath
it '#able_to_review when can_review is true' do
allow(participant).to receive(:able_to_review).and_return(participant2.can_review)
expect(participant.able_to_review).to eq(true)
end
it '#able_to_review when can_review is true' do
allow(participant).to receive(:able_to_review).and_return(participant3.can_review)
expect(participant.able_to_review).to eq(false)
end
# Manjunath
#it '#email' do
# expect(participant.email('Missing "pw"', 'Missing "home_page"')).to eq('Fill this in by hand')
#end
# Zhikai--->Manjunath
it '#scores' do
 
question = double('ScoredQuestion', weight: 2)
allow(Question).to receive(:find).with(1).and_return(question)
allow(question).to receive(:is_a?).with(ScoredQuestion).and_return(true)
#expect(response.total_score).to eq(2)
allow(participant).to receive(:scores).and_return(response.total_score)
expect(participant.scores(question)).to eq(response.total_score)
end
# Carmen
describe '#get_permissions' do
it 'returns the permissions of participant' do
expect(Participant.get_permissions('participant')).to contain_exactly( [:can_submit, true], [:can_review, true], [:can_take_quiz, true] )
end
it 'returns the permissions of reader' do
expect(Participant.get_permissions('reader')).to contain_exactly( [:can_submit, false], [:can_review, true], [:can_take_quiz, true] )
end
it 'returns the permissions of reviewer' do
expect(Participant.get_permissions('reviewer')).to contain_exactly( [:can_submit, false], [:can_review, true], [:can_take_quiz, false] )
end
it 'returns the permissions of submitter' do
expect(Participant.get_permissions('submitter')).to contain_exactly( [:can_submit, true], [:can_review, false], [:can_take_quiz, false] )
end
end
# Manjunath --> Carmen
describe '#get_authorization' do
it 'returns participant when no arguments are pasted' do
expect(Participant.get_authorization(nil, nil, nil)).to eq('participant')
end
it 'returns reader when no arguments are pasted' do
expect(Participant.get_authorization(false, true, true)).to eq('reader')
end
it 'returns submitter when no arguments are pasted' do
expect(Participant.get_authorization(true, false, false)).to eq('submitter')
end
it 'returns reviewer when no arguments are pasted' do
expect(Participant.get_authorization(false, true, false)).to eq('reviewer')
end
end
# Zhikai
it '#sort_by_name' do
#send_part=[participant,participant2]
#rec=[ participant2,participant]
#allow(participant).to receive(:sort_by_name).and_return(rec)
#expect(Participant.sort_by_name( send_part)).to eq(rec)
end
end