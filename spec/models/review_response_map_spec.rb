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

  before(:each) do
    allow(review_response_map).to receive(:response).and_return(response)
  end

  it '#questionnaire' do
    allow(assignment).to receive(:review_questionnaire_id).and_return(1)
    allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire)
    expect(review_response_map.questionnaire(1)).to eq(questionnaire)
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
        "hide review</a></td><td align=\"left\"><b>Last Reviewed:</b><span>Not available</span></td></tr></table><table id=\"review_1\""\
        " class=\"table table-bordered\"><tr><td><b>"\
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
