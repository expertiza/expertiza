describe SignUpSheetController do
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 8) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:topic) { build(:topic, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team: team, topic: topic) }
  let(:signed_up_team2) { build(:signed_up_team, team_id: 2, is_waitlisted: true) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment) }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:due_date2) { build(:assignment_due_date, deadline_type_id: 2) }
  let(:bid) { Bid.new(topic_id: 1, priority: 1) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
    allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
    allow(Participant).to receive(:find_by).with(parent_id: 1, user_id: 8).and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
  end

  describe '#new' do
    it 'builds a new sign up topic and renders sign_up_sheet#new page' do
      params = {id: 1}
      get :new, params
      expect(controller.instance_variable_get(:@sign_up_topic).assignment).to eq(assignment)
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    context 'when topic cannot be found' do
      context 'when new topic can be saved successfully' do
        it 'sets up a new topic and redirects to assignment#edit page' do
          allow(SignUpTopic).to receive(:where).with(topic_name: 'Hello world!', assignment_id: '1').and_return([nil])
          allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
            .with("The topic: \"Hello world!\" has been created successfully. ").and_return('OK')
          allow(topic).to receive(:save).and_return('OK')
          params = {
            id: 1,
            topic: {
              topic_identifier: 1,
              topic_name: 'Hello world!',
              max_choosers: 1,
              category: '',
              micropayment: 1
            }
          }
          post :create, params
          expect(response).to redirect_to('/assignments/1/edit#tabs-5')
        end
      end

      context 'when new topic cannot be saved successfully' do
        it 'sets up a new topic and renders sign_up_sheet#new page' do
          allow(SignUpTopic).to receive(:where).with(topic_name: 'Hello world!', assignment_id: '1').and_return([nil])
          allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
            .with("The topic: \"Hello world!\" has been created successfully. ").and_return('OK')
          allow(topic).to receive(:save).and_return('OK')
          params = {
            id: 1,
            topic: {
              topic_identifier: 1,
              topic_name: 'Hello world!',
              category: '',
              micropayment: 1
            }
          }
          post :create, params
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when topic can be found' do
      it 'updates the existing topic and redirects to sign_up_sheet#add_signup_topics_staggered page' do
        allow(SignedUpTeam).to receive(:find_by).with(topic_id: 1).and_return(signed_up_team)
        allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: true).and_return([signed_up_team2])
        allow(Team).to receive(:find).with(2).and_return(team)
        allow(SignUpTopic).to receive(:find_waitlisted_topics).with(1, 2).and_return(nil)
        params = {
          id: 1,
          topic: {
            topic_identifier: 666,
            topic_name: 'Hello world!',
            max_choosers: 2,
            category: '666',
            micropayment: 1
          }
        }
        post :create, params
        expect(SignedUpTeam.first.is_waitlisted).to be false
        expect(response).to redirect_to('/sign_up_sheet/add_signup_topics_staggered?id=1')
      end
    end
  end

  describe '#destroy' do
    context 'when topic can be found' do
      it 'redirects to assignment#edit page' do
        allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
          .with("The topic: \"Hello world!\" has been successfully deleted. ").and_return('OK')
        params = {id: 1, assignment_id: 1}
        post :destroy, params
        expect(response).to redirect_to('/assignments/1/edit#tabs-5')
      end
    end

    context 'when topic cannot be found' do
      it 'shows an error flash message and redirects to assignment#edit page' do
        allow(SignUpTopic).to receive(:find).with('1').and_return(nil)
        allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
          .with("The topic: \"Hello world!\" has been successfully deleted. ").and_return('OK')
        params = {id: 1, assignment_id: 1}
        post :destroy, params
        expect(flash[:error]).to eq('The topic could not be deleted.')
        expect(response).to redirect_to('/assignments/1/edit#tabs-5')
      end
    end
  end

  describe '#edit' do
    it 'renders sign_up_sheet#edit page' do
      params = {id: 1}
      get :edit, params
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    context 'when topic cannot be found' do
      it 'shows an error flash message and redirects to assignment#edit page' do
        allow(SignUpTopic).to receive(:find).with('1').and_return(nil)
        params = {id: 1, assignment_id: 1}
        post :update, params
        expect(flash[:error]).to eq('The topic could not be updated.')
        expect(response).to redirect_to('/assignments/1/edit#tabs-5')
      end
    end

    context 'when topic can be found' do
      it 'updates current topic and redirects to assignment#edit page' do
        allow(SignUpTopic).to receive(:find).with('2').and_return(build(:topic, id: 2))
        allow(SignedUpTeam).to receive(:find_by).with(topic_id: 2).and_return(signed_up_team)
        allow(SignedUpTeam).to receive(:where).with(topic_id: 2, is_waitlisted: true).and_return([signed_up_team2])
        allow(Team).to receive(:find).with(2).and_return(team)
        allow(SignUpTopic).to receive(:find_waitlisted_topics).with(1, 2).and_return(nil)
        allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
          .with("The topic: \"Hello world!\" has been successfully updated. ").and_return('OK')
        params = {
          id: 2,
          assignment_id: 1,
          topic: {
            topic_identifier: 666,
            topic_name: 'Hello world!',
            max_choosers: 2,
            category: '666',
            micropayment: 1
          }
        }
        post :update, params
        expect(response).to redirect_to('/assignments/1/edit#tabs-5')
      end
    end
  end

  describe '#list' do
    before(:each) do
      allow(SignUpTopic).to receive(:find_slots_filled).with(1).and_return([topic])
      allow(SignUpTopic).to receive(:find_slots_waitlisted).with(1).and_return([])
      allow(SignUpTopic).to receive(:where).with(assignment_id: 1, private_to: nil).and_return([topic])
      allow(participant).to receive(:team).and_return(team)
    end

    context 'when current assignment is intelligent assignment and has submission duedate (deadline_type_id 1)' do
      it 'renders sign_up_sheet#intelligent_topic_selection page' do
        assignment.is_intelligent = true
        allow(Bid).to receive_message_chain(:where, :order).with(team_id: 1).with(:priority).and_return([double('Bid', topic_id: 1)])
        allow(SignUpTopic).to receive(:find_by).with(id: 1).and_return(topic)
        params = {id: 1}
        session = {user: instructor}
        get :list, params, session
        expect(controller.instance_variable_get(:@bids).size).to eq(1)
        expect(controller.instance_variable_get(:@sign_up_topics)).to be_empty
        expect(response).to render_template('sign_up_sheet/intelligent_topic_selection')
      end
    end

    context 'when current assignment is not intelligent assignment and has submission duedate (deadline_type_id 1)' do
      it 'renders sign_up_sheet#list page' do
        allow(Bid).to receive(:where).with(team_id: 1).and_return([double('Bid', topic_id: 1)])
        allow(SignUpTopic).to receive(:find_by).with(1).and_return(topic)
        params = {id: 1}
        get :list, params
        expect(response).to render_template(:list)
      end
    end
  end

  describe '#sign_up' do
    context 'when SignUpSheet.signup_team method return nil' do
      it 'shows an error flash message and redirects to sign_up_sheet#list page' do
        allow(SignedUpTeam).to receive(:find_team_users).with(1, 6).and_return([team])
        params = {id: 1}
        session = {user: instructor}
        get :sign_up, params, session
        expect(flash[:error]).to eq('You\'ve already signed up for a topic!')
        expect(response).to redirect_to('/sign_up_sheet/list?id=1')
      end
    end
  end

  describe '#signup_as_instructor_action' do
    context 'when user cannot be found' do
      it 'shows an flash error message and redirects to assignment#edit page' do
        allow(User).to receive(:find_by).with(name: 'no name').and_return(nil)
        allow(User).to receive(:find).with(8).and_return(student)
        allow(Team).to receive(:find).with(1).and_return(team)
        params = {username: 'no name', assignment_id: 1}
        get :signup_as_instructor_action, params
        expect(flash[:error]).to eq('That student does not exist!')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when user can be found' do
      before(:each) do
        allow(User).to receive(:find_by).with(name: 'no name').and_return(student)
      end

      context 'when an assignment_participant can be found' do
        before(:each) do
          allow(AssignmentParticipant).to receive(:exists?).with(user_id: 8, parent_id: '1').and_return(true)
        end

        context 'when creating team related objects successfully' do
          it 'shows a flash success message and redirects to assignment#edit page' do
            allow(SignedUpTeam).to receive(:find_team_users).with('1', 8).and_return([team])
            allow(team).to receive(:t_id).and_return(1)
            allow(TeamsUser).to receive(:team_id).with('1', 8).and_return(1)
            allow(SignedUpTeam).to receive(:topic_id).with('1', 8).and_return(1)
            allow_any_instance_of(SignedUpTeam).to receive(:save).and_return(team)
            params = {
              username: 'no name',
              assignment_id: 1,
              topic_id: 1
            }
            get :signup_as_instructor_action, params
            expect(flash[:success]).to eq('You have successfully signed up the student for the topic!')
            expect(response).to redirect_to('/assignments/1/edit')
          end
        end

        context 'when creating team related objects unsuccessfully' do
          it 'shows a flash error message and redirects to assignment#edit page' do
            allow(SignedUpTeam).to receive(:find_team_users).with('1', 8).and_return([])
            allow(User).to receive(:find).with(8).and_return(student)
            allow(Assignment).to receive(:find).with(1).and_return(assignment)
            allow(TeamsUser).to receive(:create).with(user_id: 8, team_id: 1).and_return(double('TeamsUser', id: 1))
            allow(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: 1).and_return(double('TeamUserNode', id: 1))
            params = {
              username: 'no name',
              assignment_id: 1
            }
            get :signup_as_instructor_action, params
            expect(flash[:error]).to eq('The student has already signed up for a topic!')
            expect(response).to redirect_to('/assignments/1/edit')
          end
        end
      end

      context 'when an assignment_participant cannot be found' do
        it 'shows a flash error message and redirects to assignment#edit page' do
          allow(AssignmentParticipant).to receive(:exists?).with(user_id: 8, parent_id: '1').and_return(false)
          params = {
            username: 'no name',
            assignment_id: 1
          }
          get :signup_as_instructor_action, params
          expect(flash[:error]).to eq('The student is not registered for the assignment!')
          expect(response).to redirect_to('/assignments/1/edit')
        end
      end
    end
  end

  describe '#delete_signup' do
    before(:each) do
      allow(participant).to receive(:team).and_return(team)
    end

    context 'when either submitted files or hyperlinks of current team are not empty' do
      it 'shows a flash error message and redirects to sign_up_sheet#list page' do
        allow(assignment).to receive(:instructor).and_return(instructor)
        params = {id: 1}
        session = {user: instructor}
        get :delete_signup, params, session
        expect(flash[:error]).to eq('You have already submitted your work, so you are not allowed to drop your topic.')
        expect(response).to redirect_to('/sign_up_sheet/list?id=1')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is not nil and its due date has already passed' do
      it 'shows a flash error message and redirects to sign_up_sheet#list page' do
        due_date.due_at = DateTime.now.in_time_zone - 1.day
        allow(assignment.due_dates).to receive(:find_by).with(deadline_type_id: 6).and_return(due_date)
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        params = {id: 1}
        session = {user: instructor}
        get :delete_signup, params, session
        expect(flash[:error]).to eq('You cannot drop your topic after the drop topic deadline!')
        expect(response).to redirect_to('/sign_up_sheet/list?id=1')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is nil' do
      it 'shows a flash success message and redirects to sign_up_sheet#list page' do
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        allow(SignedUpTeam).to receive(:find_team_users).with(1, 6).and_return([team])
        allow(team).to receive(:t_id).and_return(1)
        params = {id: 1, topic_id: 1}
        session = {user: instructor}
        get :delete_signup, params, session
        expect(flash[:success]).to eq('You have successfully dropped your topic!')
        expect(response).to redirect_to('/sign_up_sheet/list?id=1')
      end
    end
  end

  describe '#delete_signup_as_instructor' do
    before(:each) do
      allow(Team).to receive(:find).with('1').and_return(team)
      allow(TeamsUser).to receive(:find_by).with(team_id: 1).and_return(double('TeamsUser', user: student))
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: 8, parent_id: 1).and_return(participant)
      allow(participant).to receive(:team).and_return(team)
    end

    context 'when either submitted files or hyperlinks of current team are not empty' do
      it 'shows a flash error message and redirects to assignment#edit page' do
        allow(assignment).to receive(:instructor).and_return(instructor)
        params = {id: 1}
        session = {user: instructor}
        get :delete_signup_as_instructor, params, session
        expect(flash[:error]).to eq('The student has already submitted their work, so you are not allowed to remove them.')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is not nil and its due date has already passed' do
      it 'shows a flash error message and redirects to assignment#edit page' do
        due_date.due_at = DateTime.now.in_time_zone - 1.day
        allow(assignment.due_dates).to receive(:find_by).with(deadline_type_id: 6).and_return(due_date)
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        params = {id: 1}
        session = {user: instructor}
        get :delete_signup_as_instructor, params, session
        expect(flash[:error]).to eq('You cannot drop a student after the drop topic deadline!')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is nil' do
      it 'shows a flash success message and redirects to assignment#edit page' do
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        allow(SignedUpTeam).to receive(:find_team_users).with(1, 6).and_return([team])
        allow(team).to receive(:t_id).and_return(1)
        params = {id: 1, topic_id: 1}
        session = {user: instructor}
        get :delete_signup_as_instructor, params, session
        expect(flash[:success]).to eq('You have successfully dropped the student from the topic!')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end
  end

  describe '#set_priority' do
    it 'sets priority of bidding topic and redirects to sign_up_sheet#list page' do
      allow(participant).to receive(:team).and_return(team)
      allow(Bid).to receive(:where).with(team_id: 1).and_return([bid])
      allow(Bid).to receive_message_chain(:where, :map).with(team_id: 1).with(no_args).and_return([1])
      allow(Bid).to receive(:where).with(topic_id: '1', team_id: 1).and_return([bid])
      allow_any_instance_of(Array).to receive(:update_all).with(priority: 1).and_return([bid])
      params = {
        participant_id: 1,
        assignment_id: 1,
        topic: ['1']
      }
      post :set_priority, params
      expect(response).to redirect_to('/sign_up_sheet/list?assignment_id=1')
    end
  end

  describe '#save_topic_deadlines' do
    context 'when topic_due_date cannot be found' do
      it 'creates a new topic_due_date record and redirects to assignment#edit page' do
        assignment.due_dates = [due_date, due_date2]
        allow(SignUpTopic).to receive(:where).with(assignment_id: '1').and_return([topic])
        allow(AssignmentDueDate).to receive(:where).with(parent_id: 1).and_return([due_date])
        allow(DeadlineType).to receive(:find_by_name).with(any_args).and_return(double('DeadlineType', id: 1))
        allow(TopicDueDate).to receive(:create).with(any_args).and_return(double('TopicDueDate'))
        params = {
          assignment_id: 1,
          due_date: {}
        }
        post :save_topic_deadlines, params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when topic_due_date can be found' do
      it 'updates the existing topic_due_date record and redirects to assignment#edit page' do
        assignment.due_dates = [due_date, due_date2]
        allow(SignUpTopic).to receive(:where).with(assignment_id: '1').and_return([topic])
        allow(AssignmentDueDate).to receive(:where).with(parent_id: 1).and_return([due_date])
        allow(DeadlineType).to receive(:find_by_name).with(any_args).and_return(double('DeadlineType', id: 1))
        topic_due_date = double('TopicDueDate')
        allow(TopicDueDate).to receive(:where).with(parent_id: 1, deadline_type_id: 1, round: 1).and_return([topic_due_date])
        allow(topic_due_date).to receive(:update_attributes).with(any_args).and_return(topic_due_date)
        params = {
          assignment_id: 1,
          due_date: {}
        }
        post :save_topic_deadlines, params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end
  end

  describe '#show_team' do
    it 'renders show_team page' do
      allow(SignedUpTeam).to receive(:where).with("topic_id = ?", '1').and_return([signed_up_team])
      allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([double('TeamsUser', user_id: 1)])
      allow(User).to receive(:find).with(1).and_return(student)
      params = {assignment_id: 1, id: 1}
      get :show_team, params
      expect(response).to render_template(:show_team)
    end
  end

  describe '#switch_original_topic_to_approved_suggested_topic' do
    it 'redirects to sign_up_sheet#list page' do
      allow(TeamsUser).to receive(:where).with(user_id: 6).and_return([double('TeamsUser', team_id: 1)])
      allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([double('TeamsUser', team_id: 1, user_id: 8)])
      allow(Team).to receive(:find).with(1).and_return(team)
      team.parent_id = 1
      allow(SignedUpTeam).to receive(:where).with(team_id: 1, is_waitlisted: 0).and_return([signed_up_team])
      allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: 1).and_return([signed_up_team])
      allow(SignUpSheet).to receive(:signup_team).with(1, 8, 1).and_return('OK!')
      params = {
        id: 1,
        topic_id: 1
      }
      session = {user: instructor}
      get :switch_original_topic_to_approved_suggested_topic, params, session
      expect(response).to redirect_to('/sign_up_sheet/list?id=1')
    end
  end
end
