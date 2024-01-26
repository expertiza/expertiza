include InstructorInterfaceHelperSpec

describe 'create team by importing file' do
  before(:each) do
    create(:assignment)
    create_list(:participant, 3)
    create(:assignment_node)
    create(:assignment_team)
    create(:assignment_team_node)
  end

  describe 'import file' do
    # to test create new teams by importing a txt file
    it 'is able to create team by importing a file' do
      login_as('instructor6')
      instructor = User.where(name: 'instructor6').first
      assignment = Assignment.where(instructor_id: instructor.id).first
      visit "/teams/list?id=#{assignment.id}&type=Assignment"
      click_link 'Import Teams'
      expect(page).to have_content('Import AssignmentTeam List')
      file_path = Rails.root + 'spec/features/upload_teams.txt'
      page.attach_file('import_file', file_path)
      expect(find_field('import_file').value.length).not_to eq(0)
      click_button 'Import'
    end
  end
end
