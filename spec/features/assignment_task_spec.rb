describe "student_task test" do

    it "with valid username and password" do
      user_name = 'student2066'
      user = User.find_by(name: user_name)
      msg = user.to_yaml
      File.open('log/diagnostic.txt', 'a') {|f| f.write msg }

      visit root_path
      fill_in 'login_name', with: user_name
      fill_in 'login_password', with: 'password'
      click_button 'Sign in'
      stub_current_user(user, user.role.name, user.role)

      visit '/student_task/list'

      numberOfTables = user.course.length
      puts "Number Of Tables: " + numberOfTables.to_s
      expect(page).to have_css('table', count: numberOfTables*2)
    end
end
