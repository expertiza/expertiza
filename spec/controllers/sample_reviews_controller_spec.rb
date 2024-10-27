require 'rails_helper'

RSpec.describe SampleReviewsController, type: :controller do
  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name', assignment: assignment, users: [student]) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:review_response_map1) do
    build :review_response_map,
          id: 2,
          assignment: assignment,
          reviewer: participant1,
          reviewee: team1,
          reviewed_object_id: 1,
          response: [response],
          calibrate_to: 0
  end
  let(:feedback) { FeedbackResponseMap.new(id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: student1) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:responsex) { build(:response, id: 1, map_id: 1, round: 1, response_map: review_response_map, is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 1, round: 2, response_map: review_response_map) }
  let(:response2) { build(:response, id: 3, map_id: 1, round: nil, response_map: review_response_map, is_submitted: true) }
  let(:metareview_response_map) { build(:meta_review_response_map, reviewed_object_id: 1) }
  let(:student) { build(:student, id: 1, username: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, username: 'name1', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:questionnaire) { Questionnaire.new(id: 1, type: 'ReviewQuestionnaire') }
  let(:answer) { Answer.new(id: 5, question_id: 1) }
  let(:samplereview1) { SampleReview.new id: 3, assignment_id: 10, response_id: 5 }
  let(:samplereview2) { SampleReview.new id: 4, assignment_id: 10, response_id: 6 }
  let(:review_response) { build(:response, id: 1, map_id: 1) }
  let(:review_response_map) { build(:review_response_map, id: 1, reviewer: participant) }
  let(:assignment_questionnaire) { build(:assignment_questionnaire) }
  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Response).to receive(:find).with('1').and_return(responsex)
    allow(SampleReview).to receive(:find).with('10').and_return(samplereview1)
    allow(Answer).to receive(:find).with('5').and_return(answer)
    allow(Response).to receive(:where).with(map_id: 1).and_return([review_response])

    allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
    allow(review_response_map).to receive(:reviewer_id).and_return(1)
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(assignment).to receive(:review_questionnaire_id).and_return(1)
    allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire)
    allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])

    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#map_to_assignment' do
    context 'when Instructor selects assignments for sample reviews to be published to' do
      it 'add entry in sampleReviews and marks response visibility to published' do
        request_params = { id: 1, assignments: [1, 2], format: :json }
        user_session = { user: build(:instructor, id: 1) }
        post :map_to_assignment, params: request_params, session: user_session
        expect(responsex).to have_attributes(visibility: 'published')
        expect(response).to have_http_status(201)
      end
    end
  end
  describe '#unmap_from_assignment' do
    context 'when Instructor selects to unmark sample review from all assignments' do
      it 'deletes mapping and marks response visibility to public' do
        request_params = { id: 1, format: :json }
        user_session = { user: build(:instructor, id: 1) }
        post :unmap_from_assignment, params: request_params, session: user_session
        expect(responsex).to have_attributes(visibility: 'public')
        expect(response).to have_http_status(204)
      end
    end
  end

  describe '#index' do
    it 'renders assignments#index page' do
      request_params = { id: 5 }
      get :index, params: request_params
      expect(response).to render_template(:index)
    end
  end

  describe '#show' do
    it 'renders assignments#show page' do
      request_params = { id: 1, return: 'assignment_edit' }
      get :show, params: request_params
      expect(response).to render_template(:show)
    end
  end
end
