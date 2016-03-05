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
    it 'Should show calibration tab' do

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
