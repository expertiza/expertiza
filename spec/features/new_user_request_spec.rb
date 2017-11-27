describe 'new user request' do
  ###
  # Please do not share this file with other teams.
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_expection_errors_feature_tests_spec.rb
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###

  context 'request account feature' do
    it 'works correctly'
    # click 'REQUEST ACCOUNT' button on root path, redirect to users#request_new page

    # a new user is able to add a new institution

    # a new user is able to write a brief introduction

    # if the email address of a new user is not valid, the flash message should display the corresponding messages

    # all data can be saved to DB successfully
  end

  context 'on users#list_pending_requested page' do
    it 'allows super-admin and admin to communicate with requesters by clicking email addresses'

    context 'when super-admin or admin rejects a requester' do
      it 'displays \'Rejected\' as status'
    end

    context 'when super-admin or admin accepts a requester' do
      it 'displays \'Accept\' as status and sends an email with randomly-generated password to the new user'

      context 'using name as username and password in the email' do
        it 'allows the new user to login Expertiza'
      end
    end
  end
end
