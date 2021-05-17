describe Dropdown do
	let(:dropdown) {build(:dropdown, id: 1)}
  describe '#view_question_text' do
    it 'returns the html' do
      html = dropdown.view_question_text
      expect(html).to eq('')
    end
  end
end