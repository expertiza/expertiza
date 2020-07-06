describe 'UploadFile' do
  let(:uf) { UploadFile.new id: 1, type: 'UploadFile', seq: 1.0, txt: 'test txt', weight: 1 }

  describe '#edit' do
    it 'returns an html_safe string to be rendered' do
      expect(uf.edit(0).html_safe?).to be_truthy
    end
  end

  describe '#view_question_text' do
    it 'returns an html_safe string to be rendered' do
      expect(uf.view_question_text.html_safe?).to be_truthy
    end
  end
end
