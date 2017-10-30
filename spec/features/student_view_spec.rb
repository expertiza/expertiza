describe "Student View for instructor interface" do
  describe "Instructor login" do
    it "with valid username and password" do
      login_as("instructor6")
      visit '/tree_display/list'
      expect(page).to have_content("Student View")
    end
  end

  describe "Switching to student view" do
    it "is able to switch to student view" do
      login_as("instructor6")
      visit '/student_view/set'
      expect(page).to have_content("Revert to Instructor View")
    end
  end

  describe "Reverting to instructor view" do
    it "is able to switch back to instructor view" do
      login_as("instructor6")
      visit '/student_view/set'
      expect(page).to have_content("Revert to Instructor View")
      visit '/student_view/revert'
      expect(page).to have_content("Manage")
    end
  end
end
