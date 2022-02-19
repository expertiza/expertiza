describe Dropdown do
  let(:dropdown) { build(:dropdown, id: 1) }
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1, type: 'Criterion') }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, comments: 'Alternative 1', response_id: 1) }
  describe '#view_question_text' do
    it 'returns the html' do
      html = dropdown.view_question_text
      expect(html).to eq('<TR><TD align="left"> Test question: </TD><TD align="left">TrueFalse</TD><td align="center">1</TD><TD align="center">&mdash;</TD></TR>')
    end
  end
  describe '#view_completed_question' do
    it 'returns the html' do
      html = dropdown.view_completed_question(1, answer)
      expect(html).to eq('<b>1. Test question:</b><BR>&nbsp&nbsp&nbsp&nbspAlternative 1')
    end
  end
  describe '#complete_for_alternatives' do
    it 'returns the html' do
      alternatives = ['Alternative 1', 'Alternative 2', 'Alternative 3']
      html = dropdown.complete_for_alternatives(alternatives, answer)
      expect(html).to eq('<option value="Alternative 1" selected>Alternative 1</option><option value="Alternative 2">Alternative 2</option><option value="Alternative 3">Alternative 3</option>')
    end
  end
  describe '#complete' do
    it 'returns the html' do
      alternatives = ['Alternative 1|Alternative 2|Alternative 3']
      allow(dropdown).to receive(:alternatives).and_return(alternatives)
      allow(dropdown).to receive(:complete_for_alternatives).and_return('')
      html = dropdown.complete(1, answer)
      expect(html).to eq('<p style="width: 80%;"><label for="responses_1"">Test question:&nbsp;&nbsp;</label><input id="responses_1_score" name="responses[1][score]" type="hidden" value="" style="min-width: 100px;"><select id="responses_1_comments" label=Test question: name="responses[1][comment]"></select></p>')
    end
  end
end
