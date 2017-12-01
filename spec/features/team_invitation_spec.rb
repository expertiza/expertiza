describe 'team invitation' do
  ###
  # Please do not share this file with other teams.
  # Please follow the TDD process as much as you can.
  # Use factories to create necessary DB records.
  # Please avoid duplicated code as much as you can by moving the code to before(:each) block or separated methods.
  # RSpec feature tests examples: spec/features/airbrake_expection_errors_feature_tests_spec.rb
  # For single user login, please use login_as method.
  # If your tests need to switch to different users frequently,
  # please use stub_current_user(user, user.role.name, user.role) each time to stub login behavior.
  ###
  before(:each) do
    create(:assignment, name: "TestAssignment", directory_path: 'test_assignment')
    create_list(:participant, 3)
    create(:assignment_node)
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, due_at: (DateTime.now.in_time_zone.in_time_zone + 1))
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: 'review').first, due_at: (DateTime.now.in_time_zone.in_time_zone + 5))
    create(:topic)
    create(:topic, topic_name: "TestReview")
    create(:team_user, user: User.where(role_id: 2).first)
    create(:team_user, user: User.where(role_id: 2).second)
    create(:assignment_team)
    create(:team_user, user: User.where(role_id: 2).third, team: AssignmentTeam.second)
    create(:signed_up_team)
    create(:signed_up_team, team_id: 2, topic: SignUpTopic.second)
    create(:assignment_questionnaire)
    create(:question)

  #  allow(Team).to receive(:find).with(any_args).and_return(SignedUpTeam.first)
  end
  context 'when current assignment is a team-based assignment with topics' do
    context 'when a student access studet_task#list page of this assignment' do
      it 'contains \'Your team\' link on the page' do
        owner = User.find_by(name: "student2064")
        stub_current_user(owner, owner.role.name, owner.role)
        visit '/student_task/list'
        click_link 'TestAssignment'
        expect(page).to have_content 'Your team'
      end
     end

      context 'advertisement feature' do
        before(:each) do
          # team owner creates an advertisement from student_teams#view page
          owner = User.find_by(name: "student2064")
          stub_current_user(owner, owner.role.name, owner.role)
          visit '/student_task/list'
          click_link 'TestAssignment'
          click_link 'Your team'
          click_link 'Create'
          fill_in 'comments_for_advertisement', with: 'advertisement1'
          click_button 'Create'
          expect(page).to have_content 'advertisement1'
          expect(page).to have_content 'Delete'
          # sign_up_sheet#list page has a horn icon appearing at the last column of the table
          user = User.find_by(name: "student2065")
          stub_current_user(user, user.role.name, user.role)
          visit '/student_task/list'
          click_link 'TestAssignment'
          click_link 'Signup sheet'
          # other students could click the horn icon to send a invitation request to team owner
          horn = find(:xpath, "//a[contains(@href,'show_team/2?')]")
          horn.click
          expect(page).to have_content 'Request invitation'
          click_link 'Request invitation'
          fill_in 'comments_', with: 'request_demo'
          expect(page).to have_selector("input[type=submit][value='Create']")
          create(:join_team_request)
          # team owner is able to accept or decline the invitation
          stub_current_user(owner, owner.role.name, owner.role)
          visit '/student_task/list'
          click_link 'TestAssignment'
          visit '/student_task/list'
          click_link 'TestAssignment'
          click_link 'Your team'
          expect(page).to have_selector("input[type=submit][value='Accept']")
          expect(page).to have_selector("input[type=submit][value='Decline']")
        end

        context 'when team owner declining the invitation' do
          it 'makes team members remain the same as before' do

          end
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
