describe 'Student can select topics', :type => :feature do
  it 'select a topic' do
    assignment = FactoryGirl.create :assignment
    student = FactoryGirl.create :student

    assignment.add_participant student.name
    
    topic1 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic2 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic3 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic4 = FactoryGirl.create :sign_up_topic, assignment: assignment
    topic5 = FactoryGirl.create :sign_up_topic, assignment: assignment

    visit root_path

    # Log in as student1
    fill_in 'login_name', with: student.name
    fill_in 'login_password', with: student.password
    click_on 'Login'

    # Navigate to the signup sheet
    click_link assignment.name
    click_link 'Signup sheet'

    # Click on sign up
    find(:xpath, "//a[@href='/sign_up_sheet/sign_up?assignment_id=#{topic1.assignment.id}&id=#{topic1.id}']").click

    # Expect topic to be selected.  Look for a div with id "topic_name"
    expect(find('#selected_topic')).to have_content(topic1.topic_name)
  end
end
