require 'rspec'
require 'spec_helper'


describe 'ReviewResponseMap' do 
   let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
   let(:team) { build(:assignment_team) }
   let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
   let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
   let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
   let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }


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
end
    

        
