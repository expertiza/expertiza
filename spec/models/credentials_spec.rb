describe Credentials do
  let(:role) { build(:role_of_student) }
  describe '#initialize' do
    it 'sets instance variables' do
      cred = Credentials.new(1)
      allow(Role).to receive(:find).with(1).and_return(role)
      allow(role).to receive(:get_parents).and_return(:role)
      allow(role).to receive(:id).and_return(1)
      expect(cred.role_id).to eq(1)
    end
  end
end
