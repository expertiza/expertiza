describe 'add TA', js: true do
  before(:each) do
    @course = create(:course, name: 'TA course')
    ta_role = Role.create(name: 'Teaching Assistant')
    ta_role.save
  end

  it 'check to see if TA can be added and removed' do
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

  it 'should display newly created course' do
    login_as('instructor6')
    visit "/course/view_teaching_assistants?id=#{@course.id}&model=Course"

    expect(page).to have_content('TA course')
  end
end
