require 'rails_helper'
require 'selenium-webdriver'

describe "Staggered deadline test" do
  before(:each) do
    create(:assignment, name: "Assignment1665", directory_path: "Assignment1665", staggered_deadline: true)
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic_1")
    create(:topic, topic_name: "Topic_2")
    create(:assignment_questionnaire, used_in_round: 1)
    create(:assignment_questionnaire, used_in_round: 2)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now + (100 * 24 * 60 * 60))
  end


  it "instructor can create an assignment with varying rubric by round feature" do
    login_as("instructor6")
     visit '/tree_display/list'
     visit '/assignments/new?private=0'
     
     fill_in 'assignment_form_assignment_name', with: 'test assignment creation'
     fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
     click_button 'Create'
     find_link('Rubrics').click
     check("assignment_questionnaire_used_in_round")
     find_link('Topics').click
     find_link('New topic').click
     expect(page).to have_content 'New topic'
     fill_in 'topic_topic_identifier', with:'1'
     fill_in 'topic_topic_name', with:'Topic_1'
     fill_in 'topic_category', with: 'Test'
     fill_in 'topic_max_choosers', with: '1'
     click_button 'Create'
     
  end 
  
  it "submit_topic" do #impersonate a student 
    user = User.find_by_name('student2064')
    stub_current_user(user, user.role.name, user.role)

    visit '/student_task/list'
    expect(page).to have_content "User: student2064"
    expect(page).to have_content "Assignment1665"

    visit '/sign_up_sheet/sign_up?assignment_id=1&id=1' #signup topic1

    visit '/student_task/list'

    click_link "Assignment1665"
    expect(page).to have_content "Submit or Review work for Assignment1665"
    expect(page).to have_content "Signup sheet"

    click_link "Your work"
    expect(page).to have_content 'Submit work for Assignment1665'
    expect(page).to have_content 'Submit a hyperlink:'

    fill_in 'submission', with:'https://google.com'
    click_on 'Upload link'
    expect(page).to have_content "https://google.com"
  end

  
  it "create staggered_deadline" do 
    login_as('instructor6')
    visit '/tree_display/list'
    visit "/assignments/1/edit"
    expect(page).to have_content "Editing Assignment: Assignment1665"
    find_link('Due dates').click
    fill_in'assignment_form_assignment_rounds_of_reviews', with:'2'
    click_button 'Set'
    find_link('Topics').click
    find_link('Show start/due date').click
    find_link('Hide start/due date')
    expect(page).to have_button('Save start/due dates', visible: false)
    #expect(page).to have_content("Submission deadline", visible: false)
    #p#age.find('_due_date').set("2014-01-01")
    #ill_in 'due_date_1_submission_1_due_date', with: '#{Time.now + (10 * 24 * 60 * 60))}'
    
  end 
end

