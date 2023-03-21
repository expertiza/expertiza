describe 'add assignment team member test' do
  before(:each) do
    create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    create(:assignment_team)
    create(:assignment_team_node)
  end

  describe '#add_participant' do
    # to test adding a assignment participant to an assignment team that exist and not full
    it 'is able to add a member to an assignment team' do
      login_as('instructor6')
      assignment = Assignment.first
      team = AssignmentTeam.first
      user = AssignmentParticipant.first
      visit "/teams/list?id=#{assignment.id}&type=Assignment"
      visit "/teams_users/new?id=#{team.id}"
      fill_in 'user_name', with: user.name
      click_button 'Add'
      expect(team.participants).to include(user)
    end
  end
end
