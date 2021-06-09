class AssignmentTeamAnalyticTestDummyClass 
	attr_accessor :responses, :participants 
	require 'analytic/assignment_team_analytic'
	include AssignmentTeamAnalytic
	
	def initialize(responses, participants)
		@responses = responses
		@participants = participants
	end
end

describe AssignmentTeamAnalytic do
  describe '#num_participants' do
    context 'when the participants are set to an empty array' do
      it 'should return zero' do
        dc = AssignmentTeamAnalyticTestDummyClass.new([],[])
        expect(dc.num_participants).to eq(0)
      end
    end
    context 'when the participants are set a list of three participants' do
      it 'should return three' do

      end
    end
  end
  describe '#num_reviews' do
    context 'when the responses are set to an empty array' do
      it 'should return zero' do

      end
    end
    context 'when the responses are set a list of three responses' do
      it 'should return three' do

      end
    end
  end
  describe '#average_review_score' do
    context 'when there are no reviews' do
      it 'returns zero' do

      end
    end
    context 'when there are reviews of [2, 4, 6]' do
      it 'return 4 as the average' do

      end
    end
  end
  describe '#max_review_score' do
    it 'should return the highest score' do

    end
  end
  describe '#min_review_score' do
    it 'should return the lowest score' do

    end
  end
  describe '#total_review_word_count' do
    context 'if there are no reviews' do
      it 'should return zero' do

      end
    end
  end
end