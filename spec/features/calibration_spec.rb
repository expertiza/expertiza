require 'rails_helper'

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
    # TODO set up any needed state
  end

  # Verify submitters can be added to the assignment
  it 'can be added to the assignment by login' do
    fail 'not yet implemented'
  end

  # Verify submitters can submit artifacts
  it 'can submit artifacts for calibration' do
    fail 'not yet implemented'
  end
end