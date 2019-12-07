describe 'add TA', js: true do
  before(:each) do
    @course = create(:course, name: 'TA course')
    ta_role = Role.create(name: "Teaching Assistant")
    ta_role.save
  end

  it "check to see if TA can be added and removed" do
    student = create(:student)
    login_as('instructor6')
    visit "/course/view_teaching_assistants?id=#{@course.id}&model=Course"
    fill_in 'user_name', with: student.name

    expect do
      click_button 'Add TA'
      wait_for_ajax
    end.to change { TaMapping.count }.by(1)

    visit "/course/view_teaching_assistants?id=#{@course.id}&model=Course"

    expect do
      first(:link, 'Delete').click
      wait_for_ajax
    end.to change { TaMapping.count }.by(-1)
  end

  it "should display newly created course" do
    login_as('instructor6')
    visit "/course/view_teaching_assistants?id=#{@course.id}&model=Course"

    expect(page).to have_content("TA course")
  end
end

describe 'Check TA ability', js: true do
  before(:each) do
    @course = create(:course, name: 'TA course')
    @course1 = create(:course, name: 'Not TA course')
    ta_role = Role.create(name: "Teaching Assistant")
    ta_role.save
    @assignment = create(:assignment, course: nil, name: 'Test Assignment')
    @course_id = Course.where(name: 'TA Course')[0].id
    @course_id = Course.where(name: 'Not TA course')[0].id

    @assignment_id = Assignment.where(name: 'Test Assignment')[0].id

    login_as('instructor6')
    visit "/assignments/associate_assignment_with_course?id=#{@assignment_id}"

    choose "course_id_#{@course_id}"
    click_button 'Save'

    @student = create(:student)
    visit "/course/view_teaching_assistants?id=#{@course.id}&model=Course"
    fill_in 'user_name', with: @student.name

    expect do
      click_button 'Add TA'
      wait_for_ajax
    end.to change { TaMapping.count }.by(1)

  end
  it "The TA mapping successfully created" do
    ta_mappings = TaMapping.where(ta_id: @student.id)
    expect(ta_mappings.get_course_id(@student.id)).to eq(@course.id)
  end

  it "The TA mapping should fail" do
    ta_mappings = TaMapping.where(ta_id: @student.id)
    expect(ta_mappings.get_course_id(@student.id)).not_to eq(@course1.id)
  end
end

