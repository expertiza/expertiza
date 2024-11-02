describe VmUserAnswerTagging do
  let(:user1) { User.new username: 'abc', name: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  describe '#initialize' do
    it 'sets the instance variables' do
      vm_user_answer_tagging = VmUserAnswerTagging.new(user1, 75, true, true, true, '3000-01-31')
      expect(vm_user_answer_tagging.user).to eq(user1)
      expect(vm_user_answer_tagging.percentage).to eq(75)
      expect(vm_user_answer_tagging.no_tagged).to eq(true)
      expect(vm_user_answer_tagging.no_not_tagged).to eq(true)
      expect(vm_user_answer_tagging.no_tagable).to eq(true)
      expect(vm_user_answer_tagging.tag_update_intervals).to eq('3000-01-31')
    end
  end
end
