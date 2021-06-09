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
  let(:participant) { build(:participant, user: build(:student, name: "Jane", fullname: "Doe, Jane", id: 1)) }
  let(:participant2) { build(:participant, user: build(:student, name: "John", fullname: "Doe, John", id: 2)) }
  let(:participant3) { build(:participant, can_review: false, user: build(:student, name: "King", fullname: "Titan, King", id: 3)) }
  let(:response) { build(:response) }
  let(:response2) { build(:response) }
  let(:response3) { build(:response) }
  describe '#num_participants' do
    context 'when the participants are set to an empty array' do
      it 'should return zero' do
        dc = AssignmentTeamAnalyticTestDummyClass.new([],[])
        expect(dc.num_participants).to eq(0)
      end
    end
    context 'when the participants are set a list of three participants' do
      it 'should return three' do
        dc = AssignmentTeamAnalyticTestDummyClass.new([], [participant, participant2, participant3])
        expect(dc.num_participants).to eq(3)
      end
    end
  end
  describe '#num_reviews' do
    context 'when the responses are set to an empty array' do
      it 'should return zero' do
        dc = AssignmentTeamAnalyticTestDummyClass.new([],[])
        expect(dc.num_reviews).to eq(0)
      end
    end
    context 'when the responses are set a list of three responses' do
      it 'should return three' do
        dc = AssignmentTeamAnalyticTestDummyClass.new([response, response2, response3],[])
        expect(dc.num_reviews).to eq(3)
      end
    end
  end
  describe '#average_review_score' do
    context 'when there are no reviews' do
      it 'returns zero' do
        dc = AssignmentTeamAnalyticTestDummyClass.new([],[])
        expect(dc.average_review_score).to eq(0)
      end
    end
    context 'when there are reviews of [2, 4, 6]' do
      it 'return 4 as the average' do
        dc = AssignmentTeamAnalyticTestDummyClass.new([response, response2, response3],[])
        allow(dc).to receive(:review_scores).and_return([2,4,6])
        expect(dc.average_review_score).to eq(4)
      end
    end
  end
  describe '#max_review_score' do
    it 'should return the highest score' do
      dc = AssignmentTeamAnalyticTestDummyClass.new([response, response2, response3],[])
      allow(dc).to receive(:review_scores).and_return([2,4,6])
      expect(dc.max_review_score).to eq(6)
    end
  end
  describe '#min_review_score' do
    it 'should return the lowest score' do
      dc = AssignmentTeamAnalyticTestDummyClass.new([response, response2, response3],[])
      allow(dc).to receive(:review_scores).and_return([2,4,6])
      expect(dc.min_review_score).to eq(2)
    end
  end
  describe '#total_review_word_count' do
    context 'if there are no reviews' do
      it 'should return zero' do

      end
    end
  end
end