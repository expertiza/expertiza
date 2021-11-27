
module GradeHistoriesHelperSpec
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
    login_as("instructor6")
    user = User.find_by(name: "student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    click_link 'Assignment1684'
    click_link 'Signup sheet'
    assignment_id = Assignment.first.id
    visit "/sign_up_sheet/sign_up?id=#{assignment_id}&topic_id=1"
    visit '/student_task/list'
    click_link 'Assignment1684'
    click_link 'Your team'
  end

  def make_submission
    visit '/student_task/list'
    click_link "Assignment1684"
    click_link "Your work"
    fill_in 'submission', with: "https://www.ncsu.edu"
    click_on 'Upload link'
  end
end