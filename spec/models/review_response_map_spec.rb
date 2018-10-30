require 'rspec'
require 'spec_helper'


describe 'ReviewResponseMap' do 
   let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
   let(:team) { build(:assignment_team) }
   let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
   let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
   let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
   let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
   let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
   let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
   let(:meta_review_response_map) { build(:meta_review_response_map, review_mapping: review_response_map, reviewee: participant)}
   let(:feedback_response_map){ build(:review_response_map, type:'FeedbackResponseMap')}

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
end
    

        
