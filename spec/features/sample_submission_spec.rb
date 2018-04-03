def create_assignment_team(assignment_name, parent_id)
  assignment_team = AssignmentTeam.new
  assignment_team.name = assignment_name
  assignment_team.parent_id = parent_id
  assignment_team.save!
end

def init_test
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

def visit_sample_submissions_page
  visit '/student_task/list'
  click_on "Example Assignment"
  click_on "Sample Submissions"
end

describe "sample submission test" do
  before(:each) { init_test }

  it "is able to make an assignment public" do
    visit '/student_task/list'
    find(:css, "#makeSubPublic[teamid='6050']").trigger("click")
    click_button 'OK'
    expect(page).to have_http_status(200)
  end

  it "should not see current assignment submissions if deadline is not met" do # Set deadline after current time.
    visit_sample_submissions_page
    expect(page).to have_content "No sample submissions from current assignment made public yet"
  end

  it "should see current assignment submissions if deadline is met" do # Set deadline before current time.
    visit_sample_submissions_page
    expect(page).to_not have_content "No sample submissions from current assignment made public yet"
  end

  it "should not see instructor selected submissions if instructor has not selected them" do
    visit_sample_submissions_page
    expect(page).to have_content "No sample submissions from previous assignment made available yet"
  end

  it "should see instructor selected submissions if instructor has selected them" do # Instructor makes submission available.
    visit_sample_submissions_page
    expect(page).to_not have_content "No sample submissions from previous assignment made available yet"
  end
end
