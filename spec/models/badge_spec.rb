describe Badge do
  let(:awarded_badge) { build(:awarded_badge) }
  before(:all) do
    allow(Badge).to receive(:find_by).and_return(awarded_badge)
    allow(awarded_badge).to receive(:try).with(:id).and_return(1)
    allow(awarded_badge).to receive(:try).with(:image_name).and_return('image_name')	
  end
  describe '#get_id_from_name' do
    it 'returns the badge id from the name' do
      expect(Badge.get_id_from_name('assignment_badge')).to eq(1)
    end
  end
  describe '#get_image_name_from_name' do
    it 'returns the badge id from the name' do
      expect(Badge.get_image_name_from_name('assignment_badge')).to eq('image_name')
    end
  end
end