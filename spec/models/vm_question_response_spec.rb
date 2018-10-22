describe VmQuestionResponse do
  let(:assignment) { build(:assignment, id: 1, questionnaires: [review_questionnaire], is_penalty_calculated: true) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  questionnaire = Questionnaire.new
  let(:response){ VmQuestionResponse.new(questionnaire, assignment)}

  it 'adds a question that is not a QuestionnaireHeader' do
    response.add_questions 'q1'
  end  
end