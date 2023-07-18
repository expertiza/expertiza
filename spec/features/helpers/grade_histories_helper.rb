# This module defines helper methods for setting up the assignment and making a submission
module GradeHistoriesHelperSpec
  # Sets up an assignment with various parameters
  def assignment_setup
    create(:assignment, name: "Assignment1684", directory_path: "Assignment1684")
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone + 1.day)
    # Log in as an instructor
    login_as("instructor6")
    # Find a user and stub their current role and role name
    user = User.find_by(name: "student2064")
    stub_current_user(user, user.role.name, user.role)
    # Visit the student task page and navigate to the assignment signup sheet
    visit '/student_task/list'
    click_link 'Assignment1684'
    click_link 'Signup sheet'
    # Get the ID of the created assignment and sign up for the first topic
    assignment_id = Assignment.first.id
    visit "/sign_up_sheet/sign_up?id=#{assignment_id}&topic_id=1"
    # Visit the student task page and navigate to the assignment team page
    visit '/student_task/list'
    click_link 'Assignment1684'
    click_link 'Your team'
  end

  # Makes a submission for the previously set up assignment
  def make_submission
    # Visit the student task page and navigate to the assignment submission page
    visit '/student_task/list'
    click_link "Assignment1684"
    click_link "Your work"
    # Fill in the submission field with a URL and click the upload link button
    fill_in 'submission', with: "https://www.ncsu.edu"
    click_on 'Upload link'
  end
end
