describe SignUpSheetController do
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 8) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:topic) { build(:topic, id: 1, topic_name: 'new topic', micropayment: 0, category: 'test',topic_identifier: '1', micropayment: 0, description: 'test', link: 'test') }
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
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
  end

  describe '#new' do
    it 'builds a new sign up topic and renders sign_up_sheet#new page' do
      get :new,  id:  1.to_s
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
   let(:params) { {id: 1, topic: {}}}
    context 'when topic cannot be found' do
      context 'when new topic can be saved successfully' do
        it 'sets up a new topic and redirects to assignment#edit page' do
          session[:user] = participant
          allow(SignUpTopic).to receive_message_chain(:where, :first).and_return(nil)
          allow_any_instance_of(SignUpTopic).to receive(:save).and_return(true)
          post :create, params
          expect(response).to redirect_to(edit_assignment_path(1.to_s) + "#tabs-5")
        end
      end

      context 'when new topic cannot be saved successfully' do
        it 'sets up a new topic and renders sign_up_sheet#new page' do
          allow(SignUpTopic).to receive_message_chain(:where, :first).and_return(nil)
          allow_any_instance_of(SignUpTopic).to receive(:save).and_return(false)
          post :create, params
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when topic can be found' do
      it 'updates the existing topic and redirects to sign_up_sheet#add_signup_topics_staggered page' do
        allow(SignUpTopic).to receive_message_chain(:where, :first).and_return(topic)
        post :create, params
        expect(response).to  redirect_to action: 'add_signup_topics_staggered', id: 1
      end
    end
  end




  describe '#destroy' do
    let(:params) { {id: 1, assignment_id: 1} }
    context 'when topic can be found' do
      it 'redirects to assignment#edit page' do
        session[:user] = participant
        post :destroy, params
        expect(response).to redirect_to(edit_assignment_path(1.to_s) + "#tabs-5")
      end
    end

    context 'when topic cannot be found' do
      it 'shows an error flash message and redirects to assignment#edit page' do
        allow(SignUpTopic).to receive(:find).with('1').and_return(nil)
        get :destroy, params
        expect(flash[:error]).to eq("The topic could not be deleted.")
        expect(response).to redirect_to(edit_assignment_path(1.to_s) + "#tabs-5")
      end
    end
  end

  describe '#edit' do
    it 'renders sign_up_sheet#edit page' do
      get :edit, id: 1
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    let(:params) { {id: 1, assignment_id: 1, topic: {}} }
    context 'when topic cannot be found' do
      it 'shows an error flash message and redirects to assignment#edit page' do
        allow(SignUpTopic).to receive(:find).with('1').and_return(nil)
        post :update, params
        expect(flash[:error]).to eq("The topic could not be updated.")
        expect(response).to redirect_to(edit_assignment_path(1.to_s) + "#tabs-5")
      end
    end

    context 'when topic can be found' do
      it 'updates current topic and redirects to assignment#edit page' do
        session[:user] = participant
        post :update, params
        expect(response).to redirect_to(edit_assignment_path(1.to_s) + "#tabs-5")
      end
    end
  end

  describe '#list' do
    let(:params) { {id: '1'} }
   
    context 'when current assignment is intelligent assignment and has submission duedate (deadline_type_id 1)' do
      it 'renders sign_up_sheet#intelligent_topic_selection page' do
        allow(assignment).to receive(:is_intelligent).and_return(true)
        get :list, id: 1
        expect(response).to render_template(:intelligent_topic_selection)
      end
    end

    context 'when current assignment is not intelligent assignment and has submission duedate (deadline_type_id 1)' do
      it 'renders sign_up_sheet#list page' do
        allow(assignment).to receive(:is_intelligent).and_return(false)
        get :list, id: 1
        expect(response).to render_template(:list)
      end
    end
  end

    context 'when current assignment is intelligent assignment and has submission duedate (deadline_type_id 1)' do
      it 'renders sign_up_sheet#list page'
    end
  end

  describe '#sign_up' do
    context 'when SignUpSheet.signup_team method return nil' do
      it 'shows an error flash message and redirects to sign_up_sheet#list page'
    end
  end

  describe '#signup_as_instructor_action' do
    context 'when user cannot be found' do
      it 'shows an flash error message and redirects to assignment#edit page'
    end

    context 'when user cannot be found' do
      context 'when an assignment_participant can be found' do
        context 'when creating team related objects successfully' do
          it 'shows a flash success message and redirects to assignment#edit page'
        end

        context 'when creating team related objects unsuccessfully' do
          it 'shows a flash error message and redirects to assignment#edit page'
        end
      end

      context 'when an assignment_participant can be found' do
        it 'shows a flash error message and redirects to assignment#edit page'
      end
    end
  end

  describe '#delete_signup' do
    context 'when either submitted files or hyperlinks of current team are not empty' do
      it 'shows a flash error message and redirects to sign_up_sheet#list page'
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is not nil and its due date has already passed' do
      it 'shows a flash error message and redirects to sign_up_sheet#list page'
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is nil' do
      it 'shows a flash success message and redirects to sign_up_sheet#list page'
    end
  end

  describe '#delete_signup_as_instructor' do
    context 'when either submitted files or hyperlinks of current team are not empty' do
      it 'shows a flash error message and redirects to assignment#edit page'
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is not nil and its due date has already passed' do
      it 'shows a flash error message and redirects to assignment#edit page'
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is nil' do
      it 'shows a flash success message and redirects to assignment#edit page'
    end
  end

  describe '#set_priority' do
    it 'sets priority of bidding topic and redirects to sign_up_sheet#list page'
  end

  describe '#save_topic_deadlines' do
    context 'when topic_due_date cannot be found' do
      it 'creates a new topic_due_date record and redirects to assignment#edit page'
    end

    context 'when topic_due_date can be found' do
      it 'updates the existing topic_due_date record and redirects to assignment#edit page'
    end
  end

  describe '#show_team' do
    it 'renders show_team page'
  end

  describe '#switch_original_topic_to_approved_suggested_topic' do
    it 'redirects to sign_up_sheet#list page'
  end
end
