describe Invitation do
	let(:user2) { build(:student, id: 2) }
  let(:user3) { build(:student, id: 3) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }

  it { should belong_to :to_user }
  it { should belong_to :from_user }

  describe '#is_invited?' do
  	context 'an invitation has been sent between user1 and user2' do
  		it 'returns false' do
  			allow(Invitation).to receive(:where).with('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                       user2.id, user3.id, assignment.id).and_return([Invitation.new])
  			expect(Invitation.is_invited?(user2.id, user3.id, assignment.id)).to eq(false)
  		end
  	end
  	context 'an invitation has not been sent between user1 and user2' do
  		it 'returns true' do
  			allow(Invitation).to receive(:where).with('from_id = ? and to_id = ? and assignment_id = ? and reply_status = "W"',
                                       user2.id, user3.id, assignment.id).and_return([])
  			expect(Invitation.is_invited?(user2.id, user3.id, assignment.id)).to eq(true)
  		end
  	end
  end

  describe '#accept_invite' do
  	context 'a user is not on a team and wishes to join a team with open slots' do
  		it 'puts the user on a team and returns true' do
  			team_id = 0
  			allow(TeamsUser).to receive(:is_team_empty).with(team_id).and_return(false)
  			allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
  			allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(true)
  			allow(Invitation).to receive(:update_users_topic_after_invite_accept).with(user2.id, user3.id, assignment.id).and_return(true)
  			expect(Invitation.accept_invite(team_id, user2.id, user3.id, assignment.id)).to eq(true)
  		end
  	end
  	context 'a user is on a team and wishes to join a team with open slots' do
  		it 'removes the user from their previous team, puts the user on a team, and returns true' do
  			team_id = 1
  			allow(TeamsUser).to receive(:is_team_empty).with(team_id).and_return(true)
  			allow(AssignmentTeam).to receive(:find).with(team_id).and_return(team)
  			allow(team).to receive(:assignment).and_return(assignment) 
  			allow(SignedUpTeam).to receive(:release_topics_selected_by_team_for_assignment).with(team_id, assignment.id).and_return(true)
  			allow(AssignmentTeam).to receive(:remove_team_by_id).with(team_id).and_return(true)
  			allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
  			allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(true)
  			allow(Invitation).to receive(:update_users_topic_after_invite_accept).with(user2.id, user3.id, assignment.id).and_return(true)
  			expect(Invitation.accept_invite(team_id, user2.id, user3.id, assignment.id)).to eq(true)
  		end
  	end
  	context 'a user is on a team and wishes to join a team without slots' do
  		it 'removes the user from their previous team, and returns false' do
  			team_id = 1
  			allow(TeamsUser).to receive(:is_team_empty).with(team_id).and_return(true)
  			allow(AssignmentTeam).to receive(:find).with(team_id).and_return(team)
  			allow(team).to receive(:assignment).and_return(assignment) 
  			allow(SignedUpTeam).to receive(:release_topics_selected_by_team_for_assignment).with(team_id, assignment.id).and_return(true)
  			allow(AssignmentTeam).to receive(:remove_team_by_id).with(team_id).and_return(true)
  			allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
  			allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(false)
  			expect(Invitation.accept_invite(team_id, user2.id, user3.id, assignment.id)).to eq(false)
  		end
  	end
  	context 'a user is not on a team and wishes to join a team without slots' do
  		it 'returns false' do
  			team_id = 0
  			allow(TeamsUser).to receive(:is_team_empty).with(team_id).and_return(false)
  			allow(Invitation).to receive(:remove_users_sent_invites_for_assignment).with(user3.id, assignment.id).and_return(true)
  			allow(TeamsUser).to receive(:add_member_to_invited_team).with(user2.id, user3.id, assignment.id).and_return(false)
  			expect(Invitation.accept_invite(team_id, user2.id, user3.id, assignment.id)).to eq(false)
  		end
  	end
  end

  describe '#remove_users_sent_invites_for_assignment' do
  	it 'deletes the invitations sent for a given assignment' do
  		allow(Invitation).to receive(:where).with('from_id = ? and assignment_id = ?', user2.id, assignment.id).and_return([Invitation.new, Invitation.new])
  		expect(Invitation.remove_users_sent_invites_for_assignment(user2.id, assignment.id)).to eq([]) 
  	end
  end
end