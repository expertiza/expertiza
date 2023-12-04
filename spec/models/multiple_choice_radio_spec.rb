describe MultipleChoiceRadio do
  let(:multiple_choice_radio) { build(:multiple_choice_radio, id: 1) }
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
end
