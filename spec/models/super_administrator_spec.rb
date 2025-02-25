describe SuperAdministrator do
  let(:user1) { User.new username: 'abc', name: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:user2) { User.new username: 'abc', name: 'abc bbc', email: 'abcbbe@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:superadmin) { build(:superadmin) }
  describe '#get_user_list' do
    it 'should return a list of all users in the system' do
      obj = [user1, user2]
      allow(User).to receive(:all).and_return(obj)
      expect(obj).to receive(:find_each).and_yield(obj.first).and_yield(obj.last)
      expect(superadmin.get_user_list).to eq(obj)
    end
  end
end
