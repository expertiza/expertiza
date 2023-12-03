describe TrueFalse do
  let(:true_false) { build(:true_false, id: 1) }
  describe "#edit" do
    it "returns html" do
      qc1 = double("QuizQuestionChoice")
      qc2 = double("QuizQuestionChoice")
      allow(QuizQuestionChoice).to receive(:where).with(question_id: 1).and_return([qc1, qc2])
      allow(qc1).to receive(:iscorrect).and_return(true)
      allow(qc2).to receive(:iscorrect).and_return(false)
      # expect(true_false.edit).to eq('<tr><td><textarea cols="100" name="question[1][txt]" id="question_1_txt">Test question:</textarea></td></tr><tr><td>Question Weight: <input type="number" name="question_weights[1][txt]" id="question_wt_1_txt" value="1" min="0" /></td></tr><tr><td><input type="radio" name="quiz_question_choices[1][TrueFalse][1][iscorrect]" id="quiz_question_choices_1_TrueFalse_1_iscorrect_True" value="True" checked="checked" />True</td></tr><tr><td><input type="radio" name="quiz_question_choices[1][TrueFalse][1][iscorrect]" id="quiz_question_choices_1_TrueFalse_1_iscorrect_True" value="False" />False</td></tr>')
      html = Nokogiri::HTML(true_false.edit)
      # Test for presence of a text area for the question text
      expect(html.css('textarea[name="question[1][txt]"]')).not_to be_empty
      # Test for presence of an input for the question weight
      expect(html.css('input[name="question_weights[1][txt]"]')).not_to be_empty
      # Test for the correct number of choices
      expect(html.css('input[type="radio"][name^="quiz_question_choices[1][TrueFalse]"]').size).to eq(2)
    end
  end
  describe "#isvalid" do
    context "when the question does not have text" do
      it 'returns "Please make sure all questions have text"' do
        allow(true_false).to receive(:txt).and_return("")
        questions = { "1" => { txt: "question text", iscorrect: true }, "2" => { txt: "question text", iscorrect: false } }
        expect(true_false.isvalid(questions)).to eq("Please make sure all questions have text")
      end
    end
    context "when the choice does not have text" do
      it 'returns "Please make sure every question has text for all options"' do
        allow(true_false).to receive(:txt).and_return("Text")
        questions = { "1" => { txt: "", iscorrect: true }, "2" => { txt: "question text", iscorrect: false } }
        expect(true_false.isvalid(questions)).to eq("Please make sure every question has text for all options")
      end
    end
    context "when no right answer was selected" do
      it 'returns "Please select a correct answer for all questions"' do
        allow(true_false).to receive(:txt).and_return("Text")
        questions = { "1" => { txt: "question text", iscorrect: false }, "2" => { txt: "question text", iscorrect: false } }
        expect(true_false.isvalid(questions)).to eq("Please select a correct answer for all questions")
      end
    end
  end
  describe "#get_formatted_question_type" do
    it 'returns "True/False"' do
      expect(true_false.get_formatted_question_type).to eq("True/False")
    end
  end
end
