describe "self review testing", js: true do
  before(:each) do
    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment', is_selfreview_enabled: 1)
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
    handle = Capybara.current_session.driver.current_window_handle
    Capybara.current_session.driver.maximize_window(handle)
  end

  def add_self_review_scores
    # Login as student2065 to submit the self-review 
    login_as('student2065')
    expect(page).to have_content "User: student2065"
    expect(page).to have_content "TestAssignment"
    # select the assignment for self-review
    find_link("TestAssignment").click
    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"
    # click on the link to review the submitted assignment
    find_link("Your work").click
    expect(page).to have_content "Self Review:"
    click_button "Review our own work"
    find_link("Begin").click
    # Fill in a textbox and a dropdown
    fill_in "responses[0][comment]", with: "HelloWorld"
    select 5, from: "responses[0][score]"
    find_button("Submit Self Review").click
    # Accept the alert box message that appears after submitting a review
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content "Your response was successfully saved."
  end

  # method added to login as another user; required for doing the peer review
  # as a different student "student2064"; redirects to the assignments page of new user
  def visit_new_user name
    user = User.find_by_name(name)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
  end

  # method for peer-reviewing the same assignment 
  def add_peer_review_scores
    # Login as a different student "student2064"
    visit_new_user "student2064"
    expect(page).to have_content "User: student2064"
    expect(page).to have_content "TestAssignment"
    # select the same assignment as the self-review
    find_link("TestAssignment").click
    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"
    # click on other's work to select the assignments available for review
    find_link("Others' work").click
    expect(page).to have_content 'Reviews for "TestAssignment"'
    choose "topic_id"
    # submit the peer-review
    find_button("Request a new submission to review").click
    find_link("Begin").click
    # Fill in a textbox and a dropdown
    fill_in "responses[0][comment]", with: "HelloWorld"
    select 3, from: "responses[0][score]"
    find_button("Submit Review").click
    # Accept the alert box message that appears after submitting a review
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content "Your response was successfully saved."
  end

  def check_self_review_scores
    # Login again as student2065 to check the self-review scores
    visit_new_user "student2065"
    expect(page).to have_content "User: student2065"
    # select the same assignment as before - TestAssignment
    expect(page).to have_content "TestAssignment"
    find_link("TestAssignment").click
    expect(page).to have_content "Submit or Review work for TestAssignment"
    expect(page).to have_content "Others' work"
    find_link("Your scores").click
    # The value should be equal to 40.00 when the peer review score is 3 and self review score is 5
    # these scores are set up in the factory
    expect(page).to have_content "40.00" 
  end

  it "validate scores" do
    # we use student2065 for self reviewing his own work
    add_self_review_scores
    # we use student2064 for peer reviewing student2065's work
    add_peer_review_scores
    # after adding both the reviews, we get back to student2065 and check to see his scores
    check_self_review_scores
  end
end
