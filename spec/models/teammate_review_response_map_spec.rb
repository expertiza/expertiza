describe TeammateReviewResponseMap do
  let(:questionnaire) { Questionnaire.new name: 'abc', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 2, duty_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:teammate_review_response_map) { TeammateReviewResponseMap.new reviewer: participant, team_reviewing_enabled: true, assignment: assignment }

  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:teammate_review_response_map1) { build(:teammate_review_response_map, id: 1, assignment: assignment1, reviewer: participant, reviewee: participant1) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant, reviewee: team) }

  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: student1) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: teammate_review_response_map1,  is_submitted: true) }
  let(:student) { build(:student, id: 1, username: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, username: 'name1', fullname: 'no one', email: 'expertiza@mailinator.com') }
  #  let(:assignment_teammate_questionnaire1) { build(:assignment_teammate_questionnaire, id: 1, assignment: assignment1, questionnaire: teammate_questionnaire1) }
  #  let(:assignment_teammate_questionnaire2) { build(:assignment_teammate_questionnaire, id: 2, assignment_id: 2, questionnaire_id: 2) }
  #  let(:teammate_questionnaire1) { build(:teammate_questionnaire, id: 1, type: 'TeammateReviewQuestionnaire') }
  #  let(:teammate_questionnaire2) { build(:teammate_questionnaire, id: 2, type: 'TeammateReviewQuestionnaire') }
  let(:response3) { build(:response) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response3]) }
  before(:each) do
    allow(teammate_review_response_map1).to receive(:response).and_return(response)
    allow(response_map).to receive(:response).and_return(response3)
    allow(response_map).to receive(:id).and_return(1)
  end

  # contributor method is unfinished, so this is a skeleton test
  describe '#contributor' do
    context 'when contributor method is called' do
      it '#contributor' do
        expect(teammate_review_response_map1.contributor).to eq(nil)
      end
    end
  end

  describe '#get_title' do
    context 'when get_title is called' do
      it '#get_title' do
        expect(teammate_review_response_map1.get_title).to eq('Teammate Review')
      end
    end
  end

  # describe '#questionnaire' do
  #   # This method is little more than a wrapper for assignment.review_questionnaire_id()
  #
  #   context 'when corresponding active record for assignment_questionnaire is found' do
  #     before(:each) do
  #       allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
  #           [assignment_teammate_questionnaire1, assignment_teammate_questionnaire2])
  #       allow(Questionnaire).to receive(:find).with(1).and_return(assignment_teammate_questionnaire1)
  #     end
  #
  #     it 'returns correct questionnaire found by used_in_round and topic_id if both used_in_round and topic_id are given' do
  #       allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment1.id, used_in_round: 1, topic_id: 1).and_return(
  #           [assignment_teammate_questionnaire1])
  #       allow(Questionnaire).to receive(:find_by!).with(type: 'TeammateReviewQuestionnaire').and_return([teammate_questionnaire1])
  #       #allow(Questionnaire).to receive(:where!).and_return([teammate_questionnaire1])
  #       assignment1.questionnaires = [teammate_questionnaire1, teammate_questionnaire2]
  #       expect(teammate_review_response_map1.questionnaire()).to eq(teammate_questionnaire1)
  #     end
  #
  #   end
  # end

  describe '#teammate_response_report' do
    context 'return an assignment given an id' do
      it '#teammate_response_report' do
        allow(TeammateReviewResponseMap).to receive_message_chain(:select, :where).and_return(assignment1)
        expect(TeammateReviewResponseMap.teammate_response_report(2)).to eq(assignment1)
      end
    end
  end

  describe '#questionnaire_by_duty' do
    it 'returns questionnaire specific to a duty' do
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, duty_id: 1).and_return([assignment_questionnaire1])
      allow(Questionnaire).to receive(:find).with(assignment_questionnaire1.questionnaire_id).and_return(questionnaire)
      expect(teammate_review_response_map.questionnaire_by_duty(1)).to eq questionnaire
    end
    it 'returns default questionnaire when no questionnaire is found for duty' do
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, duty_id: 1).and_return([])
      allow(assignment).to receive(:questionnaires).and_return(questionnaire)
      allow(questionnaire).to receive(:find_by).with(type: 'TeammateReviewQuestionnaire').and_return(questionnaire)
      expect(teammate_review_response_map.questionnaire_by_duty(1)).to eq questionnaire
    end
  end

  describe '#email' do
    context 'when an email notification is sent' do
      it '#email' do
        reviewer_id = 1
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant)
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(AssignmentTeam).to receive(:find).with(1).and_return(team)
        allow(AssignmentTeam).to receive(:users).and_return(student)
        allow(User).to receive(:find).with(1).and_return(student)
        review_response_map.reviewee_id = 1
        defn = { body: { type: 'TeammateReview', obj_name: 'Test Assgt', first_name: 'no one', partial_name: 'new_submission' }, to: 'expertiza@mailinator.com' }
        expect { teammate_review_response_map1.email(defn, participant, Assignment.find(Participant.find(reviewer_id).parent_id)) }
          .to change { ActionMailer::Base.deliveries.count }.by 1
      end
    end
  end
end
