describe TagPromptDeployment do
  let(:tag_dep) { TagPromptDeployment.new(id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: 15, assignment: assignment, questionnaire: questionnaire) }
  let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }
  let(:team) {Team.new(id: 1, parent_id: 1)}
  let(:rp) {Response.new(id: 1, round: 1, additional_comment: "improvement scope")}
  let(:responses) {Response.new(id: 1, round: 1, additional_comment: "improvement scope")}
  let(:assignment) {Assignment.new({id: 1})}
  let(:question) {Question.new(questionnaire: questionnaire, type: 'tagging')}
  let(:questionnaire) {Questionnaire.new(id: 1)}
  let(:answer) {Answer.new}
  describe '#tag_prompt' do
    it 'returns the associated tag prompt with the deployment' do
      allow(TagPrompt).to receive(:find).with(1).and_return(tp)
      expect(tag_dep.tag_prompt).to be(tp)
    end
  end

  describe 'assignment_tagging_progress' do
    it 'does nothing when no teams are found' do
      allow(Team).to receive(:where).with(parent_id: team.parent_id).and_return([])
      allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([question])

      tag_dep.assignment_tagging_progress

      expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
      expect(ResponseMap).not_to receive(:assessments_for)
      expect(Answer).not_to receive(:where)
      expect(AnswerTag).not_to receive(:where)
    end

    it 'does nothing when no questions are found' do
      allow(Team).to receive(:where).with(parent_id: team.parent_id).and_return([team])
      allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([])

      tag_dep.assignment_tagging_progress

      expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
      expect(ResponseMap).not_to receive(:assessments_for)
      expect(Answer).not_to receive(:where)
      expect(AnswerTag).not_to receive(:where)
    end

    # it ''
    # allow(Team).to receive(:where).with(parent_id: team.parent_id).and_return(team)
    # allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire_id, question_type: question.type).and_return(question)

  end
end