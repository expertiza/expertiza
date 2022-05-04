describe 'new user request' do
  before(:each) do
    # create(:role_of_student)
    # create(:role_of_instructor)
    # create(:role_of_administrator)
    # create(:role_of_teaching_assistant)
    create(:admin, name: 'super_administrator2')
    create(:institution)
  end

  context 'on users#list_pending_requested page' do
    before(:each) { create(:requested_user) }

    it 'allows super-admin and admin to communicate with requesters by clicking email addresses' do
      visit '/'
      login_as 'super_administrator2'
      visit '/account_request/list_pending_requested'
      expect(page).to have_link('requester1@test.com')
    end

    context 'when super-admin or admin accepts a requester' do
      context 'using name as username and password in the email' do
        it 'allows the new user to login Expertiza' do
          create(:student, name: 'approved_requster1', password: 'password')
          visit '/'
          fill_in 'login_name', with: 'approved_requster1'
          fill_in 'login_password', with: 'password'
          click_button 'Sign in'
          expect(page).to have_current_path('/student_task/list')
        end
      end
    end
  end
end
