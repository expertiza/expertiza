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
end
