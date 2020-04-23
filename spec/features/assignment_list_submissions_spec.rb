describe "assignment list submissions test" do
  before(:each) do
    # create assignment and topic
    @assignment = create(:assignment, name: "TestAssignment", directory_path: "TestAssignment")
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
    submit_assignment
    user = User.find_by(name: "instructor6")
    stub_current_user(user, user.role.name, user.role)
  end

  def signup_topic
    user = User.find_by(name: "student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
  end

  def submit_assignment
    signup_topic
    fill_in 'submission', with: "https://www.ncsu.edu"
    click_on 'Upload link'
    expect(page).to have_content "https://www.ncsu.edu"
    # open the link and check content
    click_on "https://www.ncsu.edu"
    expect(page).to have_http_status(200)
  end

  context "when current date is before the final deadline" do
    context "when the user is a participant" do
      before(:each) do
        user = User.find_by(name: "instructor6")
        create(:participant, assignment: @assignment, user: user)
        visit "/assignments/list_submissions?id=1"
      end

      it "should show Perform Review Link" do
        expect(page).to have_link("Perform Review")
      end
    end

    context "when the user is not a participant" do
      it "should not show Perform Review link" do
        visit "/assignments/list_submissions?id=1"
        expect(page).not_to have_link("Perform Review")
      end
    end
  end

  context "when the current date is after the final deadline" do
    before(:each) do
      user = User.find_by(name: "instructor6")
      create(:participant, assignment: @assignment, user: user)
      Timecop.travel(2.days.from_now)
      visit "/assignments/list_submissions?id=1"
    end

    it "should not show Perform Review link" do
      expect(page).not_to have_link("Perform Review")
    end

    it "should show Assign Grade link" do
      expect(page).to have_link("Assign Grade")
    end
  end

end
