describe FeedbackResponseMap do
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'AuthorFeedbackQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'MetareviewQuestionnaire') }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:team) { build(:assignment_team) }
  let(:assignment_participant) { build(:participant, id: 2, assignment: assignment) }
  let(:feedback_response_map) { build(:feedback_response_map) }
  let(:review_response_map) { build(:review_response_map, id: 2, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:user1) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  before(:each) do
    questionnaires = [questionnaire1, questionnaire2]
    allow(feedback_response_map).to receive(:reviewee).and_return(participant)
    allow(feedback_response_map).to receive(:review).and_return(response)
    allow(feedback_response_map).to receive(:reviewer).and_return(assignment_participant)
    allow(response).to receive(:map).and_return(review_response_map)
    allow(response).to receive(:reviewee).and_return(assignment_participant)
    allow(review_response_map).to receive(:assignment).and_return(assignment)
    allow(feedback_response_map).to receive(:assignment).and_return(assignment)
    allow(assignment).to receive(:questionnaires).and_return(questionnaires)
    allow(questionnaires).to receive(:find_by).with(type: 'AuthorFeedbackQuestionnaire').and_return([questionnaire1])
  end
  describe '#assignment' do
    it 'returns the assignment associated with this FeedbackResponseMap' do
      expect(feedback_response_map.assignment).to eq(assignment)
    end
  end
  describe '#show_review' do
    context 'when there is a review' do
      it 'displays the html' do
        allow(response).to receive(:display_as_html).and_return('HTML')
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
  describe '#get_title' do
    it 'returns "Feedback"' do
      expect(feedback_response_map.get_title).to eq('Feedback')
    end
  end
  describe '#questionnaire' do
    it 'returns an AuthorFeedbackQuestionnaire' do
      expect(feedback_response_map.questionnaire.first.type).to eq('AuthorFeedbackQuestionnaire')
    end
  end
  describe '#contributor' do
    it 'returns the reviewee' do
      expect(feedback_response_map.contributor).to eq(team)
    end
  end
  describe '#feedback_response_report' do
    context 'when the assignment has reviews that vary by round' do
      it 'returns a report' do
        # This function should probably be refactored and moved into a controller
        maps = [review_response_map]
        allow(ReviewResponseMap).to receive(:where).with(['reviewed_object_id = ?', 1]).and_return(maps)
        allow(maps).to receive(:pluck).with('id').and_return(review_response_map.id)
        allow(AssignmentTeam).to receive_message_chain(:includes, :where).and_return([team])
        allow(team).to receive(:users).and_return([user1])
        allow(user1).to receive(:id).and_return(1)
        allow(AssignmentParticipant).to receive(:where).with(parent_id: 1, user_id: 1).and_return([participant])
        response1 = double('Response', round: 1, additional_comment: '')
        response2 = double('Response', round: 2, additional_comment: 'LGTM')
        response3 = double('Response', round: 3, additional_comment: 'Bad')
        rounds = [response1, response2, response3]
        allow(Response).to receive(:where).with(['map_id IN (?)', 2]).and_return(rounds)
        allow(rounds).to receive(:order).with('created_at DESC').and_return(rounds)
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(assignment).to receive(:vary_with_round).and_return(true)
        allow(response1).to receive(:map_id).and_return(1)
        allow(response2).to receive(:map_id).and_return(2)
        allow(response3).to receive(:map_id).and_return(3)
        allow(response1).to receive(:id).and_return(1)
        allow(response2).to receive(:id).and_return(2)
        allow(response3).to receive(:id).and_return(3)
        report = FeedbackResponseMap.feedback_response_report(1, nil)
        expect(report[0]).to eq([participant])
        expect(report[1]).to eq([1, 2, 3])
        expect(report[2]).to eq(nil)
        expect(report[3]).to eq(nil)
      end
    end
    context 'when the assignment has reviews that do not vary by round' do
      it 'returns a report' do
        # This function should probably be refactored and moved into a controller
        maps = [review_response_map]
        allow(ReviewResponseMap).to receive(:where).with(['reviewed_object_id = ?', 1]).and_return(maps)
        allow(maps).to receive(:pluck).with('id').and_return(review_response_map.id)
        allow(AssignmentTeam).to receive_message_chain(:includes, :where).and_return([team])
        allow(team).to receive(:users).and_return([user1])
        allow(user1).to receive(:id).and_return(1)
        allow(AssignmentParticipant).to receive(:where).with(parent_id: 1, user_id: 1).and_return([participant])
        response1 = double('Response', round: 1, additional_comment: '')
        response2 = double('Response', round: 1, additional_comment: 'LGTM')
        response3 = double('Response', round: 1, additional_comment: 'Bad')
        reviews = [response1, response2, response3]
        allow(Response).to receive(:where).with(['map_id IN (?)', 2]).and_return(reviews)
        allow(reviews).to receive(:order).with('created_at DESC').and_return(reviews)
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(assignment).to receive(:vary_with_round).and_return(false)
        allow(response1).to receive(:map_id).and_return(1)
        allow(response2).to receive(:map_id).and_return(2)
        allow(response3).to receive(:map_id).and_return(3)
        allow(response1).to receive(:id).and_return(1)
        allow(response2).to receive(:id).and_return(2)
        allow(response3).to receive(:id).and_return(3)
        report = FeedbackResponseMap.feedback_response_report(1, nil)
        expect(report[0]).to eq([participant])
        expect(report[1]).to eq([1, 2, 3])
      end
    end
  end
  describe '#email' do
    it 'returns a message' do
      allow(feedback_response_map).to receive(:reviewed_object_id).and_return(1)
      allow(Response).to receive(:find).with(1).and_return(response)
      allow(response).to receive(:map_id).and_return(1)
      allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
      allow(review_response_map).to receive(:reviewer_id).and_return(1)
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(assignment_participant)
      allow(assignment).to receive(:name).and_return('Big Assignment')
      allow(assignment_participant).to receive(:user_id).and_return(1)
      allow(User).to receive(:find).with(1).and_return(user1)
      defn = { body: { type: nil, obj_name: nil, first_name: nil }, to: nil }
      allow(feedback_response_map).to receive(:email).and_return(body: { type: 'Author Feedback', obj_name: 'Big Assignment', first_name: 'abc bbc' }, to: 'abcbbc@gmail.com')
      expect(feedback_response_map.email(defn, assignment_participant, assignment)).to eq(body: { type: 'Author Feedback', obj_name: 'Big Assignment', first_name: 'abc bbc' }, to: 'abcbbc@gmail.com')
    end
  end
end
