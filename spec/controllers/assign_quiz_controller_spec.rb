require 'rails_helper'
describe AssignQuizController do
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

	describe '#assign_quiz_dynamically' do
	    before(:each) do
	      allow(AssignmentParticipant).to receive_message_chain(:where, :first)
	        .with(user_id: '1', parent_id: 1).with(no_args).and_return(participant)
	      @params = {
	        assignment_id: 1,
	        reviewer_id: 1,
	        questionnaire_id: 1,
	        participant_id: 1
	      }
	    end

	    context 'when corresponding response map exists' do
	      it 'shows a flash error and redirects to student_quizzes page' do
	        allow(ResponseMap).to receive_message_chain(:where, :first).with(reviewed_object_id: '1', reviewer_id: '1')
	          .with(no_args).and_return(double('ResponseMap'))

	        post :assign_quiz_dynamically, @params
	        expect(flash[:error]).to eq('You have already taken that quiz.')
	        expect(response).to redirect_to('/student_quizzes?id=1')
	      end
	    end

	    context 'when corresponding response map does not exist' do
	      it 'creates a new QuizResponseMap and redirects to student_quizzes page' do
	        questionnaire = double('Questionnaire', id: 1, instructor_id: 1)
	        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
	        allow(Questionnaire).to receive(:find_by).with(instructor_id: 1).and_return(questionnaire)
	        allow_any_instance_of(QuizResponseMap).to receive(:save).and_return(true)
	        post :assign_quiz_dynamically, @params
	        expect(flash[:error]).to be nil
	        expect(response).to redirect_to('/student_quizzes?id=1')
	      end
	    end
	 end
end