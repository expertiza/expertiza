describe "student_task list page" do
  before(:each) do
    # create assignment and topic
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
  end

  def go_to_student_task_page
    user = User.find_by(name: "student2064")
    login_as(user.name)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
  end

  it "have the right content" do
      go_to_student_task_page
      expect(page).to have_content("Assignments")
      expect(page).to have_no_content("badge")
      expect(page).to have_no_content("Review Grade")
      expect(page). to have_content("Assignment")
      expect(page). to have_content("Submission Grade")
      expect(page). to have_content("Topic")
      expect(page). to have_content("Current Stage")
      expect(page). to have_content("Stage Deadline")
      expect(page). to have_content("Publishing Rights")
      expect(page).to have_content("Assignment1684")
    end



end