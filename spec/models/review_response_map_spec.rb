require 'rails_helper'

describe 'ReviewResponseMap' do

  before(:each) do
    @participant=create(:participant)
    @assignment_questionnaire= create(:assignment_questionnaire)
    @review_response=create(:review_response_map)
  end

  describe "#validity" do
    it "should have a valid reviewee_id" do
      expect(@review_response.reviewee_id).to be_instance_of(Fixnum)
    end
    it "should return review_map with questionnaire id" do
      map=ReviewResponseMap.final_versions_from_reviewer(1)
      expect(map).to be_truthy
      expect(map[:review][:questionnaire_id]).to be(1)
    end
    it "should return the valid questionnaire" do
      review_questionnaire=@review_response.questionnaire 1
      expect(review_questionnaire).to be_instance_of(ReviewQuestionnaire)
      expect(review_questionnaire.id).to be(1)
    end
    it "should return title" do
      expect(@review_response.title).to eql "Review"
    end
    it "should return export_fields" do
      export_fields=ReviewResponseMap.export_fields nil
      expect(export_fields.length).to be(2)
    end
  end


  describe "#Test for the get_responses_for_team_round method" do

#There are 2 reviewers for a team and both have given their reviews for round 1
    it "should return correct number of reponses per round for a team" do

      @review1 = create(:response_1)
      @review2 = create(:response_1)
      @responsemap2= create(:response_map_review)
      @review2.update(response_map: @responsemap2 )
      @team = build(:assignment_team)
      @team.id=1
      expect(ReviewResponseMap.get_responses_for_team_round(@team,1).size).to eq(2)
    end
#There are 2 reviewers for a team but one reviewer has given review for round1 and another one for round2
    it "should return only those reponses which are related to a particular round" do

      @review1 = create(:response_1)
      @review2 = create(:response_1)
      @responsemap2= create(:response_map_review)
      @review2.update(response_map: @responsemap2 )
      @review2.update(round: 2)
      @team = build(:assignment_team)
      @team.id=1
      expect(ReviewResponseMap.get_responses_for_team_round(@team,1).size).to eq(1)
    end
  end

  describe "#Test for the rereview_response_maps method" do
# There is 1 metareview each for the reviews given by a particular reviewer in round 1 and round 2
    it "should return correct number of metareviews for a particular reviewer" do
      @review1 = create(:response_1)
      @metareview1=create(:response_map_metareview)
      @metareview1.update(reviewed_object_id: @review1.id)
      @review2 = create(:response_1)
      @review2.update(round: 2)
      @metareview2=create(:response_map_metareview)
      @metareview2.update(reviewed_object_id: @review2.id)
      @response_map=@review1.response_map
      expect(@response_map.rereview_response_maps.size).to eq(2)
    end

  end


end
