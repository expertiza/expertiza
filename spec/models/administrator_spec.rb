describe Administrator do
  describe 'class' do
    it 'creates a valid object' do
      expect(Administrator.new).to be_valid
    end
  end
end