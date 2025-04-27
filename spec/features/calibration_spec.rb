describe 'calibration' do
  ###
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_exception_errors_feature_tests_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###

  context 'in assignments#edit page' do
    it 'has a checkbox with title \'Calibration for training?\' on \'General\' tab'

    context 'when clicking \'Calibration for training?\' checkbox and clicking \'save\' button' do
      context '\'Calibration\' due date' do
        it 'works correctly'
        # displays a new tab named \'Calibration\' and adds a calibration due date in \'Due dates\' tab'

        # allows instructors to change and save date & time and permissions of calibration due date'
      end
    end
  end

  context 'when current assignment is in calibration stage' do
    context 'calibration feature' do
      it 'works correctly'
      # shows current stage of this assignment to be 'Calibration' on student_task#view page

      # shows 'Calibration review 1, 2, 3...' instead of 'Review 1, 2, 3...' on student_review#list page

      # allows students to do calibration review and the data can be saved successfully

      # the student is able to compare the results of expert review by clicking 'show calibration results' link
    end
  end

  context 'when current assignment is in review stage' do
    it 'excludes calibration reviews from outstanding review restriction and total review restriction'

    it 'shows \'Review 1, 2, 3...\' instead of \'Calibration review 1, 2, 3...\' on student_review#list page'
  end
end
