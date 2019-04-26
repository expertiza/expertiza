describe Metric do
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) } 
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:team) { build(:assignment_team) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }

  describe '#suggestion_chance_average' do
  end

  describe '#get_sentiment_text' do
    context 'when avg_sentiment_for_response is -0.4' do
      it 'returns Negative' do
        expect(metric.get_sentiment_text(-0.4)).to eq("Negative")
      end
    end
      
    context 'when avg_sentiment_for_response is 0' do
      it 'returns Neutral' do
        expect(metric.get_sentiment_text(0)).to eq("Neutral")
      end
    end

    context 'when avg_sentiment_for_response is 0.4' do
      it 'returns Positive' do
        expect(metric.get_sentiment_text(0.4)).to eq("Positive")
      end
    end
  end

end
