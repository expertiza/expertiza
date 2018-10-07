describe Menu do
  let(:menu1) { double(:menu) }
  describe '#initialize' do
    it 'sets parent to nil' do
      expect(menu1.initialize).parent.to eq(nil)
    end
  end

end