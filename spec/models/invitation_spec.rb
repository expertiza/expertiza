describe Invitation do
	let(:user2) { build(:student, id: 2) }
  let(:user3) { build(:student, id: 3) }
  let(:assignment) { build(:assignment, id: 1) }

  it { should belong_to :to_user }
  it { should belong_to :from_user }

  describe '#is_invited?' do
  	context 'an invitation has been sent between user1 and user2' do
  		it 'returns true' do
  			allow(Invitation).to receive(:where).with('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                       user2.id, user3.id, assignment.id).and_return([Invitation.new])
  			expect(Invitation.is_invited?(user2.id, user3.id, assignment.id)).to eq(true)
  		end
  	end
  	context 'an invitation has not been sent between user1 and user2' do
  		it 'returns false' do
  			allow(Invitation).to receive(:where).with('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                       user2.id, user3.id, assignment.id).and_return([nil])
  			expect(Invitation.is_invited?(user2.id, user3.id, assignment.id)).to eq(false)
  		end
  	end
  end
end