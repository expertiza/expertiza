describe ResponseMap do
  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name', assignment: assignment, users: [student1]) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: student1) }
  let(:student) { build(:student, id: 1, name: 'name', fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, name: "name1", fullname: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }

  let(:review_response_map) do
    build :review_response_map,
          id: 1,
          assignment: assignment,
          reviewer: participant,
          reviewee: team,
          reviewed_object_id: 1,
          response: [response],
          calibrate_to: 0
  end

  let(:review_response_map1) do
    build :review_response_map,
          id: 2,
          assignment: assignment,
          reviewer: participant1,
          reviewee: team,
          reviewed_object_id: 2,
          response: [response1],
          calibrate_to: 0
  end

  let(:response_map) do
    build :response_map,
          id: 3,
          assignment: assignment,
          reviewer: participant,
          reviewee: team1,
          calibrate_to: 0
  end

  let(:response_map1) do
    build :response_map,
          id: 4,
          assignment: assignment,
          reviewer: participant1,
          reviewee: team1,
          calibrate_to: 0
  end

  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: review_response_map,  is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 2, round: 1, response_map: review_response_map1, is_submitted: false) }
  let(:response2) { build(:response, id: 3, map_id: 3, round: 1, response_map: response_map,  is_submitted: true) }
  let(:response3) { build(:response, id: 4, map_id: 4, round: 1, response_map: response_map1, is_submitted: false) }

  describe 'self.assessments_for' do
    context 'Getting assessments for Review Response map' do
      it 'returns only submitted responses' do
        puts "Team"
        puts team.id
        allow(Team).to receive(:find).and_return(team)
        allow(ResponseMap).to receive(:where).with(reviewee_id: team.id).and_return([review_response_map, review_response_map1])
        responses = ResponseMap.assessments_for(team)
	expect(responses.length()).to eq(1)
      end
    end

    context 'Getting assessments for other Response maps' do
      it 'returns all responses' do
        responses = ResponseMap.assessments_for(team1)
	expect(responses.length()).to eq(2)
      end
    end

  end

end
