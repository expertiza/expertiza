describe 'Review Report View' do
    before(:each) do
        assignment = create(:assignment)
        create_list(:participant, 3) 
        create(:assignment_node) 
        create(:assignment_team) 
        create(:assignment_team_node) 
        teams = create_list(:team, 5, assignment: assignment) 
  
    end
  
    describe '#search_team' do
      it 'uses search functionality appropriately' do
    
        response_maps = create_response_maps
        visit "/reports/response_report?class=form-inline&id=#{assignment.id}"
        fill_in 'team-search', with: teams.first.name
        click_button 'Search'
        expect(page).to have_css('table#myTable tbody tr', count: 1)
        expect(page).to have_content(teams.first.name)
      end
    end
end