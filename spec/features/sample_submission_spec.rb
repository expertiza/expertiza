describe "sample submission test" do
  before(:each) do
    # create assignment and topic
    assignment = build(Assignment)
    course = Course.new
    course.name = "SampleSubmissionTestCourse"
    course.save
    assignment.course_id = course.id
    assignment.save

    assignment_team = AssignmentTeam.new
    assignment_team.name = "ss_assignment_team_1"
    assignment_team.parent_id = assignment.id
    assignment_team.save!

    assignment_team = AssignmentTeam.new
    assignment_team.name = "ss_assignment_team_2"
    assignment_team.parent_id = assignment.id
    assignment_team.save!

    assignment_team = AssignmentTeam.new
    assignment_team.name = "ss_assignment_team_3"
    assignment_team.parent_id = assignment.id
    assignment_team.save!
  end

  def signup_topic
    user = User.find_by(name: "student2064")
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
    click_link "Assignment1684"
    click_link "Your work"
  end

  it "is able to make an assignment public" do
    visit '/student_task/list'
    find(:css, "#makeSubPublic[teamid='6050']").trigger("click")
    click_button 'OK'

  end

  it "is able to view sample submissions page" do

  end

  it "should not see current assignment submissions if deadline is not met" do

  end

  it "should see current assignment submissions if deadline is met" do

  end

  it "should not see instructor selected submissions if instructor has not selected them" do

  end

  it "should see instructor selected submissions if instructor has selected them" do

  end
end
