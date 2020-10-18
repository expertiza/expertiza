include InstructorInterfaceHelperSpec

describe "Student_task, list page" do
  before(:each) do
    # course_setup
    assignment_setup
  end

  describe "Instructor login at student_task, list page" do
    it "has current contents" do
      login_as("instructor6")
      visit '/menu/student_task'
      expect(page).to have_content("Assignments")
      expect(page).to have_no_content("badge")
      expect(page).to have_no_content("Review Grade")
      expect(page). to have_content("assignment")

    end


  end
end