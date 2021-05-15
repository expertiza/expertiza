describe MultipleChoiceCheckbox do
  let(:multiple_choice_checkbox) { build(:multiple_choice_checkbox, id: 1)}
  describe '#edit' do
    it 'returns the html' do
      qc = double('QuizQuestionChoice')
      allow(QuizQuestionChoice).to receive(:where).with(question_id: 1).and_return([qc, qc, qc, qc])
      expect(multiple_choice_checkbox.edit).to eq('')
    end
  end
end