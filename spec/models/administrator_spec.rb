describe Administrator do
  describe 'class' do
    it 'creates a valid object' do
      expect(Administrator.new(username: 'name', fullname: 'John Bumgardner', email: 'email@email.com')).to be_valid
    end
  end
end
