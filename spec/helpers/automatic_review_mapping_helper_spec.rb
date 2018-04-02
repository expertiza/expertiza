require 'rails_helper'
require 'spec_helper'

describe 'AutomaticReviewMappingHelper' do

	describe '#auromatic_review_mapping_strategy' do
		context 'When all the calibrated params are not zero' do
		it 'sets the values of different instance variables and calls appropriate methods' do
			allow(helper).to receive(:assign_reviewers_for_team).with(:calibrated_artifacts_num, :params)

			
		end
		end
	end
	
end