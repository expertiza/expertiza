require 'rails_helper'

RSpec.feature "email notification when someone reviews the work", type: :feature do
  context '123' do
    scenario '123456' do
      visit '/'
      expect(page).to have_content('User Name')
    end
  end
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
  it 'approve requested user' do
    ActionMailer::Base.deliveries.clear
    session[:user] = user123
    allow(RequestedUser).to receive(:update_attributes).and_return(true)
    allow(RequestedUser).to receive(:find_by).and_return(requested_users(:requesteduser1))
    user_attributes = { :email => "something@example.com", :username => "something", :fullname => "ansdcs" }
    #allow(User).to receive(:find_by).and_return(users(:user1))
    expect{ post :create_approved_user, {:id =>1, :status => 'Approved', :user => {:username => 'something', :fullname => 'ansdcs', :email => 'vpshah@ncsu.edu'}}
    }.to change{ActionMailer::Base.deliveries.count}.by(1)

    #expect{ post( :create_approved_user, id: 1, status: 'Approved', user: users(:user1))
    #}.to change{ActionMailer::Base.deliveries.count}.by(1)
  end
end


describe PasswordRetrievalController, type: :controller do
  fixtures :users
  it 'bcnxhcvnhxv' do
    expect{ post :send_password, {:user => {:username => "something", :fullname => "ansdcs", :email => 'vpshah@ncsu.edu'}}
    }.to change{ActionMailer::Base.deliveries.count}.by(1)
  end
end






