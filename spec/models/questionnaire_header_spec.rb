describe QuestionnaireHeader do
  let(:itemnaire_header) { build(:itemnaire_header) }
  describe '#view_item_text' do
    it 'returns the html' do
      expect(itemnaire_header.view_item_text).to eq('<TR><TD align="left"> Test item: </TD><TD align="left">QuestionnaireHeader</TD><td align="center">1</TD><TD align="center">&mdash;</TD></TR>')
    end
  end
  describe '#complete' do
    it 'returns the text' do
      expect(itemnaire_header.complete).to eq('Test item:')
    end
  end
end
