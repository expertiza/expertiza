describe Dropdown do
	let(:dropdown) {build(:dropdown, id: 1)}
	let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1, type: "Criterion") }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, comments: "test comment", response_id: 1) }
  describe '#view_question_text' do
    it 'returns the html' do
      html = dropdown.view_question_text
      expect(html).to eq('<TR><TD align=\"left\"> Test question: </TD><TD align=\"left\">TrueFalse</TD><td align=\"center\">1</TD><TD align=\"center\">&mdash;</TD></TR>')
    end
  end
  describe '#view_completed_question' do
    it 'returns the html' do
      html = dropdown.view_completed_question(1, answer)
      expect(html).to eq('')
    end
  end
end