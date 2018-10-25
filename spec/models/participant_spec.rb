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
  # Please avoid duplicated code as much as you can by
  # moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples:
  # https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  let(:user) { 
	build( :student, id: 1, name: 'no name', fullname: 'no one') }
  let(:team) {	
	build( :assignment_team, id: 1, name: 'myTeam' ) }
  let(:team_user) { 
	build( :team_user, id: 1, user: user, team: team) }

  let(:topic){ build( :topic ) }

  let(:participant) {
	build(:participant,
	user: build( :student, name: "Jane", fullname: "Doe, Jane", id: 1 ) ) }
  let(:participant2) { 
	build(:participant, 
	user: build( :student, name: "John", fullname: "Doe, John", id: 2 ) ) }
  let(:participant3) { 
	build(:participant, can_review: false, 
	user: build(:student, name: "King", fullname: "Titan, King", id: 3 ) ) }

  let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }

  let( :review_response_map ) {
	build( :review_response_map, assignment: assignment, reviewer: participant, reviewee: team ) }
  let( :response ) {
	build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [ answer ] ) }
  let( :answer ) { 
	Answer.new( answer: 1, comments: 'Answer text', question_id: 1 ) }
 
  let( :question ) { 
	Criterion.new(id: 1, weight: 2, break_before: true ) }
  let( :questionnaire ) { 
	ReviewQuestionnaire.new(id: 1, questions: [ question ], max_question_score: 5) }

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

#  describe '#team' do
#    it 'returns the team of the participant' do
#      allow(TeamsUser).to receive(:find_by).with(user: participant).and_return(team_user)
#      expect( participant.team ).to eq(team_user)
#    end
#  end

  describe '#response' do
    it 'Returns the reponses that are associated with this participant' do
      allow( participant ).to receive( :responses ).and_return( response )
      expect( participant.responses ).to eq( response )
    end
  end

  # Test Completed by instructor.
  describe "#name" do
    it "returns the name of the user" do
      expect( participant.name ).to eq( "Jane" )
    end
  end

  # Test Completed by instructor.
  describe "#fullname" do
    it "returns the full name of the user" do
      expect( participant.fullname ).to eq( "Doe, Jane" )
    end
  end

  describe '#handle' do
    it 'returns the handle of the participant' do
      expect( participant.handle( nil ) ).to eq( "handle" )
    end
  end

  describe '#delete' do
    it 'deletes a participant if no associations exist and force is nil' do
      expect( participant.delete( nil ) ).to eq( participant )
    end
    it 'deletes a participant if no associations exist and force is true' do
      expect( participant.delete( true ) ).to eq( participant )
    end
    it 'deletes a participant if associations exist and force is true' do
      allow( participant ).to receive( :team ).and_return( team )
      expect( participant.delete( true ) ).to eq( participant )
    end
    it 'deletes a participant if associations exist and force is true' do
      allow( participant ).to receive( :team ).and_return( team )
      allow( team ).to receive( :teams_users ).and_return( length: 1 )
      expect( participant.delete( true ) ).to eq( participant )
    end
#    it 'raises execption when trying to delect participant where associations exists and force is nil' do
#      allow( participant ).to receive( :team ).and_return( team )
#      expect( participant.delete( nil ) ).to raise_error.with_message("Associations exist for this participant.")
#    end
  end

#  method --> force_delete is tested via the testing of method --> delete

  describe '#topic_name' do
    it 'returns the topic name associated with the participant topic name is nil' do
      expect( participant.topic_name ).to eq( '<center>&#8212;</center>' )
    end
    it 'returns the topic name associated with the participant topic name has value' do
      allow( participant ).to receive( :topic ).and_return( topic )
      expect( participant.topic_name ).to eq( "Hello world!" )   
    end
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

  describe '#email' do
    it 'sends an email to the participant' do
      expect { participant.email("Missing 'pw'", "Missing 'home_page'") }.to change {
		ActionMailer::Base.deliveries.count }.by(1)
    end
  end

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
      expect( Participant.get_permissions( 'participant' ) ).to contain_exactly(
		[ :can_submit, true ], [ :can_review, true ], [ :can_take_quiz, true ] )
    end
    it 'returns the permissions of reader' do
      expect( Participant.get_permissions( 'reader' ) ).to contain_exactly(
		[ :can_submit, false ], [ :can_review, true ], [ :can_take_quiz, true ] )
    end
    it 'returns the permissions of reviewer' do
      expect( Participant.get_permissions( 'reviewer' ) ).to contain_exactly(
		[ :can_submit, false ], [ :can_review, true ], [ :can_take_quiz, false ] )
    end
    it 'returns the permissions of submitter' do
      expect(Participant.get_permissions('submitter')).to contain_exactly(
		[:can_submit, true], [:can_review, false], [:can_take_quiz, false] )
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
      unsorted = [ participant3, participant, participant2 ]
      sorted = [ participant, participant2, participant3  ]
      expect( Participant.sort_by_name( unsorted ) ).to eq( sorted )
    end
  end
end
