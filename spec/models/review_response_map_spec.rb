describe ReviewResponseMap do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  #
  # E1850. Write unit tests for review_response_map.rb
  # Unity ID:
  # hfan4
  # pchen23
  # yyang53
  #
  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name', assignment: assignment, users: [student]) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant, reviewee: team, reviewed_object_id: 1) }
  let(:review_response_map1) { build(:review_response_map, id: 2, assignment: assignment, reviewer: participant1, reviewee: team1, reviewed_object_id: 1) }
  let(:feed_back_response_map) { double('feed_back_response_map', reviewed_object_id: 1) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: build(:student, parent_id: 1, name: 'no name', fullname: 'no one')) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: build(:student, parent_id: 1, name: 'has name', fullname: 'has one')) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2 ) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1 ) }
  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: review_response_map,  is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 1, round: 2, response_map: review_response_map) }
  let(:response2) { build(:response, id: 3, map_id: 1, round: nil, response_map: review_response_map, is_submitted: true) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:feedback) { FeedbackResponseMap.new(id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:metareview_response_map) { double('metareviewmap')}
  let(:metareview_response_map1) { MetareviewResponseMap.new(reviewed_object_id: 1) }
  let(:student) {build(:student, id: 1, fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment_questionnaire){ AssignmentQuestionnaire.new(assignment_id: 1, used_in_round: 1, questionnaire_id: 1) }
  let(:assignment_questionnaire1){ AssignmentQuestionnaire.new(assignment_id: 1, used_in_round: 2, questionnaire_id: 1) }
  let(:questionnaire1) { Questionnaire.new(id: 1, type: 'ReviewQuestionnaire') }
  let(:response_map) do  ResponseMap.new(id: 1, reviewed_object_id: 1, reviewee_id: 1, reviewer_id: 1,
                                         type: "ReviewResponseMap", response: [response], calibrate_to: 0)
  end
  let(:user) {User.new(id:1 , name: "name", fullname: 'fullname') }
  let(:user1) { User.new(id: 2, name: "name1", fullname: 'fullname') }
  let(:assignment_participant) { AssignmentParticipant.new(user_id: 1, parent_id: 1) }
  let(:assignment_participant1) { AssignmentParticipant.new(id: 1, user_id: 2, parent_id: 1) }
  let(:teams_users) {TeamsUser.new(user_id: 1, team_id: 1)}

  before(:each) do
    allow(response).to receive(:map).and_return(review_response_map)
    allow(review_response_map).to receive(:response).and_return(response)
  end

  it '#questionnaire' do
    round = 1
    allow(assignment).to receive(:review_questionnaire_id).with(1).and_return(1)
    allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
    expect(review_response_map.questionnaire(1)).to eq(questionnaire1)
  end

  it '#get_title' do
    expect(review_response_map.get_title).to eq("Review")
  end

  it '#delete' do
    # response_map = double("ResponseMap", :reviewed_object_id => 2)
    # expect(review_response_map.delete).to equal(review_response_map)
    allow(Response).to receive(:find).and_return(response)
    allow(FeedbackResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([feedback])
    allow(MetareviewResponseMap).to receive(:where).and_return([metareview_response_map1])
    expect(review_response_map.delete).to equal(review_response_map)


  end


  it '#export_fields' do
    expect(ReviewResponseMap.export_fields('Missing "_options"')).to eq(["contributor", "reviewed by"])
  end

  it '#export' do
    csv = []
    parent_id = 1
    _options = _options
    allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([review_response_map, review_response_map1])
    expect(ReviewResponseMap.export(csv, parent_id, _options)).to eq([review_response_map1, review_response_map])
  end

  it '#import' do
    row_hash={reviewee: "name", reviewers: ["name1"]}
    _session = nil
    assignment_id = 1
    allow(User).to receive(:find_by).with(name: "name").and_return(user)
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 1).and_return(assignment_participant)
    allow(AssignmentTeam).to receive(:team).with(assignment_participant).and_return(team)
    allow(User).to receive(:find_by).with(name: "name1").and_return(user1)
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 2, parent_id: 1).and_return(assignment_participant1)
    allow(ReviewResponseMap).to receive(:find_or_create_by).with(reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1,
                                                                 calibrate_to: false).and_return(review_response_map)
    expect(ReviewResponseMap.import(row_hash, _session, 1)).to eq(["name1"])
    # when reviewee_team = nil
    allow(AssignmentTeam).to receive(:team).with(assignment_participant).and_return(nil)
    allow(AssignmentTeam).to receive(:create).and_return(double('team', id: 1))
    allow(TeamsUser).to receive(:create).with(team_id: 1, user_id: 1).and_return(double('teams_users', id: 1, team_id: 1, user_id: 1))
    allow(TeamNode).to receive(:create).with(parent_id: assignment_id, node_object_id: 1).and_return(double('team_node',
                                                                                                            id: 1, parent_id: 1, node_object_id: 1))
    allow(TeamUserNode).to receive(:create).with(parent_id: 1, node_object_id: 1).and_return(double('team_user_node',
                                                                                                    id: 1, parent_id: 1, node_object_id: 1))
    allow(User).to receive(:find_by).with(name: "name1").and_return(user1)
    allow(AssignmentParticipant).to receive(:find_by).with(user_id: 2, parent_id: 1).and_return(assignment_participant1)
    allow(ReviewResponseMap).to receive(:find_or_create_by).with(reviewed_object_id: 1, reviewer_id: 1,
                                                                 reviewee_id: 1, calibrate_to: false).and_return(review_response_map)
    expect(ReviewResponseMap.import(row_hash, _session, 1)).to eq(["name1"])
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
    allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([metareview_response_map1])
    expect(review_response_map.metareview_response_maps).to eq([metareview_response_map1])
  end

  it '#get_responses_for_team_round' do
    allow(Team).to receive(:find).and_return(team)
    allow(team).to receive(:id).and_return(1)
    round = 1
    allow(ResponseMap).to receive(:where).with(reviewee_id: team.id, type: "ReviewResponseMap").and_return([response_map])
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
    expect(ReviewResponseMap.final_versions_from_reviewer(1)).to eq("review round1": {questionnaire_id: 1, response_ids: [1]}, "review round2": {questionnaire_id: 1, response_ids: [2] })
  end

  it '#review_response_report' do
    id = 1
    type = "MetareviewResponseMap"
    reviewer_id = 1
    user_ids = []
    review_user = user
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    # allow(User).to receive(:where).with('fullname LIKE ?', '%' + review_user[:fullname] + '%').and_return([user])
    # allow([user]).to receive(:select).with('DISTINCT id').and_return([user])

    allow(User).to receive_message_chain(:select, :where).and_return([user])
    allow(AssignmentParticipant).to receive(:where).and_return([assignment_participant])
    expect(ReviewResponseMap.review_response_report(id, Assignment.find(Participant.find(reviewer_id).parent_id), type, review_user)).to eq( [assignment_participant] )
    review_user = nil
    # allow(ResponseMap).to receive(:where).with('reviewed_object_id = ? and type = ? and calibrate_to = ?', id, type, 0).and_return([response_map])
    # allow([response_map]).to receive(:select).with('DISTINCT reviewer_id').and_return([response_map])

    allow(ResponseMap).to receive_message_chain(:select, :where).and_return([response_map])
    allow([response_map]).to receive(:reviewer_id).and_return(1)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return([assignment_participant])
    allow(Participant).to receive(:sort_by_name).and_return([assignment_participant])
    expect(ReviewResponseMap.review_response_report(id, Assignment.find(Participant.find(reviewer_id).parent_id), type, review_user)).to eq( [assignment_participant] )
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
    expect{review_response_map.email(defn, participant, Assignment.find(Participant.find(reviewer_id).parent_id)) }.to change { ActionMailer::Base.deliveries.count }.by (1)
  end

  it '#prepare_final_review_versions' do
    review_final_versions = {}
    reviewer_id = 1
    allow(metareview_response_map1).to receive(:id).and_return(1)
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id:1).and_return([metareview_response_map1])
    allow(Response).to receive(:where).with(map_id: 1, round: 1).and_return([response])
    allow(assignment).to receive(:review_questionnaire_id).with(1).and_return(1)
    allow(Response).to receive(:where).with(map_id: 1, round: 2).and_return([response1])
    allow(assignment).to receive(:review_questionnaire_id).with(2).and_return(1)
    expect(ReviewResponseMap.prepare_final_review_versions(Assignment.find(Participant.find(reviewer_id).parent_id),
                                                           MetareviewResponseMap.where(reviewed_object_id: 1))).to eq("review round1": {questionnaire_id: 1, response_ids: [1]}, "review round2": {questionnaire_id: 1, response_ids: [2]})
    # when round = nil
    reviewer_id = 2
    allow(Participant).to receive(:find).with(2).and_return(participant1)
    allow(Assignment).to receive(:find).with(2).and_return(assignment1)
    allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id:1).and_return([metareview_response_map1])

    allow(assignment).to receive(:review_questionnaire_id).with(nil).and_return(1)
    allow(Response).to receive(:where).with(map_id: 1).and_return([response2])
    expect(ReviewResponseMap.prepare_final_review_versions(Assignment.find(Participant.find(reviewer_id).parent_id),
                                                           MetareviewResponseMap.where(reviewed_object_id: 1))).to eq(review:{questionnaire_id: nil,
                                                                                                                              response_ids: [3]})

  end

  it '#prepare_review_response' do
    review_final_versions = {}
    review_response_map.id = 1
    round = 1
    maps = [review_response_map]
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(Response).to receive(:where).with(map_id: 1, round: 1).and_return([response])
    allow(assignment).to receive(:review_questionnaire_id).with(1).and_return(1)
    expect(ReviewResponseMap.prepare_review_response(assignment, maps, review_final_versions, round)).to eq([1])
    round = nil
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(assignment).to receive(:review_questionnaire_id).with(nil).and_return(1)
    allow(Response).to receive(:where).with(map_id: 1).and_return([response2])
    expect(ReviewResponseMap.prepare_review_response(assignment, maps, review_final_versions, round)).to eq([3])
  end
end
