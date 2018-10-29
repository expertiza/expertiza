require 'rspec'
require 'spec_helper'


describe 'ReviewResponseMap' do 
   let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
   let(:team) { build(:assignment_team) }
   let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
   let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }

  describe '#get_title' do

    it 'returns the title' do

	expect(review_response_map.get_title).to eql("Review")
    end
  end

  describe '#questionnaire' do
	
end

        
