describe 'enter student view and see the proper tabs' do

    it 'is redirected to "/student_task/list"' do
        # 1. create data for test
        instructor6 = create(:instructor)   #create instructor6

        # 2. log in as instructor6 and see Student View button
        visit(root_path)
        fill_in('login_name', with: 'instructor6')
        fill_in('login_password', with: 'password')
        click_button('Sign in')
        expect(current_path).to eql("/tree_display/list")
        expect(page).to have_content('Student View')

        # 3. click Student View button and see student tabs and instructor view
        click_link_or_button("Student View")
        expect(page).to have_content("Home")
        expect(page).to have_content("Assignments")
        expect(page).to have_content("Anonymized View")
        expect(page).to have_content("Pending Surveys")
        expect(page).to have_content("Profile")
        expect(page).to have_content("Contact Us")
        expect(page).to have_content("Instructor View")
       
        # 3. navigate to assignment page and ensure tabs are still there
        visit('/student_task/list')
        expect(page).to have_content("Home")
        expect(page).to have_content("Assignments")
        expect(page).to have_content("Anonymized view")
        expect(page).to have_content("Pending Surveys")
        expect(page).to have_content("Profile")
        expect(page).to have_content("Contact Us")
        expect(page).to have_content("Instructor View")

        # 4. click Instructor View and ensure instructor tabs return
        click_link_or_button("Instructor View")
        expect(page).to have_content("Home")
        expect(page).to have_content("Manage...")
        expect(page).to have_content("Survey")
        expect(page).to have_content("Assignments")
        expect(page).to have_content("Course Evaluation")
        expect(page).to have_content("Profile")
        expect(page).to have_content("Contact Us")
        expect(page).to have_content("Anonymized view")

    end

end