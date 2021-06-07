describe TextArea do
  let(:text_area) {create(:text_area)}
  describe '#complete' do
    context 'when the size is nil' do
      it 'uses a default size and returns html' do
        allow(text_area).to receive(:size).and_return(nil)
        html = text_area.complete(1,nil)
        expect(html).to eq('')
      end
    end
    context 'when the size is set' do
      it 'uses that size and returns html' do
        allow(text_area).to receive(:size).and_return('1,1')
        html = text_area.complete(1,nil)
        expect(html).to eq('')
      end
    end
  end
end