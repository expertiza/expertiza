describe Metric do
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) } 
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment1) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:assignment2) { build(:assignment, id: 2, name: 'Test Assgt Nil') }
  let(:team) { build(:assignment_team) }
  let(:response1) { build(:response, id: 2, map_id: 1, response_map: review_response_map1, suggestion_chance_percentage: 0.3) }
  let(:response2) { build(:response, id: 3, map_id: 1, response_map: review_response_map1, suggestion_chance_percentage: 0.5) }
  let(:response3) { build(:response, id: 1, map_id: 2, response_map: review_response_map2, suggestion_chance_average: nil) }

  describe '#suggestion_chance_average' do
    context 'when response suggestion_chance_percentage is nil' do
      it 'return -1' do
        allow(ResponseMap).to receive(:where).with(:reviewed_object_id: assignment2)).and_return(response_map_list)
        allow(response_map_list).to receive(:where).with(map_id: 2).and_return([response3])
        allow(response3).to receive(:suggestion_chance_percentage).and_return(nil)
        expect(suggestion_chance_average(assignment2)).to eq(nil)
      end
    end

    context 'when response suggestion_chance_percentage is not nil' do
      it 'return -1' do
          allow(ResponseMap).to receive(:where).with(:reviewed_object_id: assignment1)).and_return(response_map_list)
          allow(response_map_list).to receive(:where).with(map_id: 1).and_return([response1, response2])
          allow(response1).to receive(:suggestion_chance_percentage).and_return(0.3)
          allow(response2).to receive(:suggestion_chance_percentage).and_return(0.5) 
          expect(suggestion_chance_average(assignment1)).to eq(0.4)
      end
    end
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
