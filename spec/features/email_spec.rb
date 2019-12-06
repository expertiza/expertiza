require 'rails_helper'

RSpec.feature 'Password Reset', type: :feature do
  fixtures :users
  describe 'Reset Password' do
    scenario 'Email not associated with any account' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      click_link 'Forgot password?'
      expect(page).to have_current_path('/password_retrieval/forgotten')
      fill_in 'user_email', with: 'expertiza@mailinator.com'
      expect{click_button 'Request password'}.to change{ActionMailer::Base.deliveries.count}.by(0)
    end

    context 'Email associated with some account' do
      it 'email count should be 1' do
        ActionMailer::Base.deliveries.clear
        visit '/'
        click_link 'Forgot password?'
        expect(page).to have_current_path('/password_retrieval/forgotten')
        fill_in 'user_email', with: 'user1@mailinator.com'
        expect{click_button 'Request password'}.to change{ActionMailer::Base.deliveries.count}.by(1)
      end

      it 'tests email sender' do
        ActionMailer::Base.deliveries.clear
        visit '/'
        click_link 'Forgot password?'
        expect(page).to have_current_path('/password_retrieval/forgotten')
        fill_in 'user_email', with: 'user1@mailinator.com'
        click_button 'Request password'
        mail = ActionMailer::Base.deliveries.last
        expect(mail.from).to eq(["expertiza.development@gmail.com"])
      end

      it 'tests email recepient' do
        ActionMailer::Base.deliveries.clear
        visit '/'
        click_link 'Forgot password?'
        expect(page).to have_current_path('/password_retrieval/forgotten')
        fill_in 'user_email', with: 'user1@mailinator.com'
        click_button 'Request password'
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq(["expertiza.development@gmail.com"])
      end

      it 'tests email subject' do
        ActionMailer::Base.deliveries.clear
        visit '/'
        click_link 'Forgot password?'
        expect(page).to have_current_path('/password_retrieval/forgotten')
        fill_in 'user_email', with: 'user1@mailinator.com'
        click_button 'Request password'
        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq("Expertiza password reset")
      end
    end
  end
end

