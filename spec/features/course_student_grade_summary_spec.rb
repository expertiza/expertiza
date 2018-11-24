describe "Get All Grades For All Students in a Course" do
  before(:each) do
    @course = create(:course, name: 'test course')
    @assignment = create(:assignment, course: @course)
    @questionnaire = create(:questionnaire)
    @question = create(:question, questionnaire: @questionnaire)
    @assignment_questionnaire = create(:assignment_questionnaire, questionnaire: @questionnaire,
                                       assignment: @assignment)
    @review_grade = create(:review_grade)
    @topic = create(:topic, assignment: @assignment)
    @student = create(:student)
    @course.add_participant(@student.name)
    @assignment_participant = create(:participant, user: @student, assignment: @assignment)
    @signed_up_team = create(:signed_up_team, topic: @topic)
    @assignment_team = create(:assignment_team, assignment: @assignment)
    @team_user = create(:team_user, user: @student)
    login_as('instructor6')
    visit("/assessment360/course_student_grade_summary?course_id=#{@course.id}")
  end

  it 'displays Topic' do
    expect(page).to have_content("Topic")
  end

  it 'displays Peer Score ' do
    expect(page).to have_content("Peer Score")
  end

  it 'displays Instructor Grade' do
    expect(page).to have_content("Instructor Grade")
  end

  it 'displays Final Average Peer Score' do
    expect(page).to have_content("Final Average Peer Score")
  end

  it 'displays Final Average Instructor Grade' do
    expect(page).to have_content("Final Average Instructor Grade")
  end

  it 'displays student name' do
    expect(page).to have_content("#{@student.name}")
  end

  it 'displays topic name' do
    expect(page).to have_content("#{@topic.topic_name}")
  end

end