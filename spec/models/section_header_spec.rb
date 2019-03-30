describe 'SectionHeader' do
  let(:sh) { SectionHeader.new }

  describe '#complete' do
    it 'returns an html_safe string to be rendered' do
      expect(sh.complete(0).html_safe?).to be_truthy
    end
  end

  describe '#view_completed_question' do
    it 'returns an html_safe string to be rendered' do
      expect(sh.view_completed_question(0, 0).html_safe?).to be_truthy
    end
  end
end
