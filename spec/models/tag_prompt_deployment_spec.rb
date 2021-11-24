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
  let(:user1) {User.new(id: 1)}
  let(:user2) {User.new(id: 2)}
  let(:team_user1) {TeamsUser.new(user_id: user1.id, team_id: team.id)}
  let(:team_user2) {TeamsUser.new(user_id: user2.id, team_id: team.id)}
  let(:tagA) {AnswerTag.new(tag_prompt_deployment_id: tag_dep.id, user_id: user1.id, answer: answer, updated_at: Date.new.to_s)}
  let(:tagB) {AnswerTag.new(tag_prompt_deployment_id: tag_dep.id, user_id: user2.id, answer: answer, updated_at: Date.new.to_s)}
  answers = {
    'answer1': {id: 1, question_id: 1, answer: 3, comments: 'comm', response_id: 2313},
    'answer2': {id: 2, question_id: 1, answer: 3, comments: 'comment length exceeds threshold', response_id: 2313},
    'answer3': {id: 3, question_id: 1, answer: 3, comments: 'comment length within threshold', response_id: 2313},
    'answer4': {id: 4, question_id: 2, answer: 1, comments: 'com1', response_id: 241} }
  answersObjectArray = answers.values.map do |answerParams| Answer.new(answerParams) end

  short_comments_answers = {
    'answer1': {id: 1, question_id: 1, answer: 3, comments: 'comm', response_id: 2313},
    'answer4': {id: 4, question_id: 2, answer: 1, comments: 'com1', response_id: 241} }

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

      user_answer_tagging = tag_dep.assignment_tagging_progress

      expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
      expect(ResponseMap).not_to receive(:assessments_for)
      expect(Answer).not_to receive(:where)
      expect(AnswerTag).not_to receive(:where)
      expect(user_answer_tagging).to be_empty
    end

    it 'does nothing when no questions are found' do
      allow(Team).to receive(:where).with(parent_id: team.parent_id).and_return([team])
      allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([])

      user_answer_tagging = tag_dep.assignment_tagging_progress

      expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
      expect(ResponseMap).not_to receive(:assessments_for)
      expect(Answer).not_to receive(:where)
      expect(AnswerTag).not_to receive(:where)
      expect(user_answer_tagging).to be_empty
    end

    it 'does not vary by round' do
      allow(Team).to receive(:where).with(parent_id: team.parent_id).and_return([team])
      allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([question])
      allow(assignment).to receive(:vary_by_round).and_return(false)
      allow(ResponseMap).to receive(:assessments_for).and_return(responses)
      allow(Answer).to receive(:where).and_return(answersObjectArray)
      allow(TeamsUser).to receive(:where).with(team_id: team.id).and_return([team_user1, team_user2])
      allow(User).to receive(:find).with(user1.id).and_return(user1)
      allow(User).to receive(:find).with(user2.id).and_return(user2)
      allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user1.id, answer_id: [2, 3]).and_return([tagA])
      allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user2.id, answer_id: [2, 3]).and_return([tagB])

      user_answer_tagging = tag_dep.assignment_tagging_progress

      expect(user_answer_tagging).not_to be_empty
      expect(user_answer_tagging.length).to eq(2)
      p user_answer_tagging[0]
      p user_answer_tagging[1]
      expect(user_answer_tagging[0].user).to eq(user1)
      expect(user_answer_tagging[1].user).to eq(user2)

    end

  end
end