require 'rails_helper'
require 'selenium-webdriver'

describe 'Student can view review scores in a heat map distribution', js: true do
  before(:each) do
    create(:assignment, name: "NewAssignment", directory_path: 'new_assignment')
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
    create(:topic, topic_name: "NewReview")
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
    # NOTE: this function does not work since it stubs: login_as('student2064')
    visit root_path
    fill_in 'login_name', with: 'student2064'
    fill_in 'login_password', with: 'password'
    click_button 'SIGN IN'
    click_link "NewAssignment"
    click_link "Others' work"
    choose "topic_id"
    click_button "Request a new submission to review"
    click_link "Begin"
    fill_in 'responses[0][comment]', with: 'HelloWorld'
    select 5, from: "responses[0][score]"
    click_button 'Submit Review'
    # click ok on the pop-up box that warns you that responses can not be edited
    page.driver.browser.switch_to.alert.accept
    user = User.find_by name: 'student2066'
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
  end

  # it 'should be able to sort by total review score' do
  # This would require us to create several reviews
  # end

  it 'should be able to view a heat map of review scores' do
    create_review
    click_link "NewAssignment"
    click_link 'Alternate View'
    expect(page).to have_content('Summary Report for assignment')
  end

  it 'should be able to follow the link to a specific review' do
    create_review
    # Select the assignment and follow the link to the heat map
    click_link "NewAssignment"
    click_link 'Alternate View'
    new_window = window_opened_by { click_link 'Review 1' }
    within_window new_window do
      expect(page).to have_content('Review for')
    end
  end

  it 'should be able to toggle the question list' do
    create_review
    # Select the assignment and follow the link to the heat map
    click_link "NewAssignment"
    click_link 'Alternate View'
    # Figure out how to add question text so this box works
    # click_link 'toggle question list'
    # expect(page).to have_content('Question')
    expect(page).to have_content('toggle question list')
  end

  it 'should show an empty table with no reviews' do
    # Log in as the student with an assignment and reviews
    login_as('student2064')
    click_link "NewAssignment"
    click_link 'Alternate View'
    expect(page).to_not have_content('Review 1')
  end
end
