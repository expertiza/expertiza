require 'rspec'
require 'spec_helper'
describe 'ReviewResponseMap' do
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:participant2) { build(:participant, id: 2, parent_id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:student){ build(:participant, id: 3, parent_id: 1, user: build(:student, name: 'no name', fullname: 'first user')) }
  let(:student2){ build(:participant, id: 4, parent_id: 1, user: build(:student, name: 'no name', fullname: 'second one')) }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:assignment2) { build(:assignment, id: 2, name: 'Test Assgt') }
  let(:response_map) { build(:review_response_map, reviewer: student, response: [response], reviewee_id: 1, type: "ReviewResponseMap") }
  let(:response_map2) { build(:review_response_map, reviewer: student2, response:[response2, response3],reviewee_id: 1, type: "ReviewResponseMap") }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:response) { build(:response, id: 1, round: 1, is_submitted: true,map_id: 1, scores: [answer]) }
  let(:response2) { build(:response, id: 2, round: 1, is_submitted: true, map_id: 1, scores: [answer]) }
  let(:response3) { build(:response, id: 3, round: 1, is_submitted: false, map_id: 1, scores: [answer]) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:review_response_map2) { build(:review_response_map, assignment: assignment2, reviewer: participant2, reviewee: team) }
  let(:meta_review_response_map) { build(:meta_review_response_map, review_mapping: review_response_map, reviewee: participant)}
  let(:feedback_response_map){ build(:review_response_map, response:[response], type:'FeedbackResponseMap')}
  let(:feedback_response_map1){ build(:review_response_map, response:[response], type:'FeedbackResponseMap')}
  let(:user){build(:student)}
  let(:user2){double(:user)}
  describe '#get_title' do
    it 'returns the title' do
      expect(review_response_map.get_title).to eql("Review")
    end
  end

  describe '#questionnaire' do
    it 'returns questionnaire' do
      allow(assignment).to receive(:review_questionnaire_id).and_return(1)
      allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire)
      expect(review_response_map.questionnaire.id).to eq(1)
    end
  end

  describe '.export_fields' do
    it 'returns list of strings "contributor" and "reviewed by"' do
      expect(ReviewResponseMap.export_fields "").to eq(["contributor", "reviewed by"])
    end
  end

  describe '#delete' do
    it 'deletes the review response map' do
      allow(review_response_map.response).to receive(:response_id).and_return(1)
      allow(FeedbackResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([feedback_response_map])
      allow(feedback_response_map).to receive(:delete).with(nil).and_return(true)
      allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: review_response_map.id).and_return([meta_review_response_map])
      allow(meta_review_response_map).to receive(:delete).with(nil).and_return(true)
      allow(review_response_map).to receive(:destroy).and_return(true)
      expect(review_response_map.delete).to be true
    end
  end

  describe '.get_responses_for_team_round' do
    context 'when team doesnt exist' do
      it 'returns empty response' do
        team = instance_double('AssignmentTeam').as_null_object
        allow(team).to receive(:id).and_return(false)
        expect(ReviewResponseMap.get_responses_for_team_round team, 1).to eql([])
      end
    end

    context 'when team exists' do
      it 'returns the responses for particular round' do
        team = instance_double('AssignmentTeam', :id=>1)
        round = 1
        allow(ResponseMap).to receive(:where).with(reviewee_id: 1, type: "ReviewResponseMap").and_return([response_map, response_map2])
        expect(ReviewResponseMap.get_responses_for_team_round(team, round).length).to eql(2)
      end
    end
  end

  describe '#show_feedback' do
    context 'when no response is present or response is nil' do
      it 'returns nil' do
        db1 = instance_double("Response").as_null_object
        expect(review_response_map.show_feedback db1).to be(nil)
      end
    end

    context 'when response is present and not nil' do
      xit 'returns feedback' do
        allow(FeedbackResponseMap).to receive(:find_by).with(reviewed_object_id: 1).and_return(feedback_response_map)
        expect(review_response_map.show_feedback response).to receive(:display_as_html)
      end
    end
  end

  describe '.final_versions_from_reviewer' do
    xit 'returns final versions from reviewer' do
      allow(ReviewResponseMap).to receive(:where).with(reviewer_id: 1).and_return([review_response_map, review_response_map2])
     allow(Participant).to receive(:find).with(1).and_return(participant)
     allow(Assignment).to receive(:find).with(1).and_return(assignment)
     expect(ReviewResponseMap.final_versions_from_reviewer 1).to receive(:prepare_final_review_versions).with(assignment, [review_response_map])
    end
  end

  describe '.import' do
    {reviews: 'name'}
    allow(user).to_receive(:find_by).with(name: 'name').and_return(user)
    expect(ReviewResponseMap.import())
  end
end