RSpec.feature 'User account creation', type: :feature do
  before(:each) do
    create(:role_of_student)
    create(:role_of_instructor)
    create(:role_of_administrator)
    create(:role_of_superadministrator, name: 'super_admin')
    create(:admin, name: 'admin_user')
    create(:admin, name: 'super_administrator2')
    create(:superadmin, name: 'super_user')
    create(:institution)
  end
  describe 'instructor creates new user by filling form' do
    it 'email count should be one' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      login_as 'admin_user'
      visit '/users/list'
      click_link('New User', :match => :first)
      expect(page).to have_content('New user')
      fill_in 'user_name', with: 'teststudent'
      fill_in 'user_fullname', with: 'test student'
      fill_in 'user_email', with: 'test@student.com'
      check('user_email_on_review')
      expect{click_button 'Create'}.to change{ActionMailer::Base.deliveries.count}.by(1)
    end
    it 'tests email subject' do
      visit '/'
      login_as 'admin_user'
      visit '/users/list'
      click_link('New User', :match => :first)
      expect(page).to have_content('New user')
      fill_in 'user_name', with: 'teststudent'
      fill_in 'user_fullname', with: 'test student'
      fill_in 'user_email', with: 'test@student.com'
      check('user_email_on_review')
      click_button 'Create'
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq("Your Expertiza account and password has been created")
    end
    it 'tests email sender' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      login_as 'admin_user'
      visit '/users/list'
      click_link('New User', :match => :first)
      expect(page).to have_content('New user')
      fill_in 'user_name', with: 'teststudent'
      fill_in 'user_fullname', with: 'test student'
      fill_in 'user_email', with: 'test@student.com'
      check('user_email_on_review')
      click_button 'Create'
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq(["expertiza.development@gmail.com"])
    end
    it 'tests email recepient' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      login_as 'admin_user'
      visit '/users/list'
      click_link('New User', :match => :first)
      expect(page).to have_content('New user')
      fill_in 'user_name', with: 'teststudent'
      fill_in 'user_fullname', with: 'test student'
      fill_in 'user_email', with: 'test@student.com'
      check('user_email_on_review')
      click_button 'Create'
      mail = ActionMailer::Base.deliveries.last
      expect(mail.from).to eq(["expertiza.development@gmail.com"])
    end
  end

  describe 'User requests account' do
    it 'no email should be sent if new account requested with invalid email address' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      click_link 'Request account'
      select 'Instructor', from: 'user_role_id'
      fill_in 'user_name', with: 'requester1'
      fill_in 'user_fullname', with: 'requester1, requester1'
      fill_in 'user_email', with: 'test.com'
      select 'North Carolina State University', from: 'user_institution_id'
      expect { click_button 'Request' }.to change{ActionMailer::Base.deliveries.count}.by(0)
    end

    it 'super admin should receive email about new account request with a valid email address' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      click_link 'Request account'
      select 'Instructor', from: 'user_role_id'
      fill_in 'user_name', with: 'requester1'
      fill_in 'user_fullname', with: 'requester1, requester1'
      fill_in 'user_email', with: 'test@mailinator.com'
      select 'North Carolina State University', from: 'user_institution_id'
      expect { click_button 'Request' }.to change{ActionMailer::Base.deliveries.count}.by(1)
    end

    it 'should send an email notification to requester when super admin approves account creation request' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      click_link 'Request account'
      select 'Instructor', from: 'user_role_id'
      fill_in 'user_name', with: 'requester1'
      fill_in 'user_fullname', with: 'requester1, requester1'
      fill_in 'user_email', with: 'test@mailinator.com'
      select 'North Carolina State University', from: 'user_institution_id'
      click_button 'Request'
      visit '/'
      login_as 'super_user'
      visit '/users/list_pending_requested'
      expect(RequestedUser.first.status).to eq('Under Review')
      choose(name: 'status', option: 'Approved')
      expect { click_on('Submit') }.to change{ActionMailer::Base.deliveries.count}.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.from).to eq(["expertiza.development@gmail.com"])
      expect(mail.to).to eq(["expertiza.development@gmail.com"])
      expect(mail.subject).to eq("Your Expertiza account and password has been created")
    end

    it 'should send an email notification to requester when super admin rejects account creation request' do
      ActionMailer::Base.deliveries.clear
      visit '/'
      click_link 'Request account'
      select 'Instructor', from: 'user_role_id'
      fill_in 'user_name', with: 'requester1'
      fill_in 'user_fullname', with: 'requester1, requester1'
      fill_in 'user_email', with: 'test@mailinator.com'
      select 'North Carolina State University', from: 'user_institution_id'
      click_button 'Request'
      visit '/'
      login_as 'super_user'
      visit '/users/list_pending_requested'
      expect(RequestedUser.first.status).to eq('Under Review')
      choose(name: 'status', option: 'Rejected')
      expect { click_on('Submit') }.to change{ActionMailer::Base.deliveries.count}.by(0)
    end
  end

  describe 'User account creation by importing CSV file from user page' do
    it 'for each new user created, email notification should be sent' do
      ActionMailer::Base.deliveries.clear
      visit('/')
      login_as 'admin_user'
      visit("/users/list")
      click_on("Import Users",:match => :first)
      expect(find_field('delim_type_comma')).to be_checked
      expect(find_field('has_header_false')).to be_checked
      #expect(page).to have_selector "Choose File"
      page.attach_file("import_file", Rails.root + "spec/features/CSV_files_user/import_users.csv")
      #find('form input[type = "file"]').set("spec/features/CSV_files_user/import_users.csv")
      click_on('Import')
      expect(page).to have_content('Importing from')
      #expect { click_button('Import Participants') }.to change{ActionMailer::Base.deliveries.count}.by(1)
    end
  end
end



=begin
describe 'scenario 3' do

end

describe 'scenario 4' do

end

describe 'scenario 5' do

end

