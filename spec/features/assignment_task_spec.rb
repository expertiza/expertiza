describe "student_task test" do

    it "with valid username and password" do
      user = User.find_by_login(name: "instructor6")
      login_as(user.name)
      stub_current_user(user, user.role.name, user.role)
      visit '/student_task/list'

      numberOfTables = student.course.length
      puts "Number Of Tables: " + numberOfTables.to_s
      expect(page).to have_css('table', count: numberOfTables*2)
    end
end