include InstructorInterfaceHelperSpec

describe "Integration tests for student interface" do
  let(:student2064) { build(:student, id: 10, role_id: 1, parent_id: nil) }

  describe "Student login" do
    it "with valid username and password" do
      student = create(:student)
      login_as(student.name)
      visit '/student_task/list'
      expect(page).to have_content("Assignments")
    end

    it "with invalid username and password" do
      visit root_path
      fill_in 'login_name', with: 'student2064'
      fill_in 'login_password', with: 'something'
      click_button 'Sign in'
      expect(page).to have_text('Your username or password is incorrect.')
    end
  end

  describe "Anonymized view tab exists in the menu" do
    it "with valid username and password" do
      student = create(:student)
      login_as(student.name)
      visit '/student_task/list'
      expect(page).to have_content("Anonymized view")
    end
  end
end
