describe Questionnaire do
  let(:questionnaire) { Questionnaire.new name: 'abc', private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:questionnaire1) { Questionnaire.new name: 'xyz', private: 0, max_question_score: 20, instructor_id: 1234 }
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 2) }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'MetareviewQuestionnaire') }
  let!(:checkbox1) { Checkbox.create(id: 3, type: 'Checkbox', seq: 2.0, txt: 'test txt2', weight: 11) }
  let(:question1) { create(:question, questionnaire: questionnaire2, weight: 1, id: 1) }
  let(:question2) { create(:question, questionnaire: questionnaire2, weight: 2, id: 2) }
  let(:questionnaire_node) { build(:questionnaire_node) }
  describe '#name' do
    it 'returns the name of the Questionnaire' do
      expect(questionnaire.name).to eq('abc')
    end

    it 'Validate presence of name which cannot be blank' do
      questionnaire.name = '  '
      expect(questionnaire).not_to be_valid
    end
  end

  describe '#instructor_id' do
    it 'returns the instructor id' do
      expect(questionnaire.instructor_id).to eq(1234)
    end
  end

  describe '#maximum_score' do
    it 'validate maximum score' do
      expect(questionnaire.max_question_score).to eq(10)
    end

    it 'validate maximum score is integer' do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = 'a'
      expect(questionnaire).not_to be_valid
    end

    it 'validate maximum should be positive' do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = -10
      expect(questionnaire).not_to be_valid
      questionnaire.max_question_score = 10
    end
  end

  describe '#minimum_score' do
    it 'validate minimum score' do
      questionnaire.min_question_score = 5
      expect(questionnaire.min_question_score).to eq(5)
    end

    it 'validate default minimum score' do
      expect(questionnaire1.min_question_score).to eq(0)
    end

    it 'validate minimum should be smaller than maximum' do
      expect(questionnaire.min_question_score).to eq(0)
      questionnaire.min_question_score = 10
      expect(questionnaire).not_to be_valid
      questionnaire.min_question_score = 0
    end
  end

  it 'allowing calls from copy_questionnaire_details' do
    allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
    allow(Question).to receive(:where).with(questionnaire_id: '1').and_return([Question])
    question_advice = build(:question_advice)
    allow(QuestionAdvice).to receive(:where).with(question_id: 1).and_return([question_advice])
  end

  describe '#get_weighted_score' do
    context 'when there are no rounds' do
      it 'just uses the symbol with no round' do
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 2).and_return(assignment_questionnaire1)
        allow(assignment_questionnaire1).to receive(:used_in_round).and_return(nil)
        allow(questionnaire2).to receive(:symbol).and_return('a')
        allow(questionnaire2).to receive(:assignment_questionnaires).and_return(assignment_questionnaire1)
        allow(assignment_questionnaire1).to receive(:find_by).with(assignment_id: 1).and_return(assignment_questionnaire1)
        scores = { 'a' => { scores: { avg: 100 } } }
        expect(questionnaire2.get_weighted_score(assignment, scores)).to eq(100)
      end
    end
  end

  describe '#true_false_questions?' do
    context 'when there are no true/false questions' do
      it 'returns false' do
        allow(questionnaire2).to receive(:questions).and_return([question1, question2])
        expect(questionnaire2.true_false_questions?).to eq(false)
      end
    end
    context 'when there is a true/false question' do
      it 'returns true' do
        allow(questionnaire2).to receive(:questions).and_return([question1, question2, checkbox1])
        expect(questionnaire2.true_false_questions?).to eq(true)
      end
    end
    context 'when there are no associated questions' do
      it 'returns false' do
        allow(questionnaire2).to receive(:questions).and_return([])
        expect(questionnaire2.true_false_questions?).to eq(false)
      end
    end
  end

  describe '#delete' do
    it 'deletes all dependent objects and itself' do
      allow(questionnaire2).to receive(:questions).and_return([question1, question2])
      allow(questionnaire2).to receive(:assignments).and_return([])
      allow(QuestionnaireNode).to receive(:find_by).with(node_object_id: 2).and_return(questionnaire_node)
      expect(questionnaire2.delete).to be_truthy
    end
    context 'when there are associated assignments' do
      it 'raises an error' do
        allow(questionnaire2).to receive(:questions).and_return([question1, question2])
        allow(questionnaire2).to receive(:assignments).and_return([assignment])
        allow(QuestionnaireNode).to receive(:find_by).with(node_object_id: 2).and_return(questionnaire_node)
        expect { questionnaire2.delete }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#max_possible_score' do
    it 'returns the highest possible score for the questionnaire' do
      questions = [question1, question2, checkbox1]
      allow(Questionnaire).to receive(:joins).with('INNER JOIN questions ON questions.questionnaire_id = questionnaires.id').and_return(questions)
      allow(questions).to receive(:select).with('SUM(questions.weight) * questionnaires.max_question_score as max_score').and_return(questions)
      allow(questions).to receive(:where).with('questionnaires.id = ?', 2).and_return(questions)
      allow(question1).to receive(:max_score).and_return(100)
      expect(questionnaire2.max_possible_score).to eq(100)
    end
  end
end
