describe ReviewResponseMap do

  describe "#questionnaire" do
    context "when round is not nil" do
      it "returns the questionnaire in a certain round"

    end

    context "when round is nil" do
      it "returns the questionnaire"

    end
  end

  describe "#get_title" do
    it "returns 'Review'"
    
  end

  describe "#delete" do
    it "deletes author feedback response records, metareview response records, and review response records"
    
  end

  describe ".export_fields" do
    it "exports the fields of the csv file "
    
  end

  describe ".export" do
    it "exports reviewer names and reviewee names to an array"
    
  end

  describe ".import" do
    context "when the user of the reviewee is nil" do
      it "raises an ArgumentError saying 'cannot find reviewee user'"
      
    end

    context "when the user of the reviewee is not nil" do
      context "when the participant of the reviewee is nil" do
        it "raises an ArgumentError saying 'Reviewee user is not a participant in this assignment'"
        
      end

      context "when the participant of the reviewee is not nil" do
        context "when reviewee does not have a team" do
          it "creates a team for reviewee and finds/creates a review response map record"
          
        end

        context "when reviewee has a team" do
          it "finds/creates a review response map record"
          
        end
      end
    end
  end

  describe "#show_feedback" do
    context "when there is no review responses and the response parameter is nil" do
      it "returns nil"
      
    end

    context "when there exist review responses or the response parameter is not nil" do
      context "when author feedback response map record does not exist or there aren't corresponding responses" do
        it "returns the map variable"
        
      end

      context "when author feedback response map record exists and there exist corresponding responses" do
        it "returns the HTML code which displays the latest author feedback response"
        
      end
    end
  end

  describe "#metareview_response_maps" do
    it "returns metareviews related to current review response map"
    
  end

  describe ".get_responses_for_team_round" do
    context "when the team id is nil" do
      it "returns an empty array"
      
    end

    context "when the team id is not nil" do
      context "when current response map does not have responses" do
        it "returns an array with satisfied responses"
        
      end

      context "when current response map has responses" do
        context "when all these responses don't belong to this round or have been submitted" do
          it "returns an array with satisfied responses"
          
        end

        context "when one or more responses belong to this round and haven't been submitted" do
          it "returns an array with satisfied responses"
          
        end
      end
    end
  end
# start here
  describe ".final_versions_from_reviewer" do
    it "returns a hash with the latest version of response for each response map record and corresponding questionnaire ids"
    
    allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(participant).to receive(:assignment).and_return(assignment)
    allow(ReviewResponseMap).to receive(:where).with(1).and_return(reviewer_id)
    expect(ReviewResponseMap.final_versions_from_reviewer(reviewer_id)).to eq(prepare_final_review_versions(assignment,review_response_map))

  describe ".review_response_report" do
    context "when the review user is nil" do
      it "returns sorted reviewers of a certain type of response map"
      
      
      allow(ResponseMap).to receive(:find).with(1).and_return(review_response_map)
      allow(ResponseMap).to receive(:find).with(1).and_return(response_maps_with_distinct_participant_id)
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(Participant)
      allow(Participant).to receive(:sort_by_name).with(1).and_return(reviewers)
      expect(ReviewResponseMap.review_response_report(review_user=nil)).to eq(reviewers)

    end

    context "when the review user is not nil" do
      it "return reviewers users' full name"
      
      allow(User).to receive(:where).with(1).and_return(user_ids)
      allow(AssignmentParticipant).to receive(:where).with(1).and_return(reviewers)
      expect(ReviewResponseMap.review_response_report).to eq(reviewers)
    end
  end

  describe "#email" do
    it "sends emails to team members whose work has been reviewed"
    
    allow(AssignmentTeam).to receive(:find).with(1).and_return(user)
    expect(ReviewResponseMap.email(user)).to eq(true)
  end

  describe ".prepare_final_review_versions" do
    context "when round number is not nil and is bigger than 1" do
      it "returns the final version of responses in each round"
      
      allow(assignment).to receive(:rounds_of_reviews).with(1).and_return(rounds_num)
      expect(ReviewResponseMap.prepare_final_review_versions).to eq(prepare_review_response(round=rounds_num))
    end

    context "when round number is nil or is smaller than or equal to 1" do
      it "returns the final version of responses"
      
      expect(ReviewResponseMap.prepare_final_review_versions).to eq(prepare_review_response(round=nil))
    end
  end

  describe ".prepare_review_response" do
    context "when the round is nil" do
      it "uses :review as hash key and populate the hash with review questionnaire id and response ids"
      
      allow()
      expect(ReviewResponseMap.prepare_review_response).to eq(review_final_versions)
    end

    context "when the round is not nil" do
      it "uses review round number as hash key and populate the hash with review questionnaire id, round, and response ids"
      
    end
  end
end
