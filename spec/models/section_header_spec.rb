describe SectionHeader do
  let(:section_header) { build(:section_header) }
  describe '#complete' do
    it 'returns html' do
      html = section_header.complete(1)
      expect(html).to eq('<b style="color: #986633; font-size: x-large">Test item:</b><br/><br/>')
    end
  end
  describe '#view_completed_item' do
    it 'returns html' do
      html = section_header.view_completed_item(1, nil)
      expect(html).to eq('<b style="color: #986633; font-size: x-large">Test item:</b>')
    end
  end
end
