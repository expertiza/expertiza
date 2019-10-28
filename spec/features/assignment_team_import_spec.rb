include InstructorInterfaceHelperSpec

describe "create team by importing file" do
  before(:each) do
    assignment_setup
  end


  describe "import file" do

    it "is able to create team by importing a file" do
      login_as('instructor6')
      instructor = User.where(name: 'instructor6').first
      assignment = Assignment.where(instructor_id: instructor.id).first
      visit "/teams/list?id=#{assignment.id}&type=Assignment"
      click_link 'Import Teams'
      expect(page).to have_content('Import AssignmentTeam List')
      file_path = Rails.root + "spec/features/upload_teams.txt"
      attach_file('file', file_path)
      expect(find_field('file').value).to_not eq(nil)
      click_button 'Import'
      expect(page).to have_content('Importing from')
      click_button 'Import Teams'
      expect(page).to have_content('team1')
      expect(page).to have_content('team2')

    end
  end
end
