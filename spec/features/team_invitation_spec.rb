describe 'team invitation' do
  ###
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_exception_errors_feature_tests_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###

  context 'when current assignment is a team-based assignment with topics' do
    context 'when a student access studet_task#list page of this assignment' do
      it 'contains \'Your team\' link on the page'
    end

    context 'advertisement feature' do
      before(:each) do
        # team owner creates an advertisement from student_teams#view page

        # sign_up_sheet#list page has a horn icon appearing at the last column of the table

        # other students could click the horn icon to send a invitation request to team owner

        # team owner is able to accept or decline the invitation
      end

      context 'when team owner declining the invitation' do
        it 'makes team members remain the same as before'
      end

      context 'when team owner accepting the invitation' do
        context 'when the team is not full' do
          it 'makes requester joins the team'
        end

        context 'when the team is already full' do
          it 'makes team members remain the same as before'
        end
      end
    end

    context 'on student_teams#view page (student end)' do
      it 'shows a list of students who do not have a team and team owner can invite these students by clicking the \'invite\' buttons'

      context 'when invitee declining the invitation' do
        it 'makes team members remain the same as before'
      end

      context 'when invitee accepting the invitation' do
        context 'when the team is not full' do
          it 'makes invitee joins the team'
        end

        context 'when the team is already full' do
          it 'makes team members remain the same as before'
        end
      end
    end

    context 'on teams#list page (instructor end)' do
      it 'shows a list of students who do not have a team'
    end
  end

  context 'when current assignment is not a team-based assignment' do
    context 'when a student access studet_task#list page of this assignment' do
      it 'does not contain \'Your team\' link on the page'
    end
  end
end
