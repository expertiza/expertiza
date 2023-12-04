describe MultipleChoiceRadio do
  let(:multiple_choice_radio) { build(:multiple_choice_radio, id: 1) }
  let(:questionnaire1) { build(:questionnaire, id: 1, type: "ReviewQuestionnaire") }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: "MetareviewQuestionnaire") }
  let(:team) { build(:assignment_team, id: 1, name: "no team") }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment) { build(:assignment, id: 1, name: "no assignment", participants: [participant], teams: [team]) }
  let(:scored_question) { build(:scored_question, id: 1) }
  let(:question) { build(:question) }
  describe "#edit" do
    it "returns the html" do
      qc = double("QuizQuestionChoice")
      allow(QuizQuestionChoice).to receive(:where).with(question_id: 1).and_return([qc, qc, qc, qc])
      allow(qc).to receive(:iscorrect).and_return(true)
      allow(qc).to receive(:txt).and_return("question text")

      html = Nokogiri::HTML(multiple_choice_radio.edit)

      # Test for presence of a text area for the question text
      expect(html.css('textarea[name="question[1][txt]"]')).not_to be_empty
    end
  end
  describe "#isvalid" do
    context "when the question itself does not have txt" do
      it "returns 'Please make sure all questions have text'" do
        allow(multiple_choice_radio).to receive(:txt).and_return("")
        choices = { "1" => { txt: "choice text", iscorrect: "1" }, "2" => { txt: "choice text", iscorrect: "1" }, "3" => { txt: "choice text", iscorrect: "0" }, "4" => { txt: "choice text", iscorrect: "0" } }
        expect(multiple_choice_radio.isvalid(choices)).to eq("Please make sure all questions have text")
      end
    end
    context "when a choice does not have txt" do
      it 'returns "Please make sure every question has text for all options"' do
        allow(multiple_choice_radio).to receive(:txt).and_return("Question Text")
        choices = { "1" => { txt: "", iscorrect: "1" }, "2" => { txt: "", iscorrect: "1" }, "3" => { txt: "", iscorrect: "0" }, "4" => { txt: "", iscorrect: "0" } }
        expect(multiple_choice_radio.isvalid(choices)).to eq("Please make sure every question has text for all options")
      end
    end
    context "when no choices are correct" do
      it 'returns "Please select a correct answer for all questions"' do
        allow(multiple_choice_radio).to receive(:txt).and_return("Question Text")
        choices = { "1" => { txt: "choice text", iscorrect: 0 }, "2" => { txt: "choice text", iscorrect: 0 }, "3" => { txt: "choice text", iscorrect: 0 }, "4" => { txt: "choice text", iscorrect: 0 } }
        expect(multiple_choice_radio.isvalid(choices)).to eq("Please select a correct answer for all questions")
      end
    end
  end
  # describe "#view_correct_answer" do
  #   context "when valid input" do
  #     it "returns the html showing correct answer(s)" do
  #       allow(multiple_choice_radio).to receive(:txt).and_return("question")
  #       choices = { "1" => { txt: "choice1", iscorrect: "1" }, "2" => { txt: "choice2", iscorrect: "1" }, "3" => { txt: "choice3", iscorrect: "0" }, "4" => { txt: "choice4", iscorrect: "0" } }
  #       allow(multiple_choice_radio).to receive(:quiz_question_choices).and_return(choices)
  #       answer = [{ comments: "choice1", iscorrect: true, txt: "choice1" }]
  #       html = Nokogiri::HTML(multiple_choice_radio.view_completed_question(answer))
  #       puts html
  #     end
  #   end
  # end
  describe "#get_formatted_question_type" do
    it 'returns "Multiple Choice - Checked"' do
      expect(multiple_choice_radio.get_formatted_question_type).to eq("Multiple Choice - Radio")
    end
  end
  describe "#compute_question_score" do
    it "returns 0" do
      expect(Question.compute_question_score).to eq(0)
    end
  end
  describe "#export_fields" do
    it "returns the column headers" do
      expect(Question.export_fields([])).to eq(["Seq", "Question", "Type", "Weight", "text area size", "max_label", "min_label"])
    end
  end
  describe "#get_all_questions_with_comments_available" do
    context "when the assignment has no questionnaires associated" do
      it "returns an empty array" do
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(assignment).to receive(:questionnaires).and_return([])
        expect(Question.get_all_questions_with_comments_available(assignment.id)).to eq([])
      end
    end
    context "when the assignment has two questionnaires associated, metareview and review, with one scored question" do
      it "returns an array of the id of the scored question" do
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(assignment).to receive(:questionnaires).and_return([questionnaire1, questionnaire2])
        allow(questionnaire1).to receive(:questions).and_return([scored_question])
        expect(Question.get_all_questions_with_comments_available(assignment.id)).to eq([1])
      end
    end
  end
  describe "#import" do
    context "when the row length is not 5" do
      it "throws an error" do
        expect { Question.import(%w[header1 header2 header3], [], [], nil) }.to raise_error(ArgumentError)
      end
    end
    context "when there is no questionnaire" do
      it "throws an error" do
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(nil)
        expect { Question.import(%w[header1 header2 header3 header4 header5], [], [], 1) }.to raise_error(ArgumentError)
      end
    end
  end
  describe "#export" do
    it "writes to a csv file" do
      csv_1 = []
      allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire1)
      allow(questionnaire1).to receive(:questions).and_return([question])
      expect(Question.export(csv_1, 1, nil)).to eq([question])
    end
  end
end
