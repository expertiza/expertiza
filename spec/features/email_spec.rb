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
    expect(mail.subject).to eq('Your Expertiza password has been created')
  end
end
