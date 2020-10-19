describe TeammateReviewResponseMap do
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
  let(:teammate_review_response_map) { TeammateReviewResponseMap.new(id: 1, reviewed_object_id: 1, reviewee_id: 1) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, name: "name1", fullname: 'no one', email: 'expertiza@mailinator.com') }

  before(:each) do
    allow(review_response_map).to receive(:response).and_return(response)
  end

  it '#email' do
    allow(Participant).to receive(:find).with(1).and_return(participant)
    reviewee_user = participant.id

    allow(Assignment).to receive(:find).with(reviewee_user).and_return(assignment)
    allow(AssignmentTeam).to receive(:find).with(reviewee_user).and_return(team)
    allow(AssignmentTeam).to receive(:users).and_return(student)
    allow(User).to receive(:find).with(reviewee_user).and_return(student)
    allow(TeammateReviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([teammate_review_response_map])
    teammate_review_response_map.reviewee_id = reviewee_user
    defn = {body: {type: "Teammate Review", obj_name: assignment.name, first_name: student.fullname, partial_name: "new_submission"}, to: student.email}

    expect { teammate_review_response_map.email(defn, participant, assignment)}
        .to change { ActionMailer::Base.deliveries.count }.by 1
  end
end
