require 'rails_helper'
describe 'ReviewResponseMap' do
	before(:each) do
		@participant=create(:participant)
		@assignment_questionnaire= create(:assignment_questionnaire)
		@review_response=create(:review_response_map)
	end

  describe "#new" do
    it "Validate response instance creation with valid parameters" do
      expect(@review_response.class).to be(ReviewResponseMap)
    end
    it "Validate response instance creation with valid parameters" do
      response=create(:response_take)
			expect(response.class).to be(Response)
    end
    it "Validate response instance creation with valid parameters" do
			expect(@participant.class).to be(Participant)
    end
  end

  describe "id" do
    #test all the id are stored correctly
  let(:reviewresponsemap) {ReviewResponseMap.new id: 66, reviewee_id: 1, reviewed_object_id: 8}
  let(:response) {Response.new id: 4, map_id: 4}
  let(:participant) {Participant.new id: 1}
    it "should be our exact reviewer's id" do
      reviewresponsemap = build(:review_response_map)
      expect(reviewresponsemap.reviewer_id).to eq(1)
    end
    it "should be our exact reviewee's id" do
      reviewresponsemap = build(:review_response_map)
      expect(reviewresponsemap.reviewee_id).to eq(1)
    end
    it "should be the response map_id" do
      expect(response.map_id).to eq(4)
    end
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
    it "Name of the fields" do
      reviewresponsemap = build(:review_response_map)
			expect(ReviewResponseMap.export_fields(6)).to eq(["contributor", "reviewed by"])
    end
	end
	describe "#final_versions_from_reviewer method" do
	#three reviews are given by reviewer, result must have final review
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
	#two reviews are given reviewer, result must have final review
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
	#2 reviewers in a team and both have given their reviews for round 1
		it "should return correct number of reponses per round for a team" do
			@review1 = create(:response_take)
			@review2 = create(:response_take)
			@responsemap2= create(:response_map_review)
			@review2.update(response_map: @responsemap2 )
			@team = build(:assignment_team)
			@team.id=1
			expect(ReviewResponseMap.get_assessments_round_for(@team,1).size).to eq(2)
		end
	#2 reviewers for a team but one reviewer has given review for round1 and another one for round2
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
	# 1 metareview each for the reviews given by a particular reviewer in round 1 and round 2
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
  describe "#import" do
    it "raise error when not enough items" do
      row = []
      expect {ReviewResponseMap.import(row,nil,nil)}.to raise_error("Not enough items.")
    end
    it "raise error when assignment is nil" do
      assignment = build(:assignment)
      allow(Assignment).to receive(:find).and_return(nil)
      row = ["user_name","reviewer_name", "reviewee_name"]
      expect {ReviewResponseMap.import(row,nil,2)}.to raise_error("The assignment with id \"2\" was not found. <a href='/assignment/new'>Create</a> this assignment?")
    end
    it "raise error when user is nil" do
      assignment = build(:assignment)
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(User).to receive(:find).and_return(nil)
      row = ["reviewer_name", "user_name", "reviewee_name"]
      expect {ReviewResponseMap.import(row,nil,2)}.to raise_error("The user account for the reviewer \"user_name\" was not found. <a href='/users/new'>Create</a> this user?")
    end
    it "raise error when reviewer is nil" do
      assignment = build(:assignment)
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(AssignmentParticipant).to receive(:find).and_return(nil)
      row = ["user_name","reviewer_name", "reviewee_name"]
      expect {ReviewResponseMap.import(row,nil,2)}.to raise_error("The user account for the reviewer \"reviewer_name\" was not found. <a href='/users/new'>Create</a> this user?")
    end
	end
end
