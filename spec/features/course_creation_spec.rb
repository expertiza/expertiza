describe 'add TA', js: true do
  # add 4 courses called D, A, C, B
  # after this block, there should be 4 courses and the order in the dropdown list is D-A-C-B
  before(:each) do
    @instructor = create(:instructor)
    create(:institution, name: 'D')
    create(:institution, name: 'A')
    create(:institution, name: 'C')
    create(:institution, name: 'B')
    @course = create(:course, name: 'TA course')
    ta_role = Role.create(name: "Teaching Assistant")
    ta_role.save
  end

  # the original order is D-A-C-B, after sorting, we expect A-B-C-D
  it "check if the courses are sorted alphabetically" do
    create(:superadmin, name: 'super_administrator2')
    login_as('super_administrator2')
    visit "/course/new?private=1"
    expect(page.find(:xpath, "//*[@id=\"course_institutions_id\"]/option[1]").text).to eq("A")
    expect(page.find(:xpath, "//*[@id=\"course_institutions_id\"]/option[2]").text).to eq("B")
    expect(page.find(:xpath, "//*[@id=\"course_institutions_id\"]/option[3]").text).to eq("C")
    expect(page.find(:xpath, "//*[@id=\"course_institutions_id\"]/option[4]").text).to eq("D")
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
