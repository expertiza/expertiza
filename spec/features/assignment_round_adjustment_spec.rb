# Rspec file to test changing review rounds after creating assignment works correctly
# Authors: Carmen ,Manjunath, Roshni,Zhikai
describe "assignment function" do
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
  end

  describe "creation page", js: true do
    # Set up Course and Assignment Details
    before(:each) do
      create(:course, name: "Course_test")
      login_as("instructor6")
      visit "/assignments/new?private=0"
      fill_in 'assignment_form_assignment_name', with: 'multiround_Assignment'
      select('Course_test', from: 'assignment_form_assignment_course_id')
      fill_in 'assignment_form_assignment_directory_path', with: 'testDirectory'
      fill_in 'assignment_form_assignment_spec_location', with: 'testLocation'
      check("assignment_form_assignment_microtask")
      check("assignment_form_assignment_reviews_visible_to_all")
      check("assignment_form_assignment_is_calibrated")
      uncheck("assignment_form_assignment_availability_flag")
      expect(page).to have_select("assignment_form[assignment][reputation_algorithm]", options: ['--', 'Hamer', 'Lauw'])
      click_link 'Due date'
      fill_in 'assignment_form_assignment_rounds_of_reviews', with: '3'
      click_button 'set_rounds'
      click_button 'Create'
      visit current_path
      click_link 'Due date'
      sleep 2
    end

    it "verfies number of review rounds" do
      assignment_test = Assignment.where(name: 'multiround_Assignment').first
      expect(assignment_test).to have_attributes(rounds_of_reviews: 3)
    end

    it "verfies increment in number of review rounds saves correctly" do
      # update assignment by increasing the number of rounds
      fill_in 'assignment_form_assignment_rounds_of_reviews', with: '5'
      click_button 'set_rounds'
      click_button 'Save'
      assignment_test = Assignment.where(name: 'multiround_Assignment').first
      expect(assignment_test).to have_attributes(rounds_of_reviews: 5)
    end

    it "verfies decrement in number of review rounds saves correctly" do
      # update assignment by decreasing the number of rounds
      fill_in 'assignment_form_assignment_rounds_of_reviews', with: '2'
      click_button 'set_rounds'
      click_button 'Save'
      assignment_test = Assignment.where(name: 'multiround_Assignment').first
      expect(assignment_test).to have_attributes(rounds_of_reviews: 2)
    end
  end
end
