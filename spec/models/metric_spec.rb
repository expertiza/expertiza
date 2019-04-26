describe Metric do
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) } 
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:team) { build(:assignment_team) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }


  describe '#update_suggestion_chance' do
  end

  describe '#suggestion_chance_average' do
  end

  describe '#get_sentiment_text' do
  end

end
