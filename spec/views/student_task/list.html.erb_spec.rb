include InstructorInterfaceHelperSpec

describe "Integration tests for instructor's assignment page" do
  before(:each) do
    assignment_setup
  end

  describe "Instructor login" do
    it "with valid username and password" do
      login_as("instructor6")
      visit '/menu/student_task'
      expect(page).to have_content("Assignments")
      expect(page).to have_content("CSC 517 Fall 2009")
    end


  end
end