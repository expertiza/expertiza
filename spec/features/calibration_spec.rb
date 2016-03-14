require 'rails_helper'
require 'selenium-webdriver'


context "Calibration Tests" do
  #
  # before (:all) do
  #   Capybara.current_driver = :selenium
  # end
  #
  # after (:all) do
  #   Capybara.use_default_driver
  # end


end



# describe 'some stuff which requires js', :js => true do
#   it 'will use the default js driver'
#   it 'will switch to one specific driver', :driver => :webkit
# end


# Test Assignment Creation Functionality
describe 'Create Assignment' do

  # Before testing create needed state
  before :each do

    # Create an instructor account
    @instructor = create :instructor
  end

  # Test creating an assignment with calibration
  describe 'With Calibration' do

    # An assignment created with calibration turned on
    # should show the calibration tab when editing
    it 'should show calibration tab' do

      # Log in as the instructor.
      login_as @instructor.name

      # Create a new assignment
      visit new_assignment_path

      # Populate form fields
      fill_in 'assignment_form_assignment_name', with: 'Calibration Test'
      fill_in 'assignment_form_assignment_directory_path', with: 'submission'
      check 'assignment_form_assignment_is_calibrated'

      # Submit
      click_button 'Create'

      # Verify Assignment Page
      expect(find('.assignments.edit > h1')).to have_content('Editing Assignment: Calibration Test')
      expect(page).to have_link('Calibration')
    end
  end

  # Test creating an assignment without calibration
  describe 'Without Calibration' do

    # An assignment created with calibration turned off
    # should not show the calibration tab when editing
    it 'Should not show the calibration tab' do

      # Log in as the instructor.
      login_as @instructor.name

      # Create a new assignment
      visit new_assignment_path

      # Populate form fields, leaving calibration unchecked
      fill_in 'assignment_form_assignment_name', with: 'Calibration Test'
      fill_in 'assignment_form_assignment_directory_path', with: 'submission'

      # Submit
      click_button 'Create'

      # Verify Assignment Page
      expect(find('.assignments.edit > h1')).to have_content('Editing Assignment: Calibration Test')
      expect(page).to have_no_selector('#Calibration')
    end
  end
end

# Test Assignment Edit Functionality
describe 'Edit Assignment' do

  # Set up for testing
  before :each do
    # Create an instructor and admin
    @instructor = create(:instructor)
    @admin = create(:admin)

    # Create an assignment with calibration
    @assignment = create :assignment, is_calibrated: true

    # Create a team linked to the calibrated assignment
    @team = create :assignment_team, assignment: @assignment

    # Create an assignment participant linked to the assignment.
    # The factory for this implicitly loads or creates a student
    # (user) object that the participant is linked to.
    @submitter = create :participant, assignment: @assignment

    # Create a mapping between the assignment team and the
    # participant object's user (the student).
    create :team_user, team: @team, user: @submitter.user
  end

  # Verify the calibration tab can be accessed by admins
  it 'calibration can be accessed by admins' do
    # Log in with the admin
    login_as @admin.name

    # Visit the edit page
    visit edit_assignment_path @assignment

    # Verify access to calibration
    expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment.name}")
    expect(page).to have_selector('#Calibration')
  end

  # Verify the calibration tab can be accessed by instructors
  it 'calibration can be accessed by instructors' do
    # Log in with the instructor
    login_as @instructor.name

    # Visit the edit page
    visit edit_assignment_path @assignment

    # Verify access to calibration
    expect(find('.assignments.edit > h1')).to have_content("Editing Assignment: #{@assignment.name}")
    expect(page).to have_selector('#Calibration')
  end

  # Verify that as submissions are made they appear in
  # the table under the calibration tab
  it 'shows artifacts that have been submitted' do
    # Log in with instructor
    login_as @instructor.name

    # Visit the edit page
    visit edit_assignment_path @assignment

    # Click the Calibration Tab
    find('#Calibration').click

    # verify hyperlink exists
    expect(page).to have_link 'https://www.expertiza.ncsu.edu'
  end
end




