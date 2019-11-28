describe 'send email to new user', type: :feature do
  it 'should send correct information to user' do
    ActionMailer::Base.deliveries.clear
    test_user = User.new(name: 'abc', fullname: 'abcdef', email: 'abc@gmail.com')
    test_user.id = 123
    test_user.save!
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
  it 'should be sent from the designated email id' do
    ActionMailer::Base.deliveries.clear
    test_user = User.new(name: 'abc', fullname: 'abcdef', email: 'abc@gmail.com')
    test_user.id = 123
    test_user.save!
    mail = ActionMailer::Base.deliveries.last
    expect(mail.from).to eq(["expertiza.development@gmail.com"])
  end
  it 'should be sent out with correct subject' do
    ActionMailer::Base.deliveries.clear
    test_user = User.new(name: 'abc', fullname: 'abcdef', email: 'abc@gmail.com')
    test_user.id = 123
    test_user.save!
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq('Your Expertiza account and password has been created')
  end

  context 'when user will be created using import file' do
    let(:row) do
      {name: 'username', fullname: 'full name', email: 'abc@mailinator.com'}
    end
    let(:attributes) do
      {role_id: 1, name: 'username', fullname: 'full name', email: 'abc@mailinator.com', email_on_submission: 'abc@mailinator.com', email_on_review: 'abc@mailinator.com', email_on_review_of_review: 'abc@mailinator.com' }
    end

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
end
