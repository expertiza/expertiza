require 'rspec'

describe 'new account request' do

  before(:each) do
    create(:role_of_student)
    create(:role_of_administrator)
    create(:role_of_instructor)
    create(:role_of_teaching_assistant)
    create(:admin, name: 'super_administrator2')
    create(:institution)
    create(:studentx)
    create(:requested_user)
  end
  context 'account request' do
    it 'request with new institution successfully' do
      visit '/'
      click_link 'REQUEST ACCOUNT'
      expect(page).to have_content('Request new user')
      select 'Instructor', from: 'user_role_id'
      fill_in 'user_name', with: 'yzhan'
      fill_in 'user_fullname', with: 'yzhang'
      fill_in 'user_email', with: 'yzhang@hnu.edu'
      select 'Not List', from: 'user_institution_id'
      fill_in 'institution_name', with: 'HNU'
      fill_in 'requested_user_intro', with: 'university from China'
      click_on 'Request'
      expect(page).to have_content('successfully requested')
    end

    it 'request with existed institution' do
      visit '/'
      click_link 'REQUEST ACCOUNT'
      expect(page).to have_content('Request new user')
      select 'Teaching Assistant', from: 'user_role_id'
      fill_in 'user_name', with: 'yzhan'
      fill_in 'user_fullname', with: 'yzhang'
      fill_in 'user_email', with: 'yzhang@ncsu.edu'
      select 'North Carolina State University', from: 'user_institution_id'
      fill_in 'requested_user_intro', with: 'new ta from NCSU'
      click_on 'Request'
      expect(page).to have_content('successfully requested')
    end

    it 'fail to request with existed user name' do
      visit '/'
      click_link 'REQUEST ACCOUNT'
      expect(page).to have_content('Request new user')
      select 'Teaching Assistant', from: 'user_role_id'
      fill_in 'user_name', with: 'studentx'
      fill_in 'user_fullname', with: 'yzhang'
      fill_in 'user_email', with: 'yzhang@ncsu.edu'
      select 'North Carolina State University', from: 'user_institution_id'
      fill_in 'requested_user_intro', with: 'new ta from NCSU'
      click_on 'Request'
      expect(page).to have_content('The account you are requesting has already existed in Expertiza.')
    end

    it 'fail to request with existed requested_user email' do
      visit '/'
      click_link 'REQUEST ACCOUNT'
      expect(page).to have_content('Request new user')
      select 'Teaching Assistant', from: 'user_role_id'
      fill_in 'user_name', with: 'whatever'
      fill_in 'user_fullname', with: 'whatever'
      fill_in 'user_email', with: 'rq@ncsu.edu'
      select 'North Carolina State University', from: 'user_institution_id'
      fill_in 'requested_user_intro', with: 'request an account for expertiza'
      click_on 'Request'
      expect(page).to have_content('Email has already been taken')
    end

  end


  context 'on users#list_pending_requested page' do

    before (:each) do
      create(:requester, name: 'requester1', email: 'requestor1@gmail.com')
    end

    it 'allows super-admin and admin to communicate with requesters by clicking email addresses' do
      visit '/'
      login_as 'super_administrator2'
      visit '/users/list_pending_requested'
      expect(page).to have_content('requestor1@gmail.com')
      expect(page).to have_link('requestor1@gmail.com')
    end


    context 'when super-admin or admin rejects a requester' do
      it 'displays \'Rejected\' as status' do
        visit '/'
        login_as 'super_administrator2'
        visit '/users/list_pending_requested'
        expect(page).to have_content('requested_user')
        all('input[id="2"]').first.click
        #choose(name: 'status',option:'Rejected')
        all('input[value="Submit"]').first.click
        expect(page).to have_content('The user "requested_user" has been Rejected.')
        expect(RequestedUser.first.status).to eq('Rejected')
        # expect(page).to have_content('studentx')
        # expect(page).to have_content('Rejected')
      end
    end


    context 'when super-admin or admin accepts a requester' do
      it 'displays \'Accept\' as status and sends an email with randomly-generated password to the new user' do

        visit '/'
        login_as 'super_administrator2'
        visit '/users/list_pending_requested'
        ActionMailer::Base.deliveries.clear
        expect(page).to have_content('requester1')
        all('input[id="1"]')[1].click
        #choose(name: 'status',option:'Rejected')
        all('input[value="Submit"]')[1].click
        #choose(name: 'status', option:'Approved',allow_label_click: true)
        #click_on('Submit')
        expect(page).to have_content('requester1')
        # the size of mailing queue changes by 1
        expect{
          requester1 = User.find_by_name('studentx')
          prepare = MailerHelper.send_to_user(requester1,'Your Expertiza account and password have been created.',"user_welcome",'password1234')
          prepare.deliver_now
        }.to change{ ActionMailer::Base.deliveries.count }.by(1)
      end

      context 'using name as username and password in the email' do
        it 'allows the new user to login Expertiza' do
          create(:student, name: 'approved_requster1', password: "password")
          visit '/'
          fill_in 'login_name', with: 'approved_requster1'
          fill_in 'login_password', with: 'password'
          click_button 'SIGN IN'
          expect(page).to have_current_path("/student_task/list")
        end
      end

    end

  end

end

