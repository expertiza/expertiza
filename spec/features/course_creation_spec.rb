describe 'add TA', js: true do
  before(:each) do
    @course = create(:course, name: 'TA course')
    ta_role = Role.create(name: "Teaching Assistant")
    ta_role.save
  end

  it "check if the courses are sorted alphabetically" do
    driver = Selenium::WebDriver.for :firefox
    driver.get("http://localhost:3000/")
    driver.find_element(:id, "login_name").send_keys("super_administrator2")
    driver.find_element(:id, "login_password").send_keys("password")
    driver.find_element(:name, "commit").click()
    driver.get("http://localhost:3000/course/new?private=1")
    institutions_eles = driver.find_element(:id, "course_institutions_id")
    options = institutions_eles.find_elements(:tag_name, 'option')
    result = true
    for x in 0..options.size-2
      if (options[x].text.downcase <=> options[x+1].text.downcase) > 0
        result = false
        break
      end
    end
    expect(result).to be(true)
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
