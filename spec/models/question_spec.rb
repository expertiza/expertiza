describe 'Question' do
  let(:questionnaire) { Questionnaire.new id: 1, name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:team) { build(:assignment_team, id: 1) }
  let(:question_1) { build(:question, id: 1, txt: "Question 1", seq: 1.00, team_id: nil) }
  let(:question_2) { build(:question, id: 2, txt: "Question 2", seq: 2.00, team_id: 1) }

  before :each do
    questionnaire.save
    team.save
    question_1.save
    question_2.save
  end
  it 'is a ReviewQuestionnaire question if it does not belong to any team' do
    question = Question.find_by(questionnaire_id: questionnaire.id, team_id: nil)
    expect(question).to eq(question_1)
  end
  it 'is a RevisionPlanning question if it belongs to a team' do
    question = Question.find_by(questionnaire_id: questionnaire.id, team_id: team.id)
    expect(question).to eq(question_2)
    expect(question.team).to eq(team)
  end
end
