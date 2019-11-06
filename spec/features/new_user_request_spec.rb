describe 'new user request' do
  before(:each) do
    create(:role_of_student)
    create(:role_of_instructor)
    create(:role_of_administrator)
    create(:role_of_teaching_assistant)
    create(:admin, name: 'super_administrator2')
    create(:institution)
  end

  context 'request account feature' do
    it 'works correctly', js: true do
      # click 'REQUEST ACCOUNT' button on root path, redirect to users#request_new page
      visit '/'
      click_link 'Request account'
      expect(page).to have_current_path('/users/request_new?role=Instructor')
      select 'Instructor', from: 'user_role_id'
      fill_in 'user_name', with: 'requester'
      fill_in 'user_fullname', with: 'requester, requester'
      # a new user is able to add a new institution
      select 'Other', from: 'user_institution_id'
      expect(page).to have_field("institution_name")
      fill_in 'institution_name', with: 'Xavier Institute for Mutant Education and Outreach'
      # a new user is able to write a brief introduction
      expect(page).to have_field('requested_user_self_introduction')
      fill_in 'requested_user_self_introduction', with: 'The Xavier\'s School for Gifted Youngsters is a special
        institute founded and led by Professor Charles Xavier to train young mutants in controlling their powers
        and help foster a friendly human-mutant relationship.'
      # if the email address of a new user is not valid, the flash message should display the corresponding messages
      fill_in 'user_email', with: 'test.com'
      click_on 'Request'
      expect(page).to have_content('Email format is wrong')
      # all data can be saved to DB successfully
      select 'Instructor', from: 'user_role_id'
      select 'North Carolina State University', from: 'user_institution_id'
      fill_in 'user_name', with: 'requester'
      fill_in 'user_fullname', with: 'requester, requester'
      fill_in 'user_email', with: 'test@test.com'
      expect { click_on 'Request' }.to change { RequestedUser.count }.by(1)
      expect(RequestedUser.first.name).to eq('requester')
      expect(RequestedUser.first.role_id).to eq(2)
      expect(RequestedUser.first.fullname).to eq('requester, requester')
      expect(RequestedUser.first.email).to eq('test@test.com')
      expect(RequestedUser.first.status).to eq('Under Review')
    end
  end

  context 'on users#list_pending_requested page' do
    before(:each) { create(:requested_user) }

    it 'allows super-admin and admin to communicate with requesters by clicking email addresses' do
      visit '/'
      login_as 'super_administrator2'
      visit '/users/list_pending_requested'
      expect(page).to have_link('requester1@test.com')
    end

    context 'when super-admin or admin rejects a requester' do
      it 'displays \'Rejected\' as status' do
        visit '/'
        login_as 'super_administrator2'
        visit '/users/list_pending_requested'
        expect(page).to have_content('requester1')
        choose(name: 'status', option: 'Rejected')
        click_on('Submit')
        expect(page).to have_content('The user "requester1" has been Rejected.')
        expect(RequestedUser.first.status).to eq('Rejected')
        expect(page).to have_content('requester1')
        expect(page).to have_content('Rejected')
      end
    end

    context 'when super-admin or admin accepts a requester' do
      it 'displays \'Accept\' as status and sends an email with randomly-generated password to the new user' do
        visit '/'
        login_as 'super_administrator2'
        visit '/users/list_pending_requested'
        ActionMailer::Base.deliveries.clear
        expect(page).to have_content('requester1')
        expect(RequestedUser.first.status).to eq('Under Review')
        choose(name: 'status', option: 'Approved')
        click_on('Submit')
        expect(page).to have_content('requester1')
        # the size of mailing queue changes by 1
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.subject).to eq("Your Expertiza account and password has been created")
        expect(ActionMailer::Base.deliveries.first.to).to eq(["expertiza.development@gmail.com"])
      end

      context 'using name as username and password in the email' do
        it 'allows the new user to login Expertiza' do
          create(:student, name: 'approved_requster1', password: "password")
          visit '/'
          fill_in 'login_name', with: 'approved_requster1'
          fill_in 'login_password', with: 'password'
          click_button 'Sign in'
          expect(page).to have_current_path("/student_task/list")
        end
      end
    end
  end
end