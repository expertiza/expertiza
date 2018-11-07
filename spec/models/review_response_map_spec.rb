describe ReviewResponseMap do
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:team1) { build(:assignment_team) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team1) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:answer2) { Answer.new(answer: 2, comments: 'Answer text', question_id: 2) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:question2) { TextArea.new(id: 1, weight: 2, break_before: true) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:questionnaire2) { ReviewQuestionnaire.new(id: 2, questions: [question2], max_question_score: 5) }
  let(:tag_prompt) { TagPrompt.new(id: 1, prompt: "prompt") }
  let(:tag_prompt_deployment) { TagPromptDeployment.new(id: 1, tag_prompt_id: 1, assignment_id: 1, questionnaire_id: 1, question_type: 'Criterion') }
  let(:empty_response) { build(:response, id: nil, map_id: nil, response_map: nil, scores: [answer]) }
  let(:feed_back_response_map) { double('feed_back_response_map', reviewed_object_id: 1, response: empty_response) }
  let(:metareview_response_map) { double('somemap') }

  before(:each) do
    allow(response).to receive(:map).and_return(review_response_map)
  end

  describe "#questionnaire" do
    context "when round is not nil" do
      it "returns the questionnaire in a certain round" do
        allow(assignment).to receive(:review_questionnaire_id).with(1).and_return(1)
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire)
        expect(review_response_map.questionnaire(1)).to eq(questionnaire)
      end
    end
    context "when round is nil" do
      it "returns the questionnaire" do
        allow(assignment).to receive(:review_questionnaire_id).with(nil).and_return(1)
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire)
        expect(review_response_map.questionnaire).to eq(questionnaire)
      end
    end
  end

  describe "#get_title" do
    it "returns 'Review'" do
      expect(review_response_map.get_title).to eq('Review')
    end
  end

  describe "#delete" do
    it "deletes author feedback response records, metareview response records, and review response records" do
      allow(review_response_map).to receive(:response).and_return(response)
      allow(response).to receive(:response_id).and_return(1)
      expect(review_response_map.delete).to eq(review_response_map)
    end
  end

  describe ".export_fields" do
    it "exports the fields of the csv file " do
      expect(ReviewResponseMap.export_fields('_options')).to eq(["contributor", "reviewed by"])
    end
  end

  describe ".export" do
    it "exports reviewer names and reviewee names to an array" do
      allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([review_response_map])
      expect(ReviewResponseMap.export([],1,'_options')).to eq([review_response_map])
    end
  end

  describe ".import" do
    context "when the user of the reviewee is nil" do
      it "raises an ArgumentError saying 'cannot find reviewee user'" do
        hash = {reviewee: 'person1', reviewers: ['person2']}
        allow(User).to receive(:find_by).and_return(nil)
        expect {ReviewResponseMap.import(hash,'_session',1)}.to raise_error(ArgumentError)
      end
    end
    context "when the user of the reviewee is not nil" do
      context "when the participant of the reviewee is nil" do
        it "raises an ArgumentError saying 'Reviewee user is not a participant in this assignment'" do
          hash = {reviewee: 'person1', reviewers: ['person2']}
          reviewee_user = double("User", :id => 5, :name => 'person1')
          allow(User).to receive(:find_by).with(name: 'person1').and_return(reviewee_user)
          allow(AssignmentParticipant).to receive(:find_by).and_return(nil)
          expect {ReviewResponseMap.import(hash,'_session',1)}.to raise_error(ArgumentError)
        end
      end
      context "when the participant of the reviewee is not nil" do
        before(:each) do
          reviewee_user = double("User", :id => 5, :name => 'person1')
          allow(User).to receive(:find_by).with(name: 'person1').and_return(reviewee_user)
          reviewee_participant = double("AssignmentPraticipant", :user_id => 5, :parent_id => 1, :id => 3)
          allow(AssignmentParticipant).to receive(:find_by).and_return(reviewee_participant)
          reviewer_user = double("User", :id => 6, :name => 'person2')
          allow(User).to receive(:find_by).with(name: 'person2').and_return(reviewer_user)
          reviewer_participant = double("AssignmentPraticipant", :user_id => 6, :parent_id => 1, :id => 4)
          allow(AssignmentParticipant).to receive(:where).and_return(reviewer_participant)
          
        end
        context "when reviewee does not have a team" do
          it "creates a team for reviewee and finds/creates a review response map record" do
            hash = {reviewee: 'person1', reviewers: ['person2']}
            allow(AssignmentTeam).to receive(:team).and_return(nil)
            reviewee_team = double("AssignmentTeam", :name => 'Team_1', :parent_id => 1, :id => 2)
            allow(AssignmentTeam).to receive(:create).and_return(reviewee_team)
            t_user = double("TeamUser", :team_id =>2, :user_id =>5, :id => 7)
            allow(TeamsUser).to receive(:create).and_return(t_user)
            team_node = double("TeamNode", :parent_id =>1, :node_object_id => 2, :id => 4)
            allow(TeamNode).to receive(:create).and_return(team_node)
            team_user_node = double("TeamUserNode", :parent_id => 4, :node_object_id => 7)
            allow(TeamUserNode).to receive(:create).and_return(team_user_node)
            review_response_map1 = double("ReviewResponseMap", :reviewed_object_id => 1, :reviewer_id => 4, :reviewee_id => 2, :calibrate_to => false)
            allow(ReviewResponseMap).to receive(:find_by).and_return(review_response_map1)
            expect(ReviewResponseMap.import(hash,'_session',1)).to eq(['person2'])
          end
        end
        context "when reviewee has a team" do
          it "finds/creates a review response map record" do
            hash = {reviewee: 'person1', reviewers: ['person2']}
            reviewee_team = double("AssignmentTeam", :parent_id => 1, :id => 2)
            allow(AssignmentTeam).to receive(:team).and_return(reviewee_team)
            review_response_map1 = double("ReviewResponseMap", :reviewed_object_id => 1, :reviewer_id => 4, :reviewee_id => 2, :calibrate_to => false)
            allow(ReviewResponseMap).to receive(:find_by).and_return(review_response_map1)
            expect(ReviewResponseMap.import(hash,'_session',1)).to eq(['person2'])
          end
        end
      end
    end
  end

  describe "#show_feedback" do
    context "when there is no review responses and the response parameter is nil" do
      it "returns nil" do
        expect(review_response_map.show_feedback(nil)).to eq(nil)
        expect(review_response_map.show_feedback(empty_response)).to eq(nil)
      end
    end

    context "when there exist review responses or the response parameter is not nil" do
      context "when author feedback response map record does not exist or there aren't corresponding responses" do
        it "returns the map variable" do
          allow(review_response_map).to receive_message_chain(:response, :any?) { true }
          allow(FeedbackResponseMap).to receive(:find_by).and_return(feed_back_response_map)
          map = feed_back_response_map
          allow(map).to receive_message_chain(:response, :any?) { false }
          expect(review_response_map.show_feedback(response)).to eq(nil)
        end
      end
    end

    context "when author feedback response map record exists and there exist corresponding responses" do
      it "returns the HTML code which displays the lastest author feedback response" do
        allow(review_response_map).to receive_message_chain(:response, :any?) { true }
        allow(FeedbackResponseMap).to receive(:find_by).and_return(feed_back_response_map)
        map = feed_back_response_map
        allow(map).to receive_message_chain(:response, :any?) { true }
        allow(map).to receive_message_chain(:response, :last).and_return(response)
        expect(review_response_map.show_feedback(response)).to eq("<table width=\"100%\"><tr><td align=\"left\" width=\"70%\"><b>Review </b>&nbsp;&nbsp;&nbsp;<a href=\"#\" name= \"review_1Link\" onClick=\"toggleElement('review_1','review');return false;\">show review</a></td><td align=\"left\"><b>Last Reviewed:</b><span>Not available</span></td></tr></table><table id=\"review_1\" style=\"display: none;\" class=\"table table-bordered\"><tr><td><b>Additional Comment: </b></td></tr></table>")
      end
    end
  end

  describe "#metareview_response_maps" do
    it "returns metareviews related to current review response map" do
      allow(Response).to receive(:where).and_return([response])
      allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([metareview_response_map])
      expect(review_response_map.metareview_response_maps).to eq([metareview_response_map])
    end
  end

  describe ".get_responses_for_team_round" do
    context "when the team id is nil" do
      it "returns an empty array" do
        expect(ReviewResponseMap.get_responses_for_team_round(team1, 1)).to eq([])
      end
    end

    before(:each) do
      team = team1
      allow(team).to receive(:id).and_return(1)
      allow(ResponseMap).to receive(:where).and_return([review_response_map])
      map = review_response_map
      allow(map).to receive(:response).and_return([response])
    end

    context "when the team id is not nil" do
      context "when current response map does not have responses" do
        it "returns an array with satisfied responses" do
          # map = review_response_map
          allow(response).to receive(:any?).and_return(false)
          expect(ReviewResponseMap.get_responses_for_team_round(team1, 1)).to eq([])
        end
      end
    end

    before(:each) do
      allow(response).to receive(:any?).and_return(true)
    end

    context "when current response map has responses" do
      context "when all these responses don't belong to this round or have been submitted" do
        it "returns an array with satisfied responses" do
          allow(response).to receive(:round).and_return(2)
          expect(ReviewResponseMap.get_responses_for_team_round(team1, 1)).to eq([])
        end
      end
    end

    context "when one or more responses belong to this round and haven't been submitted" do
      it "returns an array with satisfied responses" do
        allow(response).to receive(:round).and_return(1)
        allow(response).to receive(:is_submitted).and_return(true)
        expect(ReviewResponseMap.get_responses_for_team_round(team1, 1)).to eq([response])
      end
    end
  end

  describe ".final_versions_from_reviewer" do
    it "returns a hash with the latest version of response for each response map record and corresponding questionnaire ids" do
      review_id = double('1', to_i: 1)
      maps = []
      allow(ReviewResponseMap).to receive(:where).and_return(maps)
      allow(Assignment).to receive(:find).and_return(assignment)
      allow(Participant).to receive_message_chain(:find, :parent_id).and_return(participant)
      expect(ReviewResponseMap.final_versions_from_reviewer(review_id)).to eq(ReviewResponseMap.prepare_final_review_versions(assignment, maps))
      maps = []
      review_final_versions = {}
      round = 2
      allow(assignment).to receive(:rounds_of_reviews).and_return(round)
      expect(ReviewResponseMap.prepare_final_review_versions(assignment, maps)).to \
        eq({:"review round1"=>{:questionnaire_id=>nil, :response_ids=>[]}, :"review round2"=>{:questionnaire_id=>nil, :response_ids=>[]}})
      round = nil
      assignment = double('assignment', round_of_reviews: 3, review_questionnaire_id: 1)
      allow(assignment).to receive(:rounds_of_reviews).and_return(round)
      expect(ReviewResponseMap.prepare_final_review_versions(assignment, maps)).to \
        eq({:review=>{:questionnaire_id=>1, :response_ids=>[]}})
      allow(assignment).to receive(:review_questionnaire_id).and_return(1)
      map = double('map', id: 1)
      maps = [map]
      where_map = {map_id: 1, round: 1}
      responses = []
      round = 1
      allow(Response).to receive(:where).and_return([])
      allow(responses).to receive_message_chain(:last, :id).and_return([])
      expect(ReviewResponseMap.prepare_review_response(assignment, maps, review_final_versions, round)).to eq([])
    end
  end

  describe ".review_response_report" do
    context "when the review user is nil" do
      it "returns sorted reviewers of a certain type of response map" do
        response_maps_with_distinct_participant_id = []
        id = double('id', id: 1)
        type = double('type', type: 'type')
        reviewers = double('reviewers')
        allow(ResponseMap).to receive_message_chain(:select, :where).and_return([review_response_map])
        # allow(ResponseMap).to receive(:each).and_return(1)
        allow(AssignmentParticipant).to receive(:find).and_return([reviewers])
        allow(Participant).to receive(:sort_by_name).and_return([reviewers])
        expect(ReviewResponseMap.review_response_report(id, assignment, type, nil)).to eq([reviewers])
      end
    end

    context "when the review user is not nil" do
      it "return reviewers users' full name" do
        review_user = double('user', :[] => '1')
        user_ids = double('user_ids')
        id = double('id', id: 1)
        type = double('type', type: 'type')
        reviewers = double('reviewers', fullname: 'zhaoke')
        allow(User).to receive_message_chain(:select, :where).and_return([user_ids])
        allow(AssignmentParticipant).to receive(:where).and_return([reviewers])
        expect(ReviewResponseMap.review_response_report(id, assignment, type, review_user)).to eq([reviewers])
      end
    end
  end

  describe "#email" do
    it "sends emails to team members whose work has been reviewed" do
      user = double('user', id: 1)
      defn = {body: {type: "peer review", obj_name: "name1", first_name: "fname", partial_name: "name2"}, to: "email1"}
      allow(AssignmentTeam).to receive_message_chain(:find, :users).and_return([user])
      allow(assignment).to receive(:name).and_return('')
      allow(User).to receive_message_chain(:find, :fullname).and_return('')
      allow(User).to receive_message_chain(:find, :email).and_return('')
      allow(Mailer).to receive_message_chain(:sync_message, :deliver_now).and_return('')
      expect(review_response_map.email(defn, participant, assignment)).to eq([user])
    end
  end
# Write the following two describes in "final_versions_from_reviewer"
  describe ".prepare_final_review_versions" do
    context "when round number is not nil and is bigger than 1" do
      xit "returns the final version of responses in each round" do

      end
    end
    context "when round number is nil or is smaller than or equal to 1" do
      xit "returns the final version of responses" do
        
      end
    end
  end

  describe ".prepare_review_response" do
    context "when the round is nil" do
      xit "uses :review as hash key and populate the hash with review questionnaire id and response ids" do
        # symbol = :review
        # review_final_versions = {symbol: {questionnaire_id: 1, response_ids: 1}}
        # where_map = {}
        # responses = 1

      end
    end
    context "when the round is not nil" do
      xit "uses review round number as hash key and populate the hash with review questionnaire id, round, and response ids" do
        # round = 1
        # symbol = ("review round" + round.to_s).to_sym
        # review_final_versions = {symbol: {questionnaire_id: 1, response_ids: 1}}
        # where_map = {}
        # responses = 1
        # allow(assignment).to receive(:review_questionnaire_id).and_return(1)
        # allow(Response).to receive(:where).and_return(1)
      end
    end
  end
end
