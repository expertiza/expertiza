include InstructorInterfaceHelperSpec

describe "Edit rubric advice" do
  before(:each) do
    assignment_setup
  end
  describe "Instructor login" do
    it "with valid username and password" do
      login_as("instructor6")
      visit '/tree_display/list'
      expect(page).to have_content("Manage content")
    end
    # # it "accepts changes to rubric advice" do
    #   login_as("instructor6")
    #   visit '/questionnaires/115/edit'
    #   expect(page).to have_content "Edit Review"
    # end
  end
end
