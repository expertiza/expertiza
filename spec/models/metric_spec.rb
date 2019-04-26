describe Metric do
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) } 
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment1) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:assignment2) { build(:assignment, id: 2, name: 'Test Assgt Nil') }
  let(:team) { build(:assignment_team) }
  let(:review_response_map1) { build(:review_response_map, assignment: assignment1, reviewer: participant, reviewee: team) }
  let(:review_response_map2) { build(:review_response_map, assignment: assignment2, reviewer: participant, reviewee: team) }
  let(:response1) { build(:response, id: 2, map_id: 1, response_map: review_response_map1, suggestion_chance_percentage: 0.3) }
  let(:response2) { build(:response, id: 3, map_id: 1, response_map: review_response_map1, suggestion_chance_percentage: 0.5) }
  let(:response3) { build(:response, id: 1, map_id: 2, response_map: review_response_map2, suggestion_chance_average: nil) }

  describe '#suggestion_chance_average' do
  end

  describe '#get_sentiment_text' do
    context 'when avg_sentiment_for_response is -0.4' do
      it 'returns Negative' do
        expect(get_sentiment_text(-0.4)).to eq("Negative")
      end
    end
      
    context 'when avg_sentiment_for_response is 0' do
      it 'returns Neutral' do
        expect(get_sentiment_text(0)).to eq("Neutral")
      end
    end

    context 'when avg_sentiment_for_response is 0.4' do
      it 'returns Positive' do
        expect(get_sentiment_text(0.4)).to eq("Positive")
      end
    end
  end

end
