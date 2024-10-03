describe 'Submissions View' do
    before(:each) do
      @assignment = create(:assignment)
      create_list(:participant, 3)
      create(:assignment_node)
      create(:assignment_team)
      create(:assignment_team_node)
      @teams = create_list(:team, 5, assignment: @assignment)
    end
  
    describe '#search_team_team_member' do
      it 'use search functionality appropriately' do
        login_as('instructor6')
        assignment = Assignment.first
        team = AssignmentTeam.first
        user = AssignmentParticipant.first
        visit "/assignments/list_submissions?id=#{assignment.id}"
        fill_in 'searchTeamName', with: team.name
        fill_in 'searchTeamMembers', with: participant.name
        expect(page).to have_css('table#submissionsTable tbody tr', count: 1) 
        expect(page).to have_content(team.name) 
        expect(page).to have_content(participant.name)
      end
    end
end
  
