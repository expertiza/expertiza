describe TeammateReviewResponseMap do
  let(:questionnaire) { Questionnaire.new name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:assignment) { build(:assignment, id: 1, name: 'no assgt', duty_based_assignment?: true, questionnaires: [questionnaire]) }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 2, duty_id: 1) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:teammate_review_response_map) { TeammateReviewResponseMap.new reviewer: participant, reviewer_is_team: true, assignment:assignment }


  describe '#questionnaire_by_duty' do
    it 'returns questionnaire specific to a duty' do
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, duty_id: 1).and_return([assignment_questionnaire1])
      allow(Questionnaire).to receive(:find).with(assignment_questionnaire1.questionnaire_id).and_return(questionnaire)
      expect(teammate_review_response_map.questionnaire_by_duty(1)).to eq questionnaire
    end
    it 'returns default questionnaire when no questionnaire is found for duty' do
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, duty_id: 1).and_return([])
      allow(assignment.questionnaires).to receive(:find_by).with(type: 'TeammateReviewQuestionnaire').and_return(questionnaire)
      expect(teammate_review_response_map.questionnaire_by_duty(1)).to eq questionnaire
    end
  end
end

