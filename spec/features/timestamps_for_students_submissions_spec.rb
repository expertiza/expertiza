describe 'timestamps for student\'s submissions' do
  ###
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_exception_errors_feature_tests_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###

  context 'when current assignment is in submission stage' do
    context 'when current participant does not submit anything yet' do
      it 'displays due dates of current assignment in student_task#list page'
    end

    context 'after current participant has submitted a hyperlink' do
      it 'displays hyperlinks with its timestamps'
      # it also displays due dates
    end

    context 'after current participant has uploaded a file' do
      it 'displays file names with its timestamps'
      # it also displays due dates
    end
  end

  context 'when current assignment (with single review round) is in review stage' do
    context 'after current participant reviews other\'s work' do
      it 'displays a link named \'review\' with its timestamps (you could redirect to that review by clicking the link) '
      # it also displays due dates
      # it also displays submitted files or hyperlinks
    end

    context 'after current participant finishes an author feedback' do
      it 'displays a link named \'feedback\' with its timestamps (you could redirect to that feedback by clicking the link)'
      # it also displays due dates
      # it also displays submitted files or hyperlinks
      # it also displays review links
    end
  end

  context 'when current assignment (with multiple review round) is in review stage' do
    context 'after current participant reviews other\'s work in round 1' do
      it 'displays a link named \'review\' with its round number (1) and timestamps (you could redirect to that review by clicking the link)'
      # it also displays due dates
      # it also displays submitted files or hyperlinks
    end

    context 'after current participant reviews other\'s work in round 2' do
      it 'displays a link named \'review\' with its round number (2) and timestamps (you could redirect to that review by clicking the link)'
      # it also displays due dates
      # it also displays submitted files or hyperlinks
      # it also displays review links
    end

    context 'after current participant finishes an author feedback' do
      it 'displays a link named \'feedback\' with its timestamps (you could redirect to that feedback by clicking the link)'
      # it also displays due dates
      # it also displays submitted files or hyperlinks
      # it also displays review links
    end
  end
end
