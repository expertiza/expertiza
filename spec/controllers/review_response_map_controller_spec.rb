require 'rails_helper'
describe ReviewMappingController do
  let(:assignment) { double('Assignment', id: 1) }
  let(:review_response_map) do
    double('ReviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:metareview_response_map) do
    double('MetareviewResponseMap', id: 1, map_id: 1, assignment: assignment,
                                    reviewer: double('Participant', id: 1, name: 'reviewer'), reviewee: double('Participant', id: 2, name: 'reviewee'))
  end
  let(:participant) { double('AssignmentParticipant', id: 1, can_review: false, user: double('User', id: 1)) }
  let(:participant1) { double('AssignmentParticipant', id: 2, can_review: true, user: double('User', id: 2)) }
  let(:user) { double('User', id: 3) }
  let(:participant2) { double('AssignmentParticipant', id: 3, can_review: true, user: user) }
  let(:team) { double('AssignmentTeam', name: 'no one') }
  let(:team1) { double('AssignmentTeam', name: 'no one1') }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end


  describe '#add_calibration' do
    context 'when both participant and review_response_map have already existed' do
      it 'does not need to create new objects and redirects to responses#new maps' do
        allow(AssignmentParticipant).to receive_message_chain(:where, :first)
          .with(parent_id: '1', user_id: 1).with(no_args).and_return(participant)
        allow(ReviewResponseMap).to receive_message_chain(:where, :first)
          .with(reviewed_object_id: '1', reviewer_id: 1, reviewee_id: '1', calibrate_to: true).with(no_args).and_return(review_response_map)
        params = {id: 1, team_id: 1}
        session = {user: build(:instructor, id: 1)}
        get :add_calibration, params, session
        expect(response).to redirect_to '/response/new?assignment_id=1&id=1&return=assignment_edit'
      end
    end

    context 'when both participant and review_response_map have not been created' do
      it 'creates new objects and redirects to responses#new maps' do
        allow(AssignmentParticipant).to receive_message_chain(:where, :first)
          .with(parent_id: '1', user_id: 1).with(no_args).and_return(nil)
        allow(AssignmentParticipant).to receive(:create)
          .with(parent_id: '1', user_id: 1, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle').and_return(participant)
        allow(ReviewResponseMap).to receive_message_chain(:where, :first)
          .with(reviewed_object_id: '1', reviewer_id: 1, reviewee_id: '1', calibrate_to: true).with(no_args).and_return(nil)
        allow(ReviewResponseMap).to receive(:create)
          .with(reviewed_object_id: '1', reviewer_id: 1, reviewee_id: '1', calibrate_to: true).and_return(review_response_map)
        params = {id: 1, team_id: 1}
        session = {user: build(:instructor, id: 1)}
        get :add_calibration, params, session
        expect(response).to redirect_to '/response/new?assignment_id=1&id=1&return=assignment_edit'
      end
    end
  end
end
