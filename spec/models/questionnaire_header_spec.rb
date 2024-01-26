describe QuestionnaireHeader do
  let(:questionnaire_header) { build(:questionnaire_header) }
  describe '#view_question_text' do
    it 'returns the html' do
      expect(questionnaire_header.view_question_text).to eq('<TR><TD align="left"> Test question: </TD><TD align="left">QuestionnaireHeader</TD><td align="center">1</TD><TD align="center">&mdash;</TD></TR>')
    end
  end
  describe '#complete' do
    it 'returns the text' do
      expect(questionnaire_header.complete).to eq('Test question:')
    end
  end
end
