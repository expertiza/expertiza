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

  # Create necessary student participants for testing.
  let(:participant) {
	build(:participant, user: build(:student, name: "Student", fullname: "Test, Student", id: 1 ) ) }
  let(:participant2) { 
	build(:participant, user: build(:student, name: "John", fullname: "Doe, John", id: 2 ) ) }
  let(:participant3) { 
	build(:participant, can_review: false, user: build(:student, name: "King", fullname: "Titan, King", id: 3 ) ) }

##create assignment
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
  
##create team 
  let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
  let(:team) { build(:assignment_team, id: 1, name: 'myTeam', users: [user]) }
  let(:team_user) { build(:team_user, id: 1, user: user) }

##create review response 
  let(:review_response_map) {
	build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:response) {
	build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
 
  #create question
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }


  describe '#team' do
    it 'returns nil for a participant not assigned to a team' do
      expect( participant.team ).to eq( nil )
    end

    it 'returns the team of the participant' do
      allow( participant ).to receive( :team ).and_return( team.name )
      expect( participant.team ).to eq( 'myTeam' )
    end
  end

  describe '#response' do
    it 'Returns the reponses that are associated with this participant' do
      allow( participant ).to receive( :responses ).and_return( response )
      expect( participant.responses ).to eq( response )
    end
  end

  # Test Completed by instructor.
  describe "#name" do
    it "returns the name of the user" do
      expect( participant.name ).to eq "Student"
    end
  end

  # Test Completed by instructor.
  describe "#fullname" do
    it "returns the full name of the user" do
      expect( participant.fullname ).to eq "Test, Student"
    end
  end

  describe '#handle' do
    it 'returns the handle of the participant' do
      expect( participant.handle( nil ) ).to eq( 'handle' )
    end
  end
## Question --> what is returned with force == nil verses force == true
  describe '#delete' do
    it 'deletes a participant if no associations exist and force is nil' do
      expect( participant.delete( nil ) ).to eq( participant )
    end
    it 'deletes a participant if no associations exist and force is true' do
      expect( participant.delete( true ) ).to eq( participant )
    end
#    it 'deletes a participant if associations exist and force is true' do
#      expect( participant.delete( true ) ).to eq( participant )
#    end
#    it 'raises execption when trying to delect participant where associations exists and force is nil' do
#      expect( participant.delete( nil ) ).to raise( "Association exist for this participant." )
#    end
  end
## Question --> Is it necessary to test force_delete if these things are tested via delete?
#  describe '#force_delete' do
#    it 'forces a delete regardless of existing associations' do
#      expect( participant.force_delete( ResponseMap.where ) ).to eq( 'Fill this in by hand' )
#    end
#  end

  describe '#topic_name' do
    it 'returns the topic name associated with the participant topic name is nil' do
      expect( participant.topic_name ).to eq( '<center>&#8212;</center>' )
    end
#    it 'returns the topic name associated with the participant topic name has value' do
#      allow( participant ).to receive( :topic_name ).and_return( 'Topic Name' )
#      expect( participant.topic_name ).to eq( 'Topic Name' )
#    end
  end

  describe '#able_to_review' do
    it '#able_to_review when can_review is true' do
      expect(participant.able_to_review).to eq(true)
    end
  end

  describe '#able_to_review' do
    it '#able_to_review when can_review is false' do
      expect(participant3.able_to_review).to eq(false)
    end
  end

#  describe '#email' do
#    it '#email' do
#      expect(participant.email('Missing "pw"', 'Missing "home_page"')).to eq('Fill this in by hand')
#    end
#  end

#  describe '#score' do
#    it '???' do
#      question = double( 'ScoredQuestion', weight: 2 )
#      allow( Question ).to receive( :find ).with( 1 ).and_return( question )
#      allow( question ).to receive( :is_a? ).with( ScoredQuestion ).and_return( true )
#      expect( response.total_score ).to eq( 2 )
#      allow( participant ).to receive( :scores ).and_return( response.total_score )
#      expect( participant.scores( question ) ).to eq( response.total_score )
#    end 
#  end

  describe '#get_permissions' do
    it 'returns the permissions of participant' do
      expect( Participant.get_permissions( 'participant' ) ).to contain_exactly( [ :can_submit, true ], [ :can_review, true ], [ :can_take_quiz, true ] )
    end
    it 'returns the permissions of reader' do
      expect( Participant.get_permissions( 'reader' ) ).to contain_exactly( [ :can_submit, false ], [ :can_review, true ], [ :can_take_quiz, true ] )
    end
    it 'returns the permissions of reviewer' do
      expect( Participant.get_permissions( 'reviewer' ) ).to contain_exactly( [ :can_submit, false ], [ :can_review, true ], [ :can_take_quiz, false ] )
    end
    it 'returns the permissions of submitter' do
      expect(Participant.get_permissions('submitter')).to contain_exactly( [:can_submit, true], [:can_review, false], [:can_take_quiz, false] )
    end
  end

  describe '#get_authorization' do
    it 'returns participant when no arguments are pasted' do
      expect( Participant.get_authorization( nil, nil, nil ) ).to eq( 'participant' )
    end
    it 'returns reader when no arguments are pasted' do
      expect( Participant.get_authorization( false, true, true ) ).to eq( 'reader' )
    end
    it 'returns submitter when no arguments are pasted' do
      expect( Participant.get_authorization( true, false, false ) ).to eq( 'submitter' )
    end
    it 'returns reviewer when no arguments are pasted' do
      expect( Participant.get_authorization( false, true, false ) ).to eq( 'reviewer' )
    end
  end

  describe '#sort_by_name' do
    it 'returns a sorted list of participants alphabetical by name' do
      unsorted = [ participant, participant2, participant3 ]
      sorted = [ participant2, participant3, participant ]
      expect( Participant.sort_by_name( unsorted ) ).to eq( sorted )
    end
  end
end