# Test Submitter Functionality
describe 'Submitter' do

  # Set up for testing
  before :each do
    # Create an instructor and student
    @instructor = create :instructor
    @student = create :student
    @submitter = create :student

    # Create an assignment with calibration
    # Either course: nil is required or an AssignmentNode must also be created.
    # The page will not load if the assignment has a course but no mapping node.
    @assignment = create :assignment, is_calibrated: true, instructor: @instructor, course: nil

    # Create an assignment due date
    create(:deadline_type,name:"submission")
    create(:deadline_type,name:"review")
    create(:deadline_type,name:"resubmission")
    create(:deadline_type,name:"rereview")
    create(:deadline_type,name:"metareview")
    create(:deadline_type,name:"drop_topic")
    create(:deadline_type,name:"signup")
    create(:deadline_type,name:"team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create :due_date, due_at: (DateTime.now + 1)

  
    # Create a team linked to the calibrated assignment
    @team = create :assignment_team, assignment: @assignment

    # Create an assignment participant linked to the assignment
    @participant = create :participant, assignment: @assignment, user: @submitter

    # Create a mapping between the assignment team and the
    # participant object's user (the submitter).
    create :team_user, team: @team, user: @submitter
  end

  # Verify submitters can be added to the assignment
  it 'can be added to the assignment by login' do
    # Log in as the instructor
    login_as @instructor.name

    # Visit the add participant page
    visit "/participants/list?id=#{@assignment.id}&model=Assignment"

    # Student is not already a participant
    expect(page).to have_no_link @student.name

    # Add student as a submitter
    fill_in 'user_name', with: @student.name
    choose 'user_role_submitter'
    click_on 'Add'

    # Verify the submitter is listed
    expect(page).to have_link @student.name
  end

  # Verify submitters can submit artifacts
  it 'can submit artifacts for calibration' do
    # Log in as student
    login_as @submitter.name

    # Click on the assignment link, and navigate to work view
    click_link @assignment.name
    click_link 'Your work'

    # Fill in submission with a url and submit
    fill_in 'submission', with: 'https://google.com'
    click_on 'Upload link'

    # Verify presense of link on page
    expect(page).to have_link 'https://google.com'
  end
end

#test expert review function
describe 'Add Expert Review' do
  before :each do
    #create instructor
    @instructor = create(:instructor)
    @student = create(:student)

    # Create an assignment with calibration
    @assignment = create :assignment, is_calibrated: true

    # Create a team linked to the calibrated assignment
    @team = create :assignment_team, assignment: @assignment

    # Create an assignment participant linked to the assignment.
    # The factory for this implicitly loads or creates a student
    # (user) object that the participant is linked to.
    @submitter = create :participant, assignment: @assignment

    # Create a mapping between the assignment team and the
    # participant object's user (the student).
    create :team_user, team: @team, user: @submitter.user
    create :review_response_map, assignment: @assignment, reviewee: @team
    create :assignment_questionnaire, assignment: @assignment
  end

  it 'should be able to save an expert review without uploading', :js => true do
    # Log in as the instructor.
    login_as @instructor.name

    #should be able to edit assignment to add a expert review
    visit "/review_mapping/add_calibration/#{@assignment.id}?team_id=#{@team.id}"
    #submit expert review
    click_on 'Save Review'

    #expect result
    #If the review was uploaded, there will be a edit link

    expect(page).to have_link('Edit')
  end

  it 'should be able to create expert review', :js => true do
    # Log in as the instructor.
    login_as @instructor.name

    #should be able to edit assignment to add a expert review
    edit_assignment_path @assignment

    #should be able to see assignment and start calibration
    visit "/review_mapping/add_calibration/#{@assignment.id}?team_id=#{@team.id}"

    #Submit expert review
    click_on 'Submit Review'
    #upload expert review
    page.driver.browser.switch_to.alert.accept

    #verify if the expert review were successfully uploaded
    edit_assignment_path @assignment
    find('#Calibration').click
    #If the review was uploaded, there will be a edit link
    expect(page).to have_no_link 'Edit'
  end



  #Student should not be able to submit an expert review
  it 'student should not be able to add an expert review', :js => true do
    #login as student
    login_as @student.name

    #Should not be able to visit expert review page
    visit "/review_mapping/add_calibration/#{@assignment.id}?team_id=#{@team.id}"
    #Expect result
    expect(page).to have_content('This student is not allowed to add_calibration this review_mapping')

  end
end



describe 'Reviewer' do

  # Set up for testing
  before :each do
    # Create an instructor and 3 students
    @instructor = create :instructor
    @student = create :student
    @reviewer = create :student
    @submitter = create :student


    # Create an assignment with calibration
    # Either course: nil is required or an AssignmentNode must also be created.
    # The page will not load if the assignment has a course but no mapping node.
    @assignment = create :assignment, is_calibrated: true, instructor: @instructor, course: nil

    # Create an assignment due date
    create(:deadline_type,name:"submission")
    create(:deadline_type,name:"review")
    create(:deadline_type,name:"resubmission")
    create(:deadline_type,name:"rereview")
    create(:deadline_type,name:"metareview")
    create(:deadline_type,name:"drop_topic")
    create(:deadline_type,name:"signup")
    create(:deadline_type,name:"team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create :due_date, due_at: (DateTime.now + 1)

    # Create a team linked to the calibrated assignment
    @team = create :assignment_team, assignment: @assignment

    # Create an assignment participant linked to the assignment
    @participant_submitter = create :participant, assignment: @assignment, user: @submitter
    @participant_reviewer = create :participant, assignment: @assignment, user: @reviewer
    @participant_reviewer_2 = create :participant, assignment: @assignment, user: @student

    # Create a mapping between the assignment team and the
    # participant object's user.
    create :team_user, team: @team, user: @reviewer

    # Create and map a questionnaire (rubric) to the assignment
    @questionnaire = create :questionnaire
    create :question, questionnaire: @questionnaire
    create :assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire
    create :review_response_map, assignment: @assignment, reviewee: @team

  end


  #instructor should be able to assign artifacts to reviewer
    it'should be able to create a submitted artifact for instructor to assign', :js => true do
      login_as @submitter.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name
      click_link 'Your work'

      # Fill in submission with a url and submit
      fill_in 'submission', with: 'https://google.com'
      click_on 'Upload link'

      # Verify presense of link on page
      expect(page).to have_link 'https://google.com'


    end

  it'instructor should be able to assign artifact to reviewer', :js => true do
    #Log in as an instructor
    login_as @instructor.name

    #Edit assignment route
    visit edit_assignment_path @assignment

    #Choose the option for instructor to assign student to review artifacts
    page.select 'Instructor-Selected', :from => 'assignment_form_assignment_review_assignment_strategy'

    #Assign reviewer
    click_on('Assign reviewers')

    #Add students to review one artifacts
    click_on('add reviewer')

    #Go to the page where instructor can add student to one artifact
    visit "/review_mapping/select_reviewer?contributor_id=#{@team.id}&id=#{@assignment.id}"

    #Input the student's name for the review
    fill_in 'user_name', with: @student.name

    #Add reviewer
    click_on 'Add Reviewer'

    #Verify the student has been assigned to the artifact
    expect(page).to have_content @student.name


  end

    # Verify submitters can submit artifacts
    it 'can review artifacts', :js => true do
      # Log in as student
      login_as @student.name

      # Click on the assignment link, and navigate to work view
      click_link @assignment.name

      #Be able to review others' work
      click_link 'Others\' work'

      #Click_link 'Request a new submission to review'
      find('input[value="Request a new submission to review"]').click

      #Be able to start a review
      expect(page).to have_link 'Begin'

    end
  it 'can not review artifacts if not a assigned a review', :js => true do
    #Log in as a student who hasn't been assigned a artifact to review
    login_as @reviewer.name

    # Click on the assignment link, and navigate to work view
    click_link @assignment.name

    #Be able to review others' work
    click_link 'Others\' work'

    #Click_link 'Request a new submission to review'
    find('input[value="Request a new submission to review"]').click

    #Do not have any artifacts to review
    expect(page).to have_content("No artifact are available to review at this time. Please try later.")

  end

end


