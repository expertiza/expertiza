describe "create group assignment" do
  before(:each) do
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    (1..3).each do |i|
      create(:course, name: "Course #{i}")
    end
  end

  it "is able to create a public group assignment" do
    login_as("instructor6")
    visit "/assignments/new?private=0"

    fill_in 'assignment_form_assignment_name', with: 'public assignment for test'
    select('Course 2', from: 'assignment_form_assignment_course_id')
    fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
    fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
    check("assignment_form_assignment_microtask")
    check("team_assignment")
    fill_in 'assignment_form_assignment_max_team_size', with: '3', visible: false
    check("assignment_form_assignment_reviews_visible_to_all")
    check("assignment_form_assignment_is_calibrated")
    uncheck("assignment_form_assignment_availability_flag")
    expect(page).to have_select("assignment_form[assignment][reputation_algorithm]", options: ['--', 'Hamer', 'Lauw'])

    click_button 'Create'
    assignment = Assignment.where(name: 'public assignment for test').first
    expect(assignment).to have_attributes(
                              name: 'public assignment for test',
                              course_id: Course.find_by(name: 'Course 2').id,
                              directory_path: 'testDirectory',
                              spec_location: 'testLocation',
                              microtask: true,
                              is_calibrated: true,
                              availability_flag: false
                          )
  end
end