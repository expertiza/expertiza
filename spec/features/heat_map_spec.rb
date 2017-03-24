require 'rails_helper'
require 'selenium-webdriver'

describe 'Student can view review scores in a heat map distribution', js: true do

  before(:each) do
    # Include setup here for pre-test stuff

    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)

  end

  def create_review
    #Capybara.using_session("Review Setup") do
    login_as('student2064')
    #expect(page).to have_content "User: student2064"
    #expect(page).to have_content "TestAssignment"

    click_link "TestAssignment"
    #expect(page).to have_content "Submit or Review work for TestAssignment"
    #expect(page).to have_content "Others' work"

    click_link "Others' work"
    #expect(page).to have_content 'Reviews for "TestAssignment"'

    choose "topic_id"
    click_button "Request a new submission to review"

    click_link "Begin"

    fill_in 'responses[0][comment]', with: 'HelloWorld'
    select 5, from: "responses[0][score]"
    click_button 'Submit Review'
    #expect(page).to have_content "Your response was successfully saved."

    # click ok on the pop-up box that warns you that responses can not be edited
    page.driver.browser.switch_to.alert.accept

    click_link "Logout"
    click_on('logout-button')
    find("login_name")
    # visit (root_path + '/auth/logout')
    #end


  end

  #it 'should be able to sort by total review score' do
  # This would require us to create several reviews
  #end

  it 'should be able to view a heat map of review scores' do
    create_review

    # Log in as the student with an assignment and reviews
    login_as('student2065')

    # Select the assignment and follow the link to the heat map
    click_link 'TestAssignment'
    click_link 'Alternate View'

    expect(page).to have_content('Summary Report for assignment')
  end

  it 'should be able to follow the link to a specific review' do
    create_review

    # Log in as the student with an assignment and reviews
    login_as('student2065')

    # Select the assignment and follow the link to the heat map
    click_link 'TestAssignment'
    click_link 'Alternate View'

    click_link 'Review 1'
    expect(page).to have_content('Review for')
  end

  it 'should be able to toggle the question list' do
    create_review

    # Log in as the student with an assignment and reviews
    login_as('student2065')

    # Select the assignment and follow the link to the heat map
    click_link 'TestAssignment'
    click_link 'Alternate View'

    click_link 'toggle question list'
    expect(page).to have_content('Question')
  end

end

describe 'Student does not have scores to show in a heat map distribution', js: true do

  before(:each) do
    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
  end

  it 'should show an empty table with no reviews' do
    # Log in as the student with an assignment and reviews
    login_as('student2064')

    click_link 'TestAssignment'
    click_link 'Alternate View'

    expect(page).to_not have_content('Review 1')
  end
end
