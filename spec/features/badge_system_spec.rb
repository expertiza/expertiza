describe 'badge system' do
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
    it 'has a tab named \'Badges\''

    context 'when switching to \'Badges\' tab' do
      it 'allows instructor to change the thresholds of two badges (by default is 95) and save thresholds to DB'
    end
  end

  context 'when a student receives a very high average teammate review grade (higher than 95 by default)' do
    it 'assigns the \'Good teammate\' badge to this student on student_task#list page'
  end

  context 'when a student receives a very high review grades assigned by teaching staff (higher than 95 by default)' do
    it 'assigns the \'Good reviewer\' badge to this student on student_task#list page'
  end

  context 'on participants#list page' do
    it 'allows instructor to view badges assignment statuses of all participants'
  end
end
