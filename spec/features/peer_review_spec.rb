describe 'peer review testing' do
  before(:each) do
    create(:assignment, name: 'TestAssignment', directory_path: 'test_assignment')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: 'submission')
    create(:deadline_type, name: 'review')
    create(:deadline_type, name: 'metareview')
    create(:deadline_type, name: 'drop_topic')
    create(:deadline_type, name: 'signup')
    create(:deadline_type, name: 'team_formation')
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: Time.now.in_time_zone + 1.day)
    create(:topic)
    create(:topic, topic_name: 'TestReview')
    create(:team_user, user: User.where(role_id: 1).first)
    create(:team_user, user: User.where(role_id: 1).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 1).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)
    create(:submission_record, team_id: 2)
    create(:review_response_map, reviewer_id: User.where(role_id: 1).third.id)
    create(:review_response_map, reviewer_id: User.where(role_id: 1).second.id, reviewee: AssignmentTeam.second)
    # sleep(10000)
  end

  def load_questionnaire
    login_as('student2064')
    expect(page).to have_content 'User: student2064'
    expect(page).to have_content 'TestAssignment'

    click_link 'TestAssignment'
    expect(page).to have_content 'Submit or Review work for TestAssignment'
    expect(page).to have_content "Others' work"

    click_link "Others' work"
    expect(page).to have_content 'Reviews for "TestAssignment"'

    choose 'topic_id'
    click_button 'Request a new submission to review'

    click_link 'Begin'
  end

  it 'fills in a single textbox and saves' do
    # Load questionnaire with generic setup
    load_questionnaire

    # Fill in a textbox and a dropdown
    fill_in 'responses[0][comment]', with: 'HelloWorld'
    select 5, from: 'responses[0][score]'
    click_button 'Submit Review'
    expect(page).to have_content 'Your response was successfully saved.'
  end

  it 'fills in a single comment with multi word text and saves' do
    # Load questionnaire with generic setup
    load_questionnaire
    # Fill in a textbox with a multi word comment
    fill_in 'responses[0][comment]', with: 'Excellent Work'
    click_button 'Submit Review'
    expect(page).to have_content 'Your response was successfully saved.'
  end

  it 'fills in a single comment with single word and saves' do
    # Load questionnaire with generic setup
    load_questionnaire
    # Fill in a textbox with a single word comment
    fill_in 'responses[0][comment]', with: 'Excellent'
    click_button 'Submit Review'
    expect(page).to have_content 'Your response was successfully saved.'
  end

  it 'fills in only points and saves' do
    # Load questionnaire with generic setup
    load_questionnaire
    # Fill in a dropdown with some points
    select 5, from: 'responses[0][score]'
    click_button 'Submit Review'
    expect(page).to have_content 'Your response was successfully saved.'
  end

  it 'saves an empty review without any points and comments' do
    # Load questionnaire with generic setup
    load_questionnaire
    click_button 'Submit Review'
    expect(page).to have_content 'Your response was successfully saved.'
  end

  it 'saves a review with only additional comments' do
    # Load questionnaire with generic setup
    load_questionnaire

    # Filling in Additional Comments only
    fill_in 'review[comments]', with: 'Excellent work done!'
    click_button 'Submit Review'
    expect(page).to have_content 'Your response was successfully saved.'
  end
end