#this all are for scenario 4: User should receive email notification upon account creation
describe 'send email to new user upon account creation', type: :feature do
  fixtures :users, :assignments, :participants
  it 'on saving user to database, mail should be sent' do
    ActionMailer::Base.deliveries.clear
    test_user = User.new(name: 'abc', fullname: 'abcdef', email: 'abc@gmail.com')
    test_user.id = 123
    test_user.save!
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
  it 'Mail should be sent from the designated email id' do
    ActionMailer::Base.deliveries.clear
    test_user = User.new(name: 'abc', fullname: 'abcdef', email: 'abc@gmail.com')
    test_user.id = 123
    test_user.save!
    mail = ActionMailer::Base.deliveries.last
    expect(mail.from).to eq(["expertiza.development@gmail.com"])
  end
  it 'Mail should be sent from the designated email id' do
    ActionMailer::Base.deliveries.clear
    test_user = User.new(name: 'abc', fullname: 'abcdef', email: 'abc@gmail.com')
    test_user.id = 123
    test_user.save!
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq(["expertiza.development@gmail.com"])
  end
  it 'should be sent out with correct subject' do
    ActionMailer::Base.deliveries.clear
    test_user = User.new(name: 'abc', fullname: 'abcdef', email: 'abc@gmail.com')
    test_user.id = 123
    test_user.save!
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq('Your Expertiza account and password has been created')
  end

  context 'when user account will be created using import file' do
    let(:row) do
      {name: 'username', fullname: 'full name', email: 'abc@mailinator.com'}
    end
    let(:attributes) do
      {role_id: 1, name: 'username', fullname: 'full name', email: 'abc@mailinator.com', email_on_submission: 'abc@mailinator.com', email_on_review: 'abc@mailinator.com', email_on_review_of_review: 'abc@mailinator.com' }
    end
    let(:user1) {User.new name: 'username', fullname: 'full name', email: 'abc@mailinator.com'}

    it 'imports one user and number of mail counnt should be one' do
      ActionMailer::Base.deliveries.clear
      allow(ImportFileHelper).to receive(:define_attributes).with(row).and_return(attributes)
      allow(ImportFileHelper).to receive(:create_new_user) do
        test_user = User.new(name: 'username', fullname: 'full name', email: 'abc@mailinator.com')
        test_user.id = 123
        test_user.save!
        test_user
      end
      allow(User).to receive(:exists?).with(name: 'username').and_return(false)
      expect{(User.import(row, nil, {},1))}.to change{ActionMailer::Base.deliveries.count}.by(1)
    end
  end

  context 'user account will be created by adding them to assignment from CSV file' do
    let(:row) do
      {name: 'username', fullname: 'full name', email: 'abc@mailinator.com', password: 'password'}
    end
    let(:attributes) do
      {role_id: 1, name: 'username', fullname: 'full name', email: 'abc@mailinator.com', email_on_submission: 'abc@mailinator.com', email_on_review: 'abc@mailinator.com', email_on_review_of_review: 'abc@mailinator.com' }
    end
    it 'add user from csv file, email count should be one' do
      ActionMailer::Base.deliveries.clear
      allow(ImportFileHelper).to receive(:define_attributes).with(row).and_return(attributes)
      allow(ImportFileHelper).to receive(:create_new_user) do
        test_user = User.new(name: 'username', fullname: 'full name', email: 'abc@mailinator.com')
        test_user.id = 123
        test_user.save!
        test_user
      end
      allow(participants(:participant1)).to receive(:set_handle).and_return('handle')
      allow(AssignmentParticipant).to receive(:exists?).and_return(false)
      allow(AssignmentParticipant).to receive(:create).and_return(participants(:participant1))
      allow(AssignmentParticipant).to receive(:set_handle)
      expect{(AssignmentParticipant.import(row, nil, {},1))}.to change{ActionMailer::Base.deliveries.count}.by(1)
    end
  end
end

describe UsersController, type: :controller do
  fixtures :requested_users, :users
  let(:user123) {create(:superadmin, id: 3)}
  let(:requesteduser1) {requested_users(:requesteduser1)}
  it 'approve requested user' do
    ActionMailer::Base.deliveries.clear
    session[:user] = user123
    allow(RequestedUser).to receive(:find_by).and_return(requested_users(:requesteduser1))
    allow(requesteduser1).to receive(:update_attributes).and_return(true)
    expect{ post :create_approved_user, {:id =>1, :status => 'Approved', :user => {:username => 'something', :fullname => 'ansdcs', :email => 'vpshah@ncsu.edu'}}
    }.to change{ActionMailer::Base.deliveries.count}.by(1)
  end
end


describe PasswordRetrievalController, type: :controller do
  fixtures :users
  it 'bcnxhcvnhxv' do
    expect{ post :send_password, {:user => {:username => "something", :fullname => "ansdcs", :email => 'vpshah@ncsu.edu'}}
    }.to change{ActionMailer::Base.deliveries.count}.by(1)
  end
end
=end





