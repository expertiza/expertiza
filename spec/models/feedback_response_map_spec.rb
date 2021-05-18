describe FeedbackResponseMap do
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'AuthorFeedbackQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'MetareviewQuestionnaire') }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:team) { build(:assignment_team) }
  let(:assignment_participant) { build(:participant, id: 2, assignment: assignment) }
  let(:feedback_response_map) { build(:feedback_response_map) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  before(:each) do
    allow(feedback_response_map).to receive(:reviewee).and_return(participant)
    allow(feedback_response_map).to receive(:review).and_return(response)
    allow(feedback_response_map).to receive(:reviewer).and_return(assignment_participant)
    allow(response).to receive(:map).and_return(review_response_map)
    allow(review_response_map).to receive(:assignment).and_return(assignment)
  end
  describe '#assignment' do
    it 'returns the assignment associated with this FeedbackResponseMap' do
      expect(feedback_response_map.assignment).to eq(assignment)
    end 
  end
  describe '#show_review' do
    context 'when there is a review' do
      it 'displays the html' do
        allow(review).to receive(:display_as_html).and_return('HTML')
        expect(feedback_response_map.show_review).to eq('HTML')
      end
    end
    context 'when there is no review available' do
      it 'returns an error' do
        allow(feedback_response_map).to receive(:review).and_return(nil)
        expect(feedback_response_map.show_review).to eq('No review was performed')
      end
    end
  end  
end