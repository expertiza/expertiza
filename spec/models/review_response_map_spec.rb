describe ReviewResponseMap do

  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name', assignment: assignment, users: [student]) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:review_response_map1) do
    build :review_response_map,
          id: 2,
          assignment: assignment,
          reviewer: participant1,
          reviewee: team1,
          reviewed_object_id: 1,
          response: [response],
          calibrate_to: 0
  end
  let(:feedback) { FeedbackResponseMap.new(id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: student1) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: review_response_map,  is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 1, round: 2, response_map: review_response_map) }
  let(:response2) { build(:response, id: 3, map_id: 1, round: nil, response_map: review_response_map, is_submitted: true) }
  let(:metareview_response_map) { build(:meta_review_response_map, reviewed_object_id: 1) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, name: "name1", fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:questionnaire) { Questionnaire.new(id: 1, type: 'ReviewQuestionnaire') }
  let(:deadline_type) { build(:deadline_type, id: 1) }

  before(:each) do
    allow(review_response_map).to receive(:response).and_return(response)
  end

  describe '#questionnaire' do

    # This method is little more than a wrapper for assignment.review_questionnaire_id()
    # So it will be tested relatively lightly
    # We want to know how it responds to the combinations of various arguments it could receive
    # We want to know how it responds if no questionnaire can be found
    before(:each) do
      @assignment = create(:assignment)
      @review_response_map = create(:review_response_map, assignment: @assignment)
      @questionnaire1 = create(:questionnaire, type: 'ReviewQuestionnaire')
      @questionnaire2 = create(:questionnaire, type: 'MetareviewQuestionnaire')
      @questionnaire3 = create(:questionnaire, type: 'AuthorFeedbackQuestionnaire')
      @questionnaire4 = create(:questionnaire, type: 'TeammateReviewQuestionnaire')
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 1, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 2, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 3, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 4, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 1, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 2, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 3, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 4, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 1, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 2, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 3, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 4, topic_id: nil)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: nil, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: nil, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: nil, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 1, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 1, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 1, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 1, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 2, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 2, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 2, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 2, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 3, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 3, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 3, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 3, topic_id: 4)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 4, topic_id: 1)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire3, used_in_round: 4, topic_id: 2)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire4, used_in_round: 4, topic_id: 3)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire2, used_in_round: 4, topic_id: 4)
    end

    it 'returns correct questionnaire found by used_in_round and topic_id when both are given and assignment varies by both' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 1)
      expect(@review_response_map.questionnaire(1, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 2)
      expect(@review_response_map.questionnaire(1, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 3)
      expect(@review_response_map.questionnaire(1, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: 4)
      expect(@review_response_map.questionnaire(1, 4)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 1)
      expect(@review_response_map.questionnaire(2, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 2)
      expect(@review_response_map.questionnaire(2, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 3)
      expect(@review_response_map.questionnaire(2, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 4)
      expect(@review_response_map.questionnaire(2, 4)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 1)
      expect(@review_response_map.questionnaire(3, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 2)
      expect(@review_response_map.questionnaire(3, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 3)
      expect(@review_response_map.questionnaire(3, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: 4)
      expect(@review_response_map.questionnaire(3, 4)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 1)
      expect(@review_response_map.questionnaire(4, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 2)
      expect(@review_response_map.questionnaire(4, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 3)
      expect(@review_response_map.questionnaire(4, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: 4)
      expect(@review_response_map.questionnaire(4, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by used_in_round when used_in_round only is given but assignment varies by both round and topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: nil)
      expect(@review_response_map.questionnaire(1, nil)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: nil)
      expect(@review_response_map.questionnaire(2, nil)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: nil)
      expect(@review_response_map.questionnaire(3, nil)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: nil)
      expect(@review_response_map.questionnaire(4, nil)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by used_in_round when both used_in_round and topic_id are given but assignment varies only by round' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 1, topic_id: nil)
      expect(@review_response_map.questionnaire(1, anything)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: nil)
      expect(@review_response_map.questionnaire(2, anything)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 3, topic_id: nil)
      expect(@review_response_map.questionnaire(3, anything)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 4, topic_id: nil)
      expect(@review_response_map.questionnaire(4, anything)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by topic_id when topic_id only is given and there is no current round used in the due date and assignment varies by both round and topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 1)
      expect(@review_response_map.questionnaire(nil, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 2)
      expect(@review_response_map.questionnaire(nil, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 3)
      expect(@review_response_map.questionnaire(nil, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 4)
      expect(@review_response_map.questionnaire(nil, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by topic_id when both used_in_round and topic_id are given and there is no current round used in the due date but assignment varies only by topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(false)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 1)
      expect(@review_response_map.questionnaire(anything, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 2)
      expect(@review_response_map.questionnaire(anything, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 3)
      expect(@review_response_map.questionnaire(anything, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: 4)
      expect(@review_response_map.questionnaire(anything, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by current round used in the due date when neither used_in_round nor topic_id are not given, but assignment varies only by round' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_due_date, assignment: @assignment, round: 2)
      allow(DeadlineType).to receive(:find_by).with(name: 'review').and_return(deadline_type)
      allow(DeadlineType).to receive(:find_by).with(name: 'submission').and_return(deadline_type)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: nil)
      expect(@review_response_map.questionnaire(nil, anything)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by current round used in the due date when topic_id only is given, but assignment varies by both round and topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(true)
      allow(@assignment).to receive(:vary_by_topic).and_return(true)
      create(:assignment_due_date, assignment: @assignment, round: 2)
      allow(DeadlineType).to receive(:find_by).with(name: 'review').and_return(deadline_type)
      allow(DeadlineType).to receive(:find_by).with(name: 'submission').and_return(deadline_type)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 1)
      expect(@review_response_map.questionnaire(nil, 1)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 2)
      expect(@review_response_map.questionnaire(nil, 2)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 3)
      expect(@review_response_map.questionnaire(nil, 3)).to eq @questionnaire1
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: 2, topic_id: 4)
      expect(@review_response_map.questionnaire(nil, 4)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by type when neither used_in_round nor topic_id are given and assignment does not vary by either round or topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(false)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: nil)
      expect(@review_response_map.questionnaire(nil, nil)).to eq @questionnaire1
    end

    it 'returns correct questionnaire found by type when both used_in_round and topic_id are given but assignment does not vary by either round or topic' do
      allow(@assignment).to receive(:vary_by_round).and_return(false)
      allow(@assignment).to receive(:vary_by_topic).and_return(false)
      create(:assignment_questionnaire, assignment: @assignment, questionnaire: @questionnaire1, used_in_round: nil, topic_id: nil)
      expect(@review_response_map.questionnaire(anything, anything)).to eq @questionnaire1
    end

    it 'should not return nil or result in any error since all possible AQs and questionnaires must be accessible via Active Record' do
      # All below cases are not possible for a given DB state
      #expect(self_review_response_map.questionnaire(5, anything)).to eq nil
      #expect(self_review_response_map.questionnaire(anything, 5)).to eq nil
    end

  end

  it '#get_title' do
    expect(review_response_map.get_title).to eq("Review")
  end

  it '#delete' do
    allow(Response).to receive(:find).and_return(response)
    allow(FeedbackResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([feedback])
    allow(MetareviewResponseMap).to receive(:where).and_return([metareview_response_map])
    expect(review_response_map.delete).to equal(review_response_map)
  end

  it '#export_fields' do
    expect(ReviewResponseMap.export_fields('options')).to eq(["contributor", "reviewed by"])
  end

  it '#export' do
    csv = []
    parent_id = 1
    options = nil
    allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([review_response_map, review_response_map1])
    expect(ReviewResponseMap.export(csv, parent_id, options)).to eq([review_response_map1, review_response_map])
  end

  it '#import' do
    row_hash = {reviewee: "name", reviewers: ["name1"]}
    session = nil
    assignment_id = 1
    # when reviewee user = nil
    allow(User).to receive(:find_by).and_return(nil)
    expect { ReviewResponseMap.import(row_hash, session, 1) }.to raise_error(ArgumentError, "Cannot find reviewee user.")
    # when reviewee user exists but reviewee user is not a participant in this assignment
    allow(User).to receive(:find_by).with(name: "name").and_return(student)
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(nil)
    expect { ReviewResponseMap.import(row_hash, session, 1) }.to raise_error(ArgumentError, "Reviewee user is not a participant in this assignment.")
    # when reviewee user exists and reviewee user is a participant in this assignment
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(participant)
    allow(AssignmentTeam).to receive(:team).with(participant).and_return(team)
    ## when reviewer user doesn't exist
    allow(User).to receive(:find_by).with(name: "name1").and_return(nil)
    expect { ReviewResponseMap.import(row_hash, session, 1) }.to raise_error(ArgumentError, "Cannot find reviewer user.")
    ## when reviewer user exist
    allow(User).to receive(:find_by).with(name: "name1").and_return(student1)
    ### when reviewer user is not a participant in this assignment.
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 2, parent_id: 1).and_return(nil)
    expect { ReviewResponseMap.import(row_hash, session, 1) }.to raise_error(ArgumentError, "Reviewer user is not a participant in this assignment.")
    ### when reviewer user is a participant in this assignment.
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 2, parent_id: 1).and_return(participant1)
    allow(ReviewResponseMap).to receive(:find_or_create_by)
      .with(reviewed_object_id: 1, reviewer_id: 2, reviewee_id: 1, calibrate_to: false)
      .and_return(review_response_map)
    expect(ReviewResponseMap.import(row_hash, session, 1)).to eq(["name1"])
    # when reviewee_team = nil
    allow(AssignmentTeam).to receive(:team).with(participant).and_return(nil)
    allow(AssignmentTeam).to receive(:create).and_return(double('team', id: 1))
    allow(TeamsUser).to receive(:create).with(team_id: 1, user_id: 1).and_return(double('teams_users', id: 1, team_id: 1, user_id: 1))
    allow(TeamNode).to receive(:create).with(parent_id: assignment_id, node_object_id: 1).and_return(double('team_node', id: 1, parent_id: 1, node_object_id: 1))
    allow(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: 1).and_return(double('team_user_node', id: 1, parent_id: 1, node_object_id: 1))
    allow(User).to receive(:find_by).with(name: "name1").and_return(student1)
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 2, parent_id: 1).and_return(participant1)
    allow(ReviewResponseMap).to receive(:find_or_create_by)
      .with(reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1, calibrate_to: false).and_return(review_response_map)
    expect(ReviewResponseMap.import(row_hash, session, 1)).to eq(["name1"])
  end

  it '#show_feedback' do
    allow(review_response_map).to receive(:response).and_return([response])
    allow(Response).to receive(:find).and_return(response)
    allow(FeedbackResponseMap).to receive(:find_by).with(reviewed_object_id: 1).and_return(feedback)
    allow(feedback).to receive(:response).and_return([response])
    expect(review_response_map.show_feedback(response)).to eq("<table width=\"100%\"><tr><td align=\"left\" width=\"70%\"><b>Review </b>"\
        "&nbsp;&nbsp;&nbsp;<a href=\"#\" name= \"review_1Link\" onClick=\"toggleElement('review_1','review');return false;\">"\
        "show review</a></td><td align=\"left\"><b>Last Reviewed:</b><span>Not available</span></td></tr></table><table id=\"review_1\""\
        " style=\"display: none;\" class=\"table table-bordered\"><tr><td><b>"\
        "Additional Comment: </b></td></tr></table>")
  end

  it '#metareview_response_maps' do
    allow(Response).to receive(:where).with(map_id: 1).and_return([response])
    allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([metareview_response_map])
    expect(review_response_map.metareview_response_maps).to eq([metareview_response_map])
  end

  it '#get_responses_for_team_round' do
    allow(Team).to receive(:find).and_return(team)
    round = 1
    allow(ResponseMap).to receive(:where).with(reviewee_id: team.id, type: "ReviewResponseMap").and_return([review_response_map1])
    expect(ReviewResponseMap.get_responses_for_team_round(team, 1)).to eq([response])
  end

  it '#final_versions_from_reviewer' do
    reviewer_id = 1
    allow(ReviewResponseMap).to receive(:where).with(reviewer_id: 1).and_return([review_response_map])
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(participant).to receive(:parent_id).and_return(1)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(Response).to receive(:where).with(map_id: 1, round: 1).and_return([response])
    allow(assignment).to receive(:review_questionnaire_id).with(1).and_return(1)
    allow(Response).to receive(:where).with(map_id: 1, round: 2).and_return([response1])
    allow(assignment).to receive(:review_questionnaire_id).with(2).and_return(1)
    expect(ReviewResponseMap.final_versions_from_reviewer(1))
      .to eq("review round1": {questionnaire_id: 1, response_ids: [1]}, "review round2": {questionnaire_id: 1, response_ids: [2]})
  end

  it '#review_response_report' do
    id = 1
    type = "MetareviewResponseMap"
    reviewer_id = 1
    user_ids = []
    review_user = student
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(User).to receive_message_chain(:select, :where).and_return([student])
    allow(AssignmentParticipant).to receive(:where).and_return([participant])
    expect(ReviewResponseMap.review_response_report(id, Assignment.find(Participant.find(reviewer_id).parent_id), type, review_user)).to eq([participant])
    review_user = nil
    allow(ResponseMap).to receive_message_chain(:select, :where).and_return([review_response_map])
    allow([review_response_map]).to receive(:reviewer_id).and_return(1)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return([participant])
    allow(Participant).to receive(:sort_by_name).and_return([participant])
    expect(ReviewResponseMap.review_response_report(id, Assignment.find(Participant.find(reviewer_id).parent_id), type, review_user)).to eq([participant])
  end

  it '#email' do
    reviewer_id = 1
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(AssignmentTeam).to receive(:find).with(1).and_return(team)
    allow(AssignmentTeam).to receive(:users).and_return(student)
    allow(User).to receive(:find).with(1).and_return(student)
    review_response_map.reviewee_id = 1
    defn = {body: {type: "Peer Review", obj_name: "Test Assgt", first_name: "no one", partial_name: "new_submission"}, to: "expertiza@mailinator.com"}
    expect { review_response_map.email(defn, participant, Assignment.find(Participant.find(reviewer_id).parent_id)) }
      .to change { ActionMailer::Base.deliveries.count }.by 1
  end

  it '#prepare_final_review_versions' do
    review_final_versions = {}
    reviewer_id = 1
    allow(metareview_response_map).to receive(:id).and_return(1)
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([metareview_response_map])
    allow(Response).to receive(:where).with(map_id: 1, round: 1).and_return([response])
    allow(assignment).to receive(:review_questionnaire_id).with(1).and_return(1)
    allow(Response).to receive(:where).with(map_id: 1, round: 2).and_return([response1])
    allow(assignment).to receive(:review_questionnaire_id).with(2).and_return(1)
    current_assignment = Assignment.find(Participant.find(reviewer_id).parent_id)
    meta_review_response_maps = MetareviewResponseMap.where(reviewed_object_id: 1)
    expect(ReviewResponseMap.prepare_final_review_versions(current_assignment, meta_review_response_maps))
      .to eq("review round1": {questionnaire_id: 1, response_ids: [1]}, "review round2": {questionnaire_id: 1, response_ids: [2]})
    # when round = nil
    reviewer_id = 2
    allow(Participant).to receive(:find).with(2).and_return(participant1)
    allow(Assignment).to receive(:find).with(2).and_return(assignment1)
    allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([metareview_response_map])
    allow(assignment).to receive(:review_questionnaire_id).with(nil).and_return(1)
    allow(Response).to receive(:where).with(map_id: 1).and_return([response2])
    current_assignment = Assignment.find(Participant.find(reviewer_id).parent_id)
    meta_review_response_maps = MetareviewResponseMap.where(reviewed_object_id: 1)
    expect(ReviewResponseMap.prepare_final_review_versions(current_assignment, meta_review_response_maps))
      .to eq(review: {questionnaire_id: nil, response_ids: [3]})
  end

  it '#prepare_review_response' do
    review_final_versions = {}
    review_response_map.id = 1
    round = 1
    maps = [review_response_map]
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(Response).to receive(:where).with(map_id: 1, round: 1).and_return([response])
    expect(ReviewResponseMap.prepare_review_response(assignment, maps, review_final_versions, round)).to eq([1])
    round = nil
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(Response).to receive(:where).with(map_id: 1).and_return([response2])
    expect(ReviewResponseMap.prepare_review_response(assignment, maps, review_final_versions, round)).to eq([3])
  end
end
