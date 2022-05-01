require 'rails_helper'
RSpec.describe StudentTaskController do
    let(:assignment) { build(:assignment, instructor_id: 6, id: 1) }
    let(:instructor) { build(:instructor, id: 6) }
    let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
    let(:review_response) { build(:response, id: 1, map_id: 1) }
    let(:review_response_round1) { build(:response, id: 1, map_id: 1, round: 1, is_submitted: 0) }
    let(:review_response_map) { build(:review_response_map, id: 1, reviewer: participant) }
    let(:questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
    let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
    let(:assignment_questionnaire) { build(:assignment_questionnaire) }
    let(:answer) { double('Answer') }
    let(:assignment_due_date) { build(:assignment_due_date) }
    let(:bookmark) { build(:bookmark) }
    let(:team_response) { build(:response, id: 2, map_id: 2) }
    let(:team_response_map) { build(:review_response_map, id: 2, reviewer: participant, reviewer_is_team: true) }
    let(:team_questionnaire) { build(:questionnaire, id: 2) }
    let(:team_assignment) { build(:assignment, id: 2) }
    let(:assignment_team) { build(:assignment_team, id: 1) }
    let(:signed_up_team) { build(:signed_up_team, team_id: assignment_team.id) }
    let(:assignment_form) { AssignmentForm.new }
    
    describe '#send_email' do
      it 'should redirect to same page if no subject or body' do
        request_params = { 
          send_email:{
            subject: '',
            email_body: '',
            participant_id:9320,
            assignment_id:17
          }
        }
        
        post :send_email, params: request_params

        expect(flash[:notice]).to eq('Please fill in the subject and the Email Content.')
        expect(response).to redirect_to ('student_task/email_reviewers')
     
      end
  end
end