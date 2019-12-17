include InstructorInterfaceHelperSpec
describe 'assignment review after deadline' do

  before(:each) do
    # create assignment and topic
    create(:assignment, id: 1, name: "TestAssignment", directory_path: "TestAssignment")
    create_list(:participant, 3)
    create(:topic, topic_name: "TestTopic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')

    # creating passed deadlines
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone - 1.day)
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "review").first, due_at: DateTime.now.in_time_zone - 1.day)

    create(:assignment_team, id: 1)

    create(:response)
    create(:review_response_map)

  end

  it "should not be able to review work after deadline" do


    # The spec is written to reproduce following bug. "Others' work" link open after deadline passed

    # user = User.find_by(name: "student2065")
    # stub_current_user(user, user.role.name, user.role)
    login_as("student2066")
    visit '/student_task/view?id=1'

    # the page should have content, but after deadline passes it is displayed as gray
    # but there should not be any link attached to it
    expect(page).to have_content "Others' work"

    # this is the bug, even after deadline has passed, the link is still present
    # the ui comment in file views/student_task/view.html.erb says
    # <!--Akshay: Fix Issue 1218 - this link is disabled if assignment does not require any peer reviews-->
    # But the link seems to be open even after deadline passed.
    # Screenshot attached as part of wiki for E1975, Fall 2019
    expect(page).to have_link("Others' work", "/student_review/list?id=1")

  end

  it "should not allow submission after deadline" do

    user = User.find_by(name: "student2066")
    stub_current_user(user, user.role.name, user.role)

    # goto student_task page, which has link to "Your work"
    visit '/student_task/view?id=1'

    # the page will have text "Your work" but will be grayed
    expect(page).to have_content "Your work"

    # the page will not have link to content "Your work"
    expect{click_link "Your work"}.to raise_error(Capybara::ElementNotFound)

  end

  it "should only use submitted response from review_response_map for score calculation" do
    @a_team = create(:assignment_team)
    expect(ReviewResponseMap.get_assessments_for(@a_team)).to eq([])

  end

end
