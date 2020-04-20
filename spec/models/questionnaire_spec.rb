describe Questionnaire do
  let(:questionnaire) { Questionnaire.new name: "abc", private: 0, min_question_score: 0, max_question_score: 10, instructor_id: 1234 }
  let(:questionnaire1) { Questionnaire.new name: "xyz", private: 0, max_question_score: 20, instructor_id: 1234 }

  describe "#name" do
    it "returns the name of the Questionnaire" do
      expect(questionnaire.name).to eq("abc")
    end

    it "Validate presence of name which cannot be blank" do
      questionnaire.name = '  '
      expect(questionnaire).not_to be_valid
    end
  end

  describe "#instrucor_id" do
    it "returns the instructor id" do
      expect(questionnaire.instructor_id).to eq(1234)
    end
  end

  describe "#maximum_score" do
    it "validate maximum score" do
      expect(questionnaire.max_question_score).to eq(10)
    end

    it "validate maximum score is integer" do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = 'a'
      expect(questionnaire).not_to be_valid
    end

    it "validate maximum should be positive" do
      expect(questionnaire.max_question_score).to eq(10)
      questionnaire.max_question_score = -10
      expect(questionnaire).not_to be_valid
      questionnaire.max_question_score = 10
    end
  end

  describe "#minimum_score" do
    it "validate minimum score" do
      questionnaire.min_question_score = 5
      expect(questionnaire.min_question_score).to eq(5)
    end

    it "validate default minimum score" do
      expect(questionnaire1.min_question_score).to eq(0)
    end

    it "validate minimum should be smaller than maximum" do
      expect(questionnaire.min_question_score).to eq(0)
      questionnaire.min_question_score = 10
      expect(questionnaire).not_to be_valid
      questionnaire.min_question_score = 0
    end
  end

  it "allowing calls from copy_questionnaire_details" do
    allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
    allow(Question).to receive(:where).with(questionnaire_id: '1').and_return([Question])
    question_advice = build(:question_advice)
    allow(QuestionAdvice).to receive(:where).with(question_id: 1).and_return([question_advice])
  end

  describe "#questions" do
    before :each do
      questionnaire.save
      @team = create(:assignment_team, id: 1)
      @question_without_team_id = create(:question, id: 1, txt: "Question 1", seq: 1.00, team_id: nil, questionnaire_id: questionnaire.id)
      @question_with_team_id = create(:question, id: 2, txt: "Question 2", seq: 2.00, team_id: @team.id, questionnaire_id: questionnaire.id)
      @question_with_another_team_id = create(:question, id: 3, txt: "Question 3", seq: 1.00, team_id: 2, questionnaire_id: questionnaire.id)
    end
    context "without team_id" do
      it "returns only questions from the original rubric" do
        questions = questionnaire.questions
        expect(questions.size).to eql(1)
        expect(questions[0]).to eql(@question_without_team_id)
      end
    end
    context "with team_id" do
      it "returns both questions from the original rubric as well as questions created by the team" do
        questions = questionnaire.questions(@team.id)
        expect(questions.size).to eql(3)
        expect(questions[0]).to eql(@question_without_team_id)
        expect(questions[1]).to be_a(SectionHeader)
        expect(questions[2]).to eql(@question_with_team_id)
      end
    end
  end
end
