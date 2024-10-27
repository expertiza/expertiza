describe 'bookmark review testing' do
  let(:bookmark_rating_response_map) { build(:review_response_map, type: 'BookmarkRatingResponseMap') }
  before(:each) do
    create(:assignment, name: 'TestAssignment', directory_path: 'test_assignment', use_bookmark: true)
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
    create(:bookmark, id: 1, topic_id:  SignUpTopic.first.id)
    create(:bookmark, id: 2, topic_id:  SignUpTopic.second.id)
    create(:team_user, user: User.where(role_id: 1).first)
    create(:team_user, user: User.where(role_id: 1).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 1).third, team: AssignmentTeam.second)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:bookmark_questionnaire)
    create(:question)
    create(:bookmark_review_response_map, reviewer_id: User.where(role_id: 1).second.id, reviewee: Bookmark.first)
  end

  def load_bookmark_list
    login_as('student2064')
    expect(page).to have_content 'User: student2064'
    expect(page).to have_content 'TestAssignment'

    click_link 'TestAssignment'
    sleep(4)
    expect(page).to have_content 'Submit or Review work for TestAssignment'
    expect(page).to have_content 'View bookmarks'

    click_link 'View bookmarks'
    expect(page).to have_content 'Bookmarks list for TestReview'
  end

  xit 'can view bookmark list' do
    load_bookmark_list
  end

  xit 'can edit bookmark' do
    load_bookmark_list
    click_link 'Edit Bookmark'
    expect(page).to have_content 'Editing bookmark'
    click_button 'Update'
  end

  xit 'can destroy bookmark' do
    load_bookmark_list
    click_link 'Destroy Bookmark'
    expect(page).to have_content 'Your bookmark has been successfully deleted!'
  end

  xit 'can add new bookmark' do
    load_bookmark_list
    click_link 'New bookmark'
    expect(page).to have_content 'Add new bookmark'
    fill_in 'title', with: 'Test title'
    fill_in 'url', with: 'test.com'
    fill_in 'description', with: 'test description'
    click_button 'Add new bookmark'
    expect(page).to have_content 'Your bookmark has been successfully created!'
  end

  xit 'can review a bookmark' do
    load_bookmark_list
    click_link 'Review'
    expect(page).to have_content 'New Bookmark Review for TestAssignment'
    fill_in 'responses[0][comment]', with: 'bookmark is awesome!'
    select 5, from: 'responses[0][score]'
    click_button 'Save Bookmark Review'
    expect(page).to have_content 'Your response was successfully saved.'
  end
end
