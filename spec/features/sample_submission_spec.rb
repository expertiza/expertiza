describe "sample submission test" do
  def create_assignment_team(assignment_name, parent_id)
    assignment_team = AssignmentTeam.new
    assignment_team.name = assignment_name
    assignment_team.parent_id = parent_id
    assignment_team.save!
  end
  before(:each) do
    # create assignment and topic
    assignment = build(Assignment)
    course = Course.new
    course.name = "SampleSubmissionTestCourse"
    course.save
    assignment.course_id = course.id
    assignment.save

    create_assignemnt_team("ss_assignment_team_1", assignment.id)
    create_assignemnt_team("ss_assignment_team_2", assignment.id)
  end

  it "is able to make an assignment public" do
    visit '/student_task/list'
    find(:css, "#makeSubPublic[teamid='6050']").trigger("click")
    click_button 'OK'
  end

  it "is able to view sample submissions page" do

  end

  it "should not see current assignment submissions if deadline is not met" do
    #Set deadline after current time.
    visit '/student_task/list'
    click_on "Example Assignment"
    click_on "Sample Submissions"
    expect(page).to have_content "No sample submissions from current assignment made public yet"
  end

  it "should see current assignment submissions if deadline is met" do
    #Set deadline before current time.
    visit '/student_task/list'
    click_on "Example Assignment"
    click_on "Sample Submissions"
    expect(page).to_not have_content "No sample submissions from current assignment made public yet"
  end

  it "should not see instructor selected submissions if instructor has not selected them" do
    visit '/student_task/list'
    click_on "Example Assignment"
    click_on "Sample Submissions"
    expect(page).to have_content "No sample submissions from previous assignment made available yet"
  end

  it "should see instructor selected submissions if instructor has selected them" do
    #Instructor makes submission available.
    visit '/student_task/list'
    click_on "Example Assignment"
    click_on "Sample Submissions"
    expect(page).to_not have_content "No sample submissions from previous assignment made available yet"
  end
end
