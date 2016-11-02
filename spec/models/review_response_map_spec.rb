require 'rails_helper'
describe 'ReviewResponseMap' do
	before(:each) do
		@participant=create(:participant)
		@assignment_questionnaire= create(:assignment_questionnaire)
		@review_response=create(:review_response_map)
	end
	describe "#validity" do
		it "should have a reviewee_id, reviewed_object_id" do
			expect(@review_response.reviewee_id).to be_instance_of(Fixnum)
			expect(@review_response.reviewed_object_id).to be_instance_of(Fixnum)
		end
		it "should return the questionnaire" do
			review_questionnaire=@review_response.questionnaire 1
			expect(review_questionnaire).to be_instance_of(ReviewQuestionnaire)
			expect(review_questionnaire.id).to be(1)
		end
		it "should return title" do
			expect(@review_response.get_title).to eql "Review"
		end
		it "should return export_fields" do
			export_fields=ReviewResponseMap.export_fields nil
			expect(export_fields.length).to be(2)
		end
	end
	describe "#final_versions_from_reviewer method" do
	#reviewer giver three reviews, result must have final review
		it "should return final version of review when assignment has non varying rubric" do
			create(:response_take)
			create(:response_take)
			create(:response_take)
			map=ReviewResponseMap.final_versions_from_reviewer(1)
			expect(map).to be_truthy
			expect(map[:review][:questionnaire_id]).to be(1)
			expect(map[:review][:response_ids].length).to be(1)
			expect(map[:review][:response_ids][0]).to be(3)
		end
	#reviewer giver two reviews, result must have final review
		it "should return final version of review when assignment has varying rubric" do
			@assignment_questionnaire2= create(:assignment_questionnaire)
			@assignment_questionnaire.update(used_in_round:1)
			@assignment_questionnaire2.update(used_in_round:2)
			create(:response_take)
			create(:response_take)
			map=ReviewResponseMap.final_versions_from_reviewer(1)
			expect(map).to be_truthy
			expect(map["review round1".to_sym][:questionnaire_id]).to be(1)
			expect(map["review round1".to_sym][:response_ids].length).to be(1)
			expect(map["review round1".to_sym][:response_ids][0]).to be(2)
		end
	end
	describe "#get_assessments_round_for" do
	#There are 2 reviewers for a team and both have given their reviews for round 1
		it "should return correct number of reponses per round for a team" do
			@review1 = create(:response_take)
			@review2 = create(:response_take)
			@responsemap2= create(:response_map_review)
			@review2.update(response_map: @responsemap2 )
			@team = build(:assignment_team)
			@team.id=1
			expect(ReviewResponseMap.get_assessments_round_for(@team,1).size).to eq(2)
		end
	#There are 2 reviewers for a team but one reviewer has given review for round1 and another one for round2
		it "should return only those reponses which are related to a particular round" do
			@review1 = create(:response_take)
			@review2 = create(:response_take)
			@responsemap2= create(:response_map_review)
			@review2.update(response_map: @responsemap2 )
			@review2.update(round: 2)
			@team = build(:assignment_team)
			@team.id=1
			expect(ReviewResponseMap.get_assessments_round_for(@team,1).size).to eq(1)
		end
	end
	describe "#Test for the metareview_response_maps method" do
	# There is 1 metareview each for the reviews given by a particular reviewer in round 1 and round 2
		it "should return correct number of metareviews for a particular reviewer" do
			@review1 = create(:response_take)
			@metareview1=create(:response_map_metareview)
			@metareview1.update(reviewed_object_id: @review1.id)
			@review2 = create(:response_take)
			@review2.update(round: 2)
			@metareview2=create(:response_map_metareview)
			@metareview2.update(reviewed_object_id: @review2.id)
			@response_map=@review1.response_map
			expect(@response_map.metareview_response_maps.size).to eq(2)
		end
	end
end
