describe SignUpSheetController do
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true, directory_path: 'assignment') }
  let(:assignment2) { create(:assignment, id: 2, microtask: false, staggered_deadline: false, private: true, directory_path: 'assignment2') }
  let(:assignment3) { create(:assignment, id: 3, microtask: true, staggered_deadline: true, private: false, directory_path: 'assignment3') }
  let(:assignment30) { create(:assignment, id: 30, microtask: true, staggered_deadline: false, private: true, directory_path: 'assignment30') }
  let(:assignment40) { create(:assignment, id: 40, microtask: false, staggered_deadline: true, private: false, directory_path: 'assignment40') }
  let(:assignment6) { create(:assignment, id: 6000, microtask: true, staggered_deadline: false, private: false, directory_path: 'assignment6') }
  let(:assignment7) { create(:assignment, id: 7000, microtask: false, staggered_deadline: true, private: true, directory_path: 'assignment7') }
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
    allow(Assignment).to receive(:find).with('2').and_return(assignment2)
    allow(Assignment).to receive(:find).with(2).and_return(assignment2)
    allow(Assignment).to receive(:find).with('3').and_return(assignment3)
    allow(Assignment).to receive(:find).with(3).and_return(assignment3)
    allow(Assignment).to receive(:find).with('30').and_return(assignment30)
    allow(Assignment).to receive(:find).with(30).and_return(assignment30)
    allow(Assignment).to receive(:find).with('40').and_return(assignment40)
    allow(Assignment).to receive(:find).with(40).and_return(assignment40)
    allow(Assignment).to receive(:find).with('6').and_return(assignment6)
    allow(Assignment).to receive(:find).with(6).and_return(assignment6)
    allow(Assignment).to receive(:find).with('7').and_return(assignment7)
    allow(Assignment).to receive(:find).with(7).and_return(assignment7)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
    allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
    allow(Participant).to receive(:find_by).with(parent_id: 1, user_id: 8).and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
  end

  describe '#new' do
    it 'builds a new sign up topic and renders sign_up_sheet#new page' do
      request_params = { id: 1 }
      get :new, params: request_params
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
            .with('The topic: "Hello world!" has been created successfully. ').and_return('OK')
          allow(topic).to receive(:save).and_return('OK')
          request_params = {
            id: 1,
            topic: {
              topic_identifier: 1,
              topic_name: 'Hello world!',
              max_choosers: 1,
              category: '',
              micropayment: 1
            }
          }
          post :create, params: request_params
          expect(response).to redirect_to('/assignments/1/edit#tabs-2')
        end
      end

      context 'when new topic cannot be saved successfully' do
        it 'sets up a new topic and renders sign_up_sheet#new page' do
          allow(SignUpTopic).to receive(:where).with(topic_name: 'Hello world!', assignment_id: '1').and_return([nil])
          allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
            .with('The topic: "Hello world!" has been created successfully. ').and_return('OK')
          allow(topic).to receive(:save).and_return('OK')
          request_params = {
            id: 1,
            topic: {
              topic_identifier: 1,
              topic_name: 'Hello world!',
              category: '',
              micropayment: 1
            }
          }
          post :create, params: request_params
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
        request_params = {
          id: 1,
          topic: {
            topic_identifier: 666,
            topic_name: 'Hello world!',
            max_choosers: 2,
            category: '666',
            micropayment: 1
          }
        }
        post :create, params: request_params
        expect(SignedUpTeam.first.is_waitlisted).to be false
        expect(response).to redirect_to('/sign_up_sheet/add_signup_topics_staggered?id=1')
      end
    end
  end

  describe '#destroy' do
    context 'when topic can be found' do
      it 'redirects to assignment#edit page' do
        allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
          .with('The topic: "Hello world!" has been successfully deleted. ').and_return('OK')
        request_params = { id: 1, assignment_id: 1 }
        post :destroy, params: request_params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when topic cannot be found' do
      it 'shows an error flash message and redirects to assignment#edit page' do
        allow(SignUpTopic).to receive(:find).with('1').and_return(nil)
        allow_any_instance_of(SignUpSheetController).to receive(:undo_link)
          .with('The topic: "Hello world!" has been successfully deleted. ').and_return('OK')
        request_params = { id: 1, assignment_id: 1 }
        post :destroy, params: request_params
        expect(flash[:error]).to eq('The topic could not be deleted.')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end
  end

  describe '#delete_all_selected_topics' do
    it 'delete_all_selected_topics with staggered deadline true and redirects to edit assignment page with single topic as input' do
      allow(SignUpTopic).to receive(:find).with(assignment_id: 1, topic_identifier: ['E1732']).and_return(topic)
      request_params = { assignment_id: 1, topic_ids: ['E1732'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 1).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/1/edit#tabs-2')
    end

    it 'delete_all_selected_topics for a private assignment and redirects to edit assignment page with single topic selected' do
      create(:topic, id: 2, assignment_id: 2, topic_identifier: 'topic2')
      request_params = { assignment_id: 2, topic_ids: ['topic2'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 2).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/2/edit#tabs-2')
    end

    it 'delete_all_selected_topics for a non private assignment and redirects to edit assignment page with single topic selected' do
      create(:topic, id: 2, assignment_id: 3, topic_identifier: 'topic2')
      request_params = { assignment_id: 3, topic_ids: ['topic2'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 3).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/3/edit#tabs-2')
    end

    it 'delete_all_selected_topics for a non private assignment and redirects to edit assignment page with multiple topic selected' do
      create(:topic, id: 2, assignment_id: 3, topic_identifier: 'topic2')
      create(:topic, id: 3, assignment_id: 3, topic_identifier: 'topic3')
      create(:topic, id: 8, assignment_id: 3, topic_identifier: 'topic4')
      request_params = { assignment_id: 3, topic_ids: %w[topic2 topic3] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 3).count
      expect(topics_exist).to be_eql 1
      expect(response).to redirect_to('/assignments/3/edit#tabs-2')

      request_params = { assignment_id: 3, topic_ids: ['topic4'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 3).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/3/edit#tabs-2')
    end

    it 'delete_all_selected_topics for a private assignment and redirects to edit assignment page with multiple topic selected' do
      create(:topic, id: 2, assignment_id: 2, topic_identifier: 'topic2')
      create(:topic, id: 3, assignment_id: 2, topic_identifier: 'topic3')
      create(:topic, id: 4, assignment_id: 2, topic_identifier: 'topic4')
      request_params = { assignment_id: 2, topic_ids: %w[topic2 topic3] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 2).count
      expect(topics_exist).to be_eql 1
      expect(response).to redirect_to('/assignments/2/edit#tabs-2')

      request_params = { assignment_id: 2, topic_ids: ['topic4'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 2).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/2/edit#tabs-2')
    end

    it 'create topic and delete_all_selected_topics for a staggered deadline assignment and redirects to edit assignment page with single topic selected' do
      create(:topic, id: 40, assignment_id: 40, topic_identifier: 'E1733')
      request_params = { assignment_id: 40, topic_ids: ['E1733'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 40).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/40/edit#tabs-2')
    end

    it 'create topic and delete_all_selected_topics for not a staggered deadline assignment and redirects to edit assignment page with single topic selected' do
      create(:topic, id: 30, assignment_id: 30, topic_identifier: 'E1734')
      request_params = { assignment_id: 30, topic_ids: ['E1734'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 30).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/30/edit#tabs-2')
    end

    it 'create topic and delete_all_selected_topics for a staggered deadline assignment and redirects to edit assignment page with multiple topic selected' do
      create(:topic, id: 30, assignment_id: 40, topic_identifier: 'E1735')
      create(:topic, id: 40, assignment_id: 40, topic_identifier: 'E1736')
      create(:topic, id: 50, assignment_id: 40, topic_identifier: 'E1737')
      create(:topic, id: 60, assignment_id: 40, topic_identifier: 'E1738')
      create(:topic, id: 70, assignment_id: 40, topic_identifier: 'E1739')
      request_params = { assignment_id: 40, topic_ids: %w[E1735 E1736] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 40).count
      expect(topics_exist).to be_eql 3
      expect(response).to redirect_to('/assignments/40/edit#tabs-2')

      request_params = { assignment_id: 40, topic_ids: %w[E1737 E1738] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 40).count
      expect(topics_exist).to be_eql 1
      expect(response).to redirect_to('/assignments/40/edit#tabs-2')

      request_params = { assignment_id: 40, topic_ids: ['E1739'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 40).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/40/edit#tabs-2')
    end

    it 'create topic and delete_all_selected_topics for not a staggered deadline assignment and redirects to edit assignment page with multiple topic selected' do
      create(:topic, id: 30, assignment_id: 30, topic_identifier: 'E1735')
      create(:topic, id: 40, assignment_id: 30, topic_identifier: 'E1736')
      create(:topic, id: 50, assignment_id: 30, topic_identifier: 'E1737')
      create(:topic, id: 60, assignment_id: 30, topic_identifier: 'E1738')
      create(:topic, id: 70, assignment_id: 30, topic_identifier: 'E1739')
      request_params = { assignment_id: 30, topic_ids: %w[E1735 E1736] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 30).count
      expect(topics_exist).to be_eql 3
      expect(response).to redirect_to('/assignments/30/edit#tabs-2')

      request_params = { assignment_id: 30, topic_ids: %w[E1737 E1738] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 30).count
      expect(topics_exist).to be_eql 1
      expect(response).to redirect_to('/assignments/30/edit#tabs-2')

      request_params = { assignment_id: 30, topic_ids: ['E1739'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 30).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/30/edit#tabs-2')
    end

    it 'delete_all_selected_topics for a microtask assignment and redirects to edit assignment page with single topic selected' do
      create(:topic, id: 6000, assignment_id: 6000, topic_identifier: 'topic6000')
      request_params = { assignment_id: 6000, topic_ids: ['topic6000'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 6000).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/6000/edit#tabs-2')
    end

    it 'delete_all_selected_topics for not microtask assignment and redirects to edit assignment page with single topic selected' do
      create(:topic, id: 6000, assignment_id: 7000, topic_identifier: 'topic6000')
      request_params = { assignment_id: 7000, topic_ids: ['topic6000'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 7000).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/7000/edit#tabs-2')
    end

    it 'delete_all_selected_topics for not microtask assignment and redirects to edit assignment page with multiple topic selected' do
      create(:topic, id: 6000, assignment_id: 7000, topic_identifier: 'topic6000')
      create(:topic, id: 7000, assignment_id: 7000, topic_identifier: 'topic7000')
      create(:topic, id: 8000, assignment_id: 7000, topic_identifier: 'topic8000')
      request_params = { assignment_id: 7000, topic_ids: %w[topic6000 topic7000] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 7000).count
      expect(topics_exist).to be_eql 1
      expect(response).to redirect_to('/assignments/7000/edit#tabs-2')

      request_params = { assignment_id: 7000, topic_ids: ['topic8000'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 7000).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/7000/edit#tabs-2')
    end

    it 'delete_all_selected_topics for a microtask assignment and redirects to edit assignment page with multiple topic selected' do
      create(:topic, id: 6000, assignment_id: 6000, topic_identifier: 'topic6000')
      create(:topic, id: 7000, assignment_id: 6000, topic_identifier: 'topic7000')
      create(:topic, id: 8000, assignment_id: 6000, topic_identifier: 'topic8000')
      request_params = { assignment_id: 6000, topic_ids: %w[topic6000 topic7000] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 6000).count
      expect(topics_exist).to be_eql 1
      expect(response).to redirect_to('/assignments/6000/edit#tabs-2')

      request_params = { assignment_id: 6000, topic_ids: ['topic8000'] }
      post :delete_all_selected_topics, params: request_params
      expect(flash[:success]).to eq('All selected topics have been deleted successfully.')
      topics_exist = SignUpTopic.where(assignment_id: 6000).count
      expect(topics_exist).to be_eql 0
      expect(response).to redirect_to('/assignments/6000/edit#tabs-2')
    end
  end

  describe '#delete_all_topics_for_assignment' do
    it 'deletes all topics for the assignment and redirects to edit assignment page' do
      allow(SignUpTopic).to receive(:find).with(assignment_id: '1').and_return(topic)
      request_params = { assignment_id: 1 }
      post :delete_all_topics_for_assignment, params: request_params
      expect(flash[:success]).to eq('All topics have been deleted successfully.')
      expect(response).to redirect_to('/assignments/1/edit')
    end

    it 'deletes all topics for the private assignment and redirects to edit assignment page' do
      create(:topic, id: 2, assignment_id: 2)
      create(:topic, id: 3, assignment_id: 2)
      request_params = { assignment_id: 2 }
      post :delete_all_topics_for_assignment, params: request_params.merge(format: :html)
      topics_exist = SignUpTopic.where(assignment_id: 2).count
      expect(topics_exist).to be_eql 0
      expect(flash[:success]).to eq('All topics have been deleted successfully.')
      expect(response).to redirect_to('/assignments/2/edit')
    end

    it 'deletes all topics for not private assignment and redirects to edit assignment page' do
      create(:topic, id: 2, assignment_id: 3)
      create(:topic, id: 3, assignment_id: 3)
      request_params = { assignment_id: 3 }
      post :delete_all_topics_for_assignment, params: request_params.merge(format: :html)
      topics_exist = SignUpTopic.where(assignment_id: 3).count
      expect(topics_exist).to be_eql 0
      expect(flash[:success]).to eq('All topics have been deleted successfully.')
      expect(response).to redirect_to('/assignments/3/edit')
    end

    it 'deletes all topics for the staggered deadline assignment and redirects to edit assignment page' do
      create(:topic, id: 30, assignment_id: 40, topic_identifier: 'E1740')
      create(:topic, id: 40, assignment_id: 40, topic_identifier: 'E1741')
      create(:topic, id: 50, assignment_id: 40, topic_identifier: 'E1742')
      request_params = { assignment_id: 40 }
      post :delete_all_topics_for_assignment, params: request_params
      topics_exist = SignUpTopic.where(assignment_id: 40).count
      expect(topics_exist).to be_eql 0
      expect(flash[:success]).to eq('All topics have been deleted successfully.')
      expect(response).to redirect_to('/assignments/40/edit')
    end

    it 'deletes all topics for the non-staggered deadline assignment and redirects to edit assignment page' do
      create(:topic, id: 30, assignment_id: 30, topic_identifier: 'E1740')
      create(:topic, id: 40, assignment_id: 30, topic_identifier: 'E1741')
      create(:topic, id: 50, assignment_id: 30, topic_identifier: 'E1742')
      request_params = { assignment_id: 30 }
      post :delete_all_topics_for_assignment, params: request_params
      topics_exist = SignUpTopic.where(assignment_id: 30).count
      expect(topics_exist).to be_eql 0
      expect(flash[:success]).to eq('All topics have been deleted successfully.')
      expect(response).to redirect_to('/assignments/30/edit')
    end

    it 'deletes all topics for the microtask assignment and redirects to edit assignment page' do
      create(:topic, id: 6000, assignment_id: 6000)
      create(:topic, id: 7000, assignment_id: 6000)
      request_params = { assignment_id: 6000 }
      post :delete_all_topics_for_assignment, params: request_params.merge(format: :html)
      topics_exist = SignUpTopic.where(assignment_id: 6000).count
      expect(topics_exist).to be_eql 0
      expect(flash[:success]).to eq('All topics have been deleted successfully.')
      expect(response).to redirect_to('/assignments/6000/edit')
    end

    it 'deletes all topics for not microtask assignment and redirects to edit assignment page' do
      create(:topic, id: 6000, assignment_id: 7000)
      create(:topic, id: 7000, assignment_id: 7000)
      request_params = { assignment_id: 7000 }
      post :delete_all_topics_for_assignment, params: request_params.merge(format: :html)
      topics_exist = SignUpTopic.where(assignment_id: 7000).count
      expect(topics_exist).to be_eql 0
      expect(flash[:success]).to eq('All topics have been deleted successfully.')
      expect(response).to redirect_to('/assignments/7000/edit')
    end
  end

  describe '#edit' do
    it 'renders sign_up_sheet#edit page' do
      request_params = { id: 1 }
      get :edit, params: request_params
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    context 'when topic cannot be found' do
      it 'shows an error flash message and redirects to assignment#edit page' do
        allow(SignUpTopic).to receive(:find).with('1').and_return(nil)
        request_params = { id: 1, assignment_id: 1 }
        post :update, params: request_params
        expect(flash[:error]).to eq('The topic could not be updated.')
        expect(response).to redirect_to('/assignments/1/edit#tabs-2')
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
          .with('The topic: "Hello world!" has been successfully updated. ').and_return('OK')
        request_params = {
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
        post :update, params: request_params
        expect(response).to redirect_to('/assignments/1/edit#tabs-2')
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
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :list, params: request_params, session: user_session
        expect(controller.instance_variable_get(:@bids).size).to eq(1)
        expect(controller.instance_variable_get(:@sign_up_topics)).to be_empty
        expect(response).to render_template('sign_up_sheet/intelligent_topic_selection')
      end
    end

    context 'when current assignment is not intelligent assignment and has submission duedate (deadline_type_id 1)' do
      it 'renders sign_up_sheet#list page' do
        allow(Bid).to receive(:where).with(team_id: 1).and_return([double('Bid', topic_id: 1)])
        allow(SignUpTopic).to receive(:find_by).with(1).and_return(topic)
        request_params = { id: 1 }
        get :list, params: request_params
        expect(response).to render_template(:list)
      end
    end
  end

  describe '#sign_up' do
   context 'when SignUpSheet.signup_team method returns nil' do
     it 'shows an error flash message and redirects to sign_up_sheet#list page' do
       allow(Team).to receive(:find_team_users).with(1, 6).and_return([team])
       request_params = { id: 1 }
       user_session = { user: instructor }
       
       # Stub the method call to return nil
       allow(SignUpSheet).to receive(:signup_team).and_return(nil)
       
       get :sign_up, params: request_params, session: user_session
       expect(flash[:error]).to eq('You\'ve already signed up for a topic!')
       expect(response).to redirect_to('/sign_up_sheet/list?id=1')
     end
    end
  end

  describe '#signup_as_instructor_action' do
    context 'when user cannot be found' do
      it 'shows an flash error message and redirects to assignment#edit page' do
        allow(User).to receive(:find_by).with(username: 'no name').and_return(nil)
        allow(User).to receive(:find).with(8).and_return(student)
        allow(Team).to receive(:find).with(1).and_return(team)
        request_params = { username: 'no name', assignment_id: 1 }
        get :signup_as_instructor_action, params: request_params
        expect(flash[:error]).to eq('That student does not exist!')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when user can be found' do
      before(:each) do
        allow(User).to receive(:find_by).with(username: 'no name').and_return(student)
      end

      context 'when an assignment_participant can be found' do
        before(:each) do
          allow(AssignmentParticipant).to receive(:exists?).with(user_id: 8, parent_id: '1').and_return(true)
        end

        context 'when creating team related objects successfully' do
          it 'shows a flash success message and redirects to assignment#edit page' do
            allow(Team).to receive(:find_team_users).with('1', 8).and_return([team])
            allow(Team).to receive(:find).and_return(team)
            allow(team).to receive(:t_id).and_return(1)
            allow(TeamsUser).to receive(:team_id).with('1', 8).and_return(1)
            allow(SignedUpTeam).to receive(:topic_id).with('1', 8).and_return(1)
            allow(SignUpSheet).to receive(:signup_team).and_return(true)
            allow_any_instance_of(SignedUpTeam).to receive(:save).and_return(team)
            request_params = {
              username: 'no name',
              assignment_id: 1,
              topic_id: 1
            }
            get :signup_as_instructor_action, params: request_params
            expect(flash[:success]).to eq('You have successfully signed up the student for the topic!')
            expect(response).to redirect_to('/assignments/1/edit')
          end
        end

        context 'when creating team related objects unsuccessfully' do
          it 'shows a flash error message and redirects to assignment#edit page' do
            allow(Team).to receive(:find_team_users).with('1', 8).and_return([])
            allow(User).to receive(:find).with(8).and_return(student)
            allow(Assignment).to receive(:find).with(1).and_return(assignment)
            allow(TeamsUser).to receive(:create).with(user_id: 8, team_id: 1).and_return(double('TeamsUser', id: 1))
            allow(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: 1).and_return(double('TeamUserNode', id: 1))
            request_params = {
              username: 'no name',
              assignment_id: 1
            }
            get :signup_as_instructor_action, params: request_params
            expect(flash[:error]).to eq('The student has already signed up for a topic!')
            expect(response).to redirect_to('/assignments/1/edit')
          end
        end
      end

      context 'when an assignment_participant cannot be found' do
        it 'shows a flash error message and redirects to assignment#edit page' do
          allow(AssignmentParticipant).to receive(:exists?).with(user_id: 8, parent_id: '1').and_return(false)
          request_params = {
            username: 'no name',
            assignment_id: 1
          }
          get :signup_as_instructor_action, params: request_params
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
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :delete_signup, params: request_params, session: user_session
        expect(flash[:error]).to eq('You have already submitted your work, so you are not allowed to drop your topic.')
        expect(response).to redirect_to('/sign_up_sheet/list?id=1')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is not nil and its due date has already passed' do
      it 'shows a flash error message and redirects to sign_up_sheet#list page' do
        due_date.due_at = DateTime.now.in_time_zone - 1.day
        allow(assignment).to receive(:due_dates).and_return(due_date)
        allow(due_date).to receive(:find_by).with(deadline_type_id: 6).and_return(due_date)
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :delete_signup, params: request_params, session: user_session
        expect(flash[:error]).to eq('You cannot drop your topic after the drop topic deadline!')
        expect(response).to redirect_to('/sign_up_sheet/list?id=1')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is nil' do
      it 'shows a flash success message and redirects to sign_up_sheet#list page' do
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        allow(Team).to receive(:find_team_users).with(1, 6).and_return([team])
        allow(team).to receive(:t_id).and_return(1)
        request_params = { id: 1, topic_id: 1 }
        user_session = { user: instructor }
        get :delete_signup, params: request_params, session: user_session
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
        request_params = { id: 1 }
        user_session = { user: instructor }
        get :delete_signup_as_instructor, params: request_params, session: user_session
        expect(flash[:error]).to eq('The student has already submitted their work, so you are not allowed to remove them.')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is not nil and its due date has already passed' do
      it 'shows a flash error message and redirects to assignment#edit page' do
        due_date.due_at = DateTime.now.in_time_zone - 1.day
        allow(assignment).to receive(:due_dates).and_return(due_date)
        allow(due_date).to receive(:find_by).with(deadline_type_id: 6).and_return(due_date)
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        request_params = { 
          id: 1,
          due_date: {
            '1_submission_1_due_date' => nil,
            '1_review_1_due_date' => nil
          }
        }
        user_session = { user: instructor }
        get :delete_signup_as_instructor, params: request_params, session: user_session
        expect(flash[:error]).to eq('You cannot drop a student after the drop topic deadline!')
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end

    context 'when both submitted files and hyperlinks of current team are empty and drop topic deadline is nil' do
      it 'shows a flash success message and redirects to assignment#edit page' do
        allow(team).to receive(:submitted_files).and_return([])
        allow(team).to receive(:hyperlinks).and_return([])
        allow(Team).to receive(:find_team_users).with(1, 6).and_return([team])
        allow(team).to receive(:t_id).and_return(1)
        request_params = { id: 1, topic_id: 1 }
        user_session = { user: instructor }
        get :delete_signup_as_instructor, params: request_params, session: user_session
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
      request_params = {
        participant_id: 1,
        assignment_id: 1,
        topic: ['1'],
        due_date: {
            '1_submission_1_due_date' => nil,
            '1_review_1_due_date' => nil
          }
      }
      post :set_priority, params: request_params
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
        request_params = {
          assignment_id: 1,
          due_date: {
            '1_submission_1_due_date' => nil,
            '1_review_1_due_date' => nil
          }
        }
        
        post :save_topic_deadlines, params: request_params
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
        request_params = {
          assignment_id: 1,
          due_date: {
            '1_submission_1_due_date' => nil,
            '1_review_1_due_date' => nil
          }
        }
        post :save_topic_deadlines, params: request_params
        expect(response).to redirect_to('/assignments/1/edit')
      end
    end
  end

  describe '#show_team' do
    it 'renders show_team page' do
      allow(SignedUpTeam).to receive(:where).with(topic_id: 1).and_return([signed_up_team])
      allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([double('TeamsUser', user_id: 1)])
      allow(User).to receive(:find).with(1).and_return(student)
      request_params = { assignment_id: 1, id: 1 }
      get :show_team, params: request_params
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
      request_params = {
        id: 1,
        topic_id: 1
      }
      user_session = { user: instructor }
      get :switch_original_topic_to_approved_suggested_topic, params: request_params, session: user_session
      expect(response).to redirect_to('/sign_up_sheet/list?id=1')
    end
  end

  describe '#delete_signup_for_topic' do
    let!(:topic) { create(:topic, id: 30, assignment_id: 30, topic_identifier: 'E1740') }
    let(:topic_id) { 1 }
    let(:team_id) { 1 }
    let(:sign_up_topic) { instance_double('SignUpTopic') }

    before do
      allow(SignUpTopic).to receive(:find_by).with(id: topic_id).and_return(sign_up_topic)
    end

    context 'when the topic exists' do
      it 'calls reassign_topic on the found SignUpTopic instance' do
        expect(sign_up_topic).to receive(:reassign_topic).with(team_id)
        controller.send(:delete_signup_for_topic, topic_id, team_id)
      end
    end

    context 'when the topic does not exist' do
      it 'does not call reassign_topic' do
        allow(SignUpTopic).to receive(:find_by).with(id: topic_id).and_return(nil)
        expect(sign_up_topic).not_to receive(:reassign_topic)
        controller.send(:delete_signup_for_topic, topic_id, team_id)
      end
    end
  end

end
