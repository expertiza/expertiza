########################################

#   Case 1: One team is on the waitlist. They sent a suggestion for new topic and they want to choose their suggested topic. After their suggested topic is approved, they should leave the waitlist and hold their suggested topic;

########################################

describe 'Assignment Topic Suggestion Test' do
  before(:each) do
    create(:assignment, name: 'Assignment_suggest_topic', allow_suggestions: true)
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
    create :assignment_due_date
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: DateTime.now.in_time_zone + 2.days)
  end

  describe 'topic_suggestion' do
    it 'Instructor set an assignment which allow student suggest topic and register student2065' do
      # login as student2065, Note by Xing Pan: modify spec/factories/factories.rb to generate student11 and call "create student" at beginning
      user = User.find_by(username: 'student2064')
      # stub_current_user(user, user.role.name, user.role)
      login_as(user.username)

      visit '/student_task/list'
      expect(page).to have_content 'Assignment_suggest_topic'

      # student2065 suggest topic
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Suggest a topic'
      click_link('Suggest a topic')
      fill_in 'suggestion_title', with: 'suggested_topic'
      fill_in 'suggestion_description', with: 'suggested_description'
      click_button 'Submit'
      expect(page).to have_content 'Thank you for your suggestion'
      logout
      visit login_path
      user = User.find_by(username: 'instructor6')
      login_as(user.username)

      # instructor approve the suggestion topic
      # DUE date need to be added here
      visit '/suggestion/list?id=1&type=Assignment'
      expect(page).to have_content 'Assignment_suggest_topic'
      click_link('View')
      expect(page).to have_content 'suggested_description'
      click_button 'Approve suggestion'
      expect(page).to have_content 'The suggestion was successfully approved.'
    end

    it ' student2064 hold suggest topic and suggest a new one and student2065 enroll on waitlist of suggested topic', js: true do
      # login_as "student2064"
      user = User.find_by(username: 'student2064')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'Assignment_suggest_topic'

      # student2064 suggest topic
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Suggest a topic'
      click_link('Suggest a topic')
      fill_in 'suggestion_title', with: 'suggested_topic'
      fill_in 'suggestion_description', with: 'suggested_description'
      click_button 'Submit'
      expect(page).to have_content 'Thank you for your suggestion'
      click_link('Logout')

      user = User.find_by(username: 'instructor6')
      login_as(user.username)

      # instructor approve the suggestion topic
      visit '/suggestion/list?id=1&type=Assignment'
      expect(page).to have_content 'Suggested topics for Assignment_suggest_topic'
      expect(page).to have_content 'suggested_topic'
      click_link('View')
      expect(page).to have_content 'suggested_description'
      click_button 'Approve suggestion'
      expect(page).to have_content 'The suggestion was successfully approved.'
      click_link('Logout')

      # case 2 student already have topic switch to new topic
      # need two students one to be on the waitlist of previous suggested topic,
      # the other one (student2065) is holding it and suggest another topic and wish to switch to the new one
      user = User.find_by(username: 'student2065')
      login_as(user.username)
      visit '/student_task/list'
      click_link('Assignment_suggest_topic')
      click_link('Signup sheet')
      first("img[title='Signup']").click
      click_link('Logout')

      # log in student2064
      user = User.find_by(username: 'student2064')
      login_as(user.username)
      visit '/student_task/list'
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Suggest a topic'
      click_link('Suggest a topic')
      fill_in 'suggestion_title', with: 'suggested_topic2_will_switch'
      fill_in 'suggestion_description', with: 'suggested_description_2'
      click_button 'Submit'
      expect(page).to have_content 'Thank you for your suggestion'
      click_link('Logout')

      # login_as instructor6 to approve the 2nd suggested topic
      user = User.find_by(username: 'instructor6')
      login_as(user.username)

      # instructor approve the suggestion topic
      visit '/tree_display/list'
      visit '/suggestion/list?id=1&type=Assignment'
      expect(page).to have_content 'Suggested topics for Assignment_suggest_topic'
      expect(page).to have_content 'suggested_topic2_will_switch'
      # find link for new suggested view
      visit '/suggestion/2'
      # click_link('View')
      expect(page).to have_content 'suggested_description'
      click_button 'Approve suggestion'
      expect(page).to have_content 'The suggestion was successfully approved.'
      click_link('Logout')

      # login as student 2064 to switch to new approved topic
      user = User.find_by(username: 'student2064')
      login_as(user.username)
      visit '/student_task/list'
      click_link('Assignment_suggest_topic')
      click_link('Signup sheet')
      expect(page).to have_content 'Your approved suggested topic'
      expect(page).to have_content 'suggested_topic'
      expect(page).to have_content 'suggested_topic2_will_switch'
      first("img[title='Switch Topic']").click
      click_link('Logout')

      # login as student 2065 to see if it's holding the topic rather than on the wait list
      user = User.find_by(username: 'student2065')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'suggested_topic'
      click_link('Logout')

      # login as studnet 2064 to see if it's already shifted to the new suggested topic
      user = User.find_by(username: 'student2064')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'suggested_topic2_will_switch'
      click_link('Logout')
    end

    ########################################
    # Case 3:
    # One team is holding a topic. They sent a suggestion for new topic, and keep themselves in old topic
    ########################################
    it 'student2065 hold suggest topic and suggest a new one, but wish to stay in the old topic', js: true do
      # login_as "student2065"
      user = User.find_by(username: 'student2065')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'Assignment_suggest_topic'

      # student2065 suggest topic
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Suggest a topic'
      click_link('Suggest a topic')
      fill_in 'suggestion_title', with: 'suggested_topic'
      fill_in 'suggestion_description', with: 'suggested_description'
      click_button 'Submit'
      expect(page).to have_content 'Thank you for your suggestion'
      click_link('Logout')

      # login_as "instructor6"
      user = User.find_by(username: 'instructor6')
      login_as(user.username)

      # instructor approve the suggestion topic
      # DUE date need to be added here
      visit '/suggestion/list?id=1&type=Assignment'
      click_link('View')
      expect(page).to have_content 'suggested_description'
      click_button 'Approve suggestion'
      expect(page).to have_content 'The suggestion was successfully approved.'
      click_link('Logout')

      ######################################
      # One team is holding a topic. They sent a suggestion for new topic
      ######################################
      # login_as "student2065"
      user = User.find_by(username: 'student2065')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'Assignment_suggest_topic'

      # student2065 suggest topic
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Suggest a topic'
      click_link('Suggest a topic')
      fill_in 'suggestion_title', with: 'suggested_topic2_without_switch'
      fill_in 'suggestion_description', with: 'suggested_description2_without_switch'
      find('#suggestion_signup_preference').find(:xpath, 'option[2]').select_option
      click_button 'Submit'
      expect(page).to have_content 'Thank you for your suggestion'
      click_link('Logout')

      # login_as "instructor6"
      user = User.find_by(username: 'instructor6')
      login_as(user.username)

      # instructor approve the suggestion topic
      visit '/tree_display/list'
      visit '/suggestion/list?id=1&type=Assignment'
      expect(page).to have_content 'Suggested topics for Assignment_suggest_topic'
      expect(page).to have_content 'suggested_topic2_without_switch'
      find(:xpath, "//tr[contains(.,'suggested_topic2_without_switch')]/td/a", text: 'View').click
      # click_link('View')

      expect(page).to have_content 'suggested_description2_without_switch'
      click_button 'Approve suggestion'
      expect(page).to have_content 'The suggestion was successfully approved.'
      click_link('Logout')

      # login_as "student2065"
      user = User.find_by(username: 'student2065')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'Assignment_suggest_topic'
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Signup sheet'
      click_link('Signup sheet')
      expect(page).to have_content 'suggested_topic2_without_switch'
      # click_link('publish_approved_suggested_topic')
      visit '/sign_up_sheet/publish_approved_suggested_topic/2?assignment_id=1'
      # find(:xpath, "//tr[contains(.,'suggested_topic2_without_switch')]/td/a", :figure=>"Publish Topic").click
      visit '/student_task/list'
      expect(page).to have_content 'suggested_topic'
      click_link('Logout')

      # login_as "student2064"
      user = User.find_by(username: 'student2064')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'Assignment_suggest_topic'
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Signup sheet'
      click_link('Signup sheet')
      expect(page).to have_content ' suggested_topic2_without_switch'
      find(:xpath, "(//img[@title='Signup'])[2]").click
      visit '/student_task/list'
      expect(page).to have_content ' suggested_topic2_without_switch'
      click_link('Logout')
    end

    it 'professor could approve anonymous suggestion topic' do
      # login_as "student2064"
      user = User.find_by(username: 'student2064')
      login_as(user.username)
      visit '/student_task/list'
      expect(page).to have_content 'Assignment_suggest_topic'

      # student2064 suggest topic
      click_link('Assignment_suggest_topic')
      expect(page).to have_content 'Suggest a topic'
      click_link('Suggest a topic')
      fill_in 'suggestion_title', with: 'suggested_topic'
      fill_in 'suggestion_description', with: 'suggested_description'
      find(:xpath, "//input[@name='suggestion_anonymous']").click
      click_button 'Submit'
      expect(page).to have_content 'You have submitted an anonymous suggestion.'
      click_link('Logout')

      user = User.find_by(username: 'instructor6')
      login_as(user.username)

      # instructor approve the suggestion topic
      visit '/suggestion/list?id=1&type=Assignment'
      expect(page).to have_content 'Suggested topics for Assignment_suggest_topic'
      expect(page).to have_content 'suggested_topic'
      click_link('View')
      expect(page).to have_content 'suggested_description'
      click_button 'Approve suggestion'
      expect(page).to have_content 'The suggestion was successfully approved.'
    end
  end
end
