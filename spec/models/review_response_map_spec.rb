describe 'ReviewResponseMap' do
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:participant2) { build(:participant, id: 2, parent_id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:student) { build(:participant, id: 3, parent_id: 1, user: build(:student, name: 'no name', fullname: 'first user')) }
  let(:student2) { build(:participant, id: 4, parent_id: 1, user: build(:student, name: 'no name', fullname: 'second one')) }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:assignment2) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:response_map) { build(:review_response_map, reviewer: student, response: [response], reviewee_id: 1, type: "ReviewResponseMap") }
  let(:response_map2) { build(:review_response_map, reviewer: student2, response: [response2, response3], reviewee_id: 1, type: "ReviewResponseMap") }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, round: 1, is_submitted: true, scores: [answer]) }
  let(:null_response) { double(:response) }
  let(:response2) { build(:response, id: 2, round: 1, is_submitted: true, map_id: 1, scores: [answer]) }
  let(:response3) { build(:response, id: 3, round: 1, is_submitted: false, map_id: 1, scores: [answer]) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:review_response_map2) { build(:review_response_map, assignment: assignment2, reviewer: participant2, reviewee: team) }
  let(:meta_review_response_map) { build(:meta_review_response_map, id: 1, reviewed_object_id: 1, review_mapping: review_response_map, reviewee: participant) }
  let(:feedback_response_map) { build(:review_response_map, response: [response2, response3], type: 'FeedbackResponseMap') }
  let(:metareview_response_map) { double('somemap') }

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
      expect(ReviewResponseMap.export_fields("")).to eq(["contributor", "reviewed by"])
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
      expect(review_response_map.delete).to be(true)
    end
  end

  describe '.get_responses_for_team_round' do
    context 'when team doesnt exist' do
      it 'returns empty response' do
        team = instance_double('AssignmentTeam').as_null_object
        allow(team).to receive(:id).and_return(false)
        expect(ReviewResponseMap.get_responses_for_team_round(team, 1)).to eql([])
      end
    end

    context 'when team exists' do
      it 'returns the responses for particular round' do
        team = instance_double('AssignmentTeam', id: 1)
        round = 1
        allow(ResponseMap).to receive(:where).with(reviewee_id: 1, type: "ReviewResponseMap").and_return([response_map, response_map2])
        expect(ReviewResponseMap.get_responses_for_team_round(team, round).length).to eql(2)
      end
    end
  end

  describe '.export' do
    it 'adds reviewer and reviewee names to array' do
      allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([review_response_map])
      expect(ReviewResponseMap.export([], 1, 'test')).to eql([review_response_map])
    end
  end

  describe '#metareview_response_maps' do
    it 'returns metareview responses for which id is caller id' do
      allow(Response).to receive(:where).with(map_id: 1).and_return([response])
      allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([metareview_response_map])
      expect(review_response_map.metareview_response_maps).to eq([metareview_response_map])
    end
  end

  describe '#show_feedback' do
    context 'when no response is present or response is nil' do
      it 'returns nil' do
        allow(review_response_map).to receive(:response).and_return([])
        expect(review_response_map.show_feedback(null_response)).to be(nil)
      end
    end

    context 'when response is present and not nil' do
      it 'returns feedback' do
        allow(review_response_map).to receive(:response).and_return([response2, response3])
        allow(FeedbackResponseMap).to receive(:find_by).with(reviewed_object_id: 1).and_return(feedback_response_map)
        allow(response3).to receive(:display_as_html).and_return("display_as_html")
        expect(review_response_map.show_feedback(response)).to eql("display_as_html")
      end
    end
  end

  describe '.final_versions_from_reviewer' do
    it 'returns final versions from reviewer' do
      allow(ReviewResponseMap).to receive(:where).with(reviewer_id: 1).and_return([review_response_map, review_response_map2])
      allow(Participant).to receive(:find).with(1).and_return(participant)
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(ReviewResponseMap).to receive(:prepare_final_review_versions)
        .with(assignment, [review_response_map, review_response_map2])
        .and_return("prepare_final_review_versions")
      expect(ReviewResponseMap.final_versions_from_reviewer(1)).to eql("prepare_final_review_versions")
    end
  end

  describe '.import' do
    context 'when reviewee is nil' do
      test_hash = {reviewee: 'user1', reviewers: ['user2']}
      it 'raises an ArgumentError' do
        allow(User).to receive(:find_by).and_return(nil)
        expect { ReviewResponseMap.import(test_hash, '_session', 1) }.to raise_error(ArgumentError)
      end
    end

    context 'when the reviewee is not nil' do
      context 'when participant is nil' do
        test_hash = {reviewee: 'user1', reviewers: ['user2']}
        it "Raises another ArgumentError" do
          reviewee = double('User', id: 1, name: 'user1')
          allow(User).to receive(:find_by).with(name: 'user1').and_return(reviewee)
          allow(AssignmentParticipant).to receive(:find_by).and_return(nil)
          expect { ReviewResponseMap.import(test_hash, '_session', 1) }.to raise_error(ArgumentError)
        end
      end

      context 'when the participant is not nil' do
        before(:each) do
          reviewee = double('User', id: 2, name: 'user1')
          allow(User).to receive(:find_by).with(name: 'user1').and_return(reviewee)
          reviewee_participant = double('AssignmentParticipant', user_id: 2, parent_id: 1, id: 3)
          allow(AssignmentParticipant).to receive(:find_by).and_return(reviewee_participant)
          reviewer = double('User', id: 4, name: 'user2')
          allow(User).to receive(:find_by).with(name: 'user2').and_return(reviewer)
          reviewer_participant = double('AssignmentParticipant', user_id: 4, parent_id: 1, id: 5)
          allow(AssignmentParticipant).to receive(:where).and_return(reviewer_participant)
        end

        context 'when reviewee has no team' do
          it "creates a team for reviewee via lazy team creation" do
            test_hash = {reviewee: 'user1', reviewers: ['user2']}
            allow(AssignmentTeam).to receive(:team).and_return(nil)
            reviewee_team = double('AssignmentTeam', name: 'Team_1', parent_id: 1, id: 2)
            allow(AssignmentTeam).to receive(:create).and_return(reviewee_team)
            team_user = double('TeamUser', team_id: 2, user_id: 2, id: 10)
            allow(TeamsUser).to receive(:create).and_return(team_user)
            team_node = double('TeamNode', parent_id: 1, node_object_id: 2, id: 6)
            allow(TeamNode).to receive(:create).and_return(team_node)
            team_user_node = double('TeamUserNode', parent_id: 4, node_object_id: 10)
            allow(TeamUserNode).to receive(:create).and_return(team_user_node)
            map1 = double('ReviewResponseMap', reviewed_object_id: 1, reviewer_id: 4, reviewee_id: 2, calibrate_to: false)
            allow(ReviewResponseMap).to receive(:find_by).and_return(map1)
            expect(ReviewResponseMap.import(test_hash, '_session', 1)).to eq(['user2'])
          end
        end

        context 'when reviewee has a team' do
          it "creates a review response map" do
            test_hash = {reviewee: 'user1', reviewers: ['user2']}
            reviewee_team = double('AssignmentTeam', parent_id: 1, id: 2)
            allow(AssignmentTeam).to receive(:team).and_return(reviewee_team)
            map1 = double('ReviewResponseMap', reviewed_object_id: 1, reviewer_id: 4, reviewee_id: 2, calibrate_to: false)
            allow(ReviewResponseMap).to receive(:find_by).and_return(map1)
            expect(ReviewResponseMap.import(test_hash, '_session', 1)).to eq(['user2'])
          end
        end
      end
    end
  end

  describe ".review_response_report" do
    context "when the user is nil" do
      it "gives participants with unique IDs in a sorted order" do
        temp_id = double('id', id: 1)
        temp_type = double('type', type: 'type')
        temp_reviewers = double('reviewers')
        # Stubbing call to the database source: https://relishapp.com/rspec/rspec-mocks/docs/working-with-legacy-code/message-chains
        allow(ResponseMap).to receive_message_chain(:select, :where).and_return([response_map])
        allow(AssignmentParticipant).to receive(:find).and_return([temp_reviewers])
        allow(Participant).to receive(:sort_by_name).and_return([temp_reviewers])
        expect(ReviewResponseMap.review_response_report(temp_id, assignment, temp_type, nil)).to eq([temp_reviewers])
      end
    end

    context "when the user is not nil" do
      it "gives reviewers users' full name" do
        temp_user = double('user', :[] => '1')
        # Mocking user ids
        temp_user_ids = double('user_ids')
        temp_id = double('id', id: 1)
        temp_type = double('type', type: 'type')
        temp_reviewers = double('reviewers', fullname: 'testName')
        allow(User).to receive_message_chain(:select, :where).and_return([temp_user_ids])
        allow(AssignmentParticipant).to receive(:where).and_return([temp_reviewers])
        expect(ReviewResponseMap.review_response_report(temp_id, assignment, temp_type, temp_user)).to eq([temp_reviewers])
      end
    end
  end

  describe "#email" do
    it "notifies the reviewee of the new review submitted" do
      temp_user = double('user', id: 1)
      defn = {body: {type: "test type", obj_name: "test name", first_name: "test name", partial_name: "test name"}, to: "test@email.com"}
      allow(AssignmentTeam).to receive_message_chain(:find, :users).and_return([temp_user])
      allow(assignment).to receive(:name).and_return('')
      allow(User).to receive_message_chain(:find, :fullname).and_return('')
      allow(User).to receive_message_chain(:find, :email).and_return('')
      allow(Mailer).to receive_message_chain(:sync_message, :deliver_now).and_return('')
      expect(review_response_map.email(defn, participant, assignment)).to eq([temp_user])
    end
  end

  describe '.prepare_final_review_versions' do
    context 'if the round number is greater than 1' do
      it "returns updated version of review" do
        maps = []
        round_num = 2
        allow(assignment).to receive(:rounds_of_reviews).and_return(round_num)
        # Mocking reviews for two rounds
        expect(ReviewResponseMap.prepare_final_review_versions(assignment, maps))
          .to eql(:"review round1" => {questionnaire_id: nil, response_ids: []}, :"review round2" => {questionnaire_id: nil, response_ids: []})
      end
    end

    context 'if the round number is not greater than 1' do
      it "returns latest version of review" do
        maps = []
        round_num = nil
        temp_assignment = double(:assignment, round_of_reviews: 5, review_questionnaire_id: 2)
        allow(temp_assignment).to receive(:rounds_of_reviews).and_return(round_num)
        expect(ReviewResponseMap.prepare_final_review_versions(temp_assignment, maps)).to eql(review: {questionnaire_id: 2, response_ids: []})
      end
    end
  end

  describe '.prepare_review_response' do
    context 'if the round is nil' do
      it 'should return the latest response Id' do
        round_num = nil
        maps = []
        temp_assignment = double(:assignment, review_questionnaire_id: 1)
        allow(temp_assignment).to receive(:rounds_of_reviews).and_return(round_num)
        expect(ReviewResponseMap.prepare_final_review_versions(temp_assignment, maps)).to eql(review: {questionnaire_id: 1, response_ids: []})
        allow(temp_assignment).to receive(:review_questionnaire_id).and_return(1)
      end
    end

    context 'if the round is not nil' do
      it 'should return the latest response Id' do
        review_final_versions = {}
        maps = [double(:map, id: 1)]
        responses = []
        round_num = 1
        allow(Response).to receive(:where).and_return([])
        allow(responses).to receive_message_chain(:last, :id).and_return([])
        expect(ReviewResponseMap.prepare_review_response(assignment, maps, review_final_versions, round_num)).to eq([])
      end
    end
  end
end
