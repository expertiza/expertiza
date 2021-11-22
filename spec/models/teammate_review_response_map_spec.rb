describe TeammateReviewResponseMap do
  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:team2) { build(:assignment_team, id: 3, name: 'no team') }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name', assignment: assignment, users: [student]) }
  let(:team3) { build(:assignment_team, id: 4, name: 'team has name1', assignment: assignment, users: [student1]) }
  let(:teammate_review_response_map1) { build(:teammate_review_response_map, id: 1, assignment: assignment1, reviewer: participant, reviewee: participant1) }

  let(:feedback) { FeedbackResponseMap.new(id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: student1) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt', rounds_of_reviews: 1) }
  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: teammate_review_response_map1,  is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 1, round: 2, response_map: teammate_review_response_map1) }
  let(:response2) { build(:response, id: 3, map_id: 1, round: nil, response_map: teammate_review_response_map1, is_submitted: true) }
  let(:response3) { build(:response) }
  let(:metareview_response_map) { build(:meta_review_response_map, reviewed_object_id: 1) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, name: "name1", fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment_teammate_questionnaire1) { build(:assignment_teammate_questionnaire, id: 1, assignment: assignment1, questionnaire: teammate_questionnaire1) }
  let(:assignment_teammate_questionnaire2) { build(:assignment_teammate_questionnaire, id: 2, assignment_id: 2, questionnaire_id: 2) }
  let(:teammate_questionnaire1) { build(:teammate_questionnaire, id: 1, type: 'TeammateReviewQuestionnaire') }
  let(:teammate_questionnaire2) { build(:teammate_questionnaire, id: 2, type: 'TeammateReviewQuestionnaire') }
  let(:next_due_date) { build(:assignment_due_date, round: 1) }
  let(:question) { double('Question') }
  let(:review_questionnaire) { build(:questionnaire, id: 3) }
  let(:response3) { build(:response) }
  let(:response_map) { build(:review_response_map, reviewer_id: 2, response: [response3]) }
  before(:each) do
    allow(teammate_review_response_map1).to receive(:response).and_return(response)
    allow(response_map).to receive(:response).and_return(response3)
    allow(response_map).to receive(:id).and_return(1)
  end

  it '#contributor' do
    expect(teammate_review_response_map1.contributor).to eq(nil)
  end

  it '#get_title' do
    expect(teammate_review_response_map1.get_title).to eq("Teammate Review")
  end

  describe '#questionnaire' do
    # This method is little more than a wrapper for assignment.review_questionnaire_id()
    # Test how it responds to the combinations of various arguments it could receive

    context 'when corresponding active record for assignment_questionnaire is found' do
      before(:each) do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_teammate_questionnaire1, assignment_teammate_questionnaire2])
        allow(Questionnaire).to receive(:find).with(1).and_return(assignment_teammate_questionnaire1)
      end

      it 'returns correct questionnaire found by used_in_round and topic_id if both used_in_round and topic_id are given' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment1.id, used_in_round: 1, topic_id: 1).and_return(
            [assignment_teammate_questionnaire1])
        allow(Questionnaire).to receive(:find_by!).with(type: 'TeammateReviewQuestionnaire').and_return([teammate_questionnaire1])
        #allow(Questionnaire).to receive(:where!).and_return([teammate_questionnaire1])


        assignment1.questionnaires = [teammate_questionnaire1, teammate_questionnaire2]
        puts "--"
        puts assignment1
        puts "questionnaire through assignment"
        puts assignment1.questionnaires
        puts "--"
        puts teammate_questionnaire1
        puts teammate_questionnaire1.type

        puts "--"
        puts assignment_teammate_questionnaire1
        puts assignment_teammate_questionnaire1.assignment
        puts assignment_teammate_questionnaire1.questionnaire
        puts "--"
        puts teammate_review_response_map1.assignment.questionnaires.class
        puts teammate_review_response_map1.assignment.questionnaires.where!(type: 'TeammateReviewQuestionnaire')

        expect(teammate_review_response_map1.questionnaire()).to eq(teammate_questionnaire1)
      end

    end
  end

  it '#email' do
    reviewer_id = 1
    allow(Participant).to receive(:find).with(1).and_return(participant)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(AssignmentTeam).to receive(:find).with(1).and_return(team)
    allow(AssignmentTeam).to receive(:users).and_return(student)
    allow(User).to receive(:find).with(1).and_return(student)
    review_response_map.reviewee_id = 1
    defn = {body: {type: "TeammateReview", obj_name: "Test Assgt", first_name: "no one", partial_name: "new_submission"}, to: "expertiza@mailinator.com"}
    expect { teammate_review_response_map1.email(defn, participant, Assignment.find(Participant.find(reviewer_id).parent_id)) }
        .to change { ActionMailer::Base.deliveries.count }.by 1
  end
end
