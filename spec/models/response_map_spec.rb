describe ResponseMap do
  let(:team) { build(:assignment_team, id: 1, name: 'team no name', assignment: assignment, users: [student], parent_id: 1) }
  let(:team1) { build(:assignment_team, id: 2, name: 'team has name', assignment: assignment, users: [student1]) }
  let(:team2) { build(:assignment_team, id: 3, name: 'team has a name', assignment: assignment, users: [student2]) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: student) }
  let(:participant1) { build(:participant, id: 2, parent_id: 2, user: student1) }
  let(:participant2) { build(:participant, id: 3, parent_id: 3, user: student2) }
  let(:student) { build(:student, id: 1, username: 'name', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:student1) { build(:student, id: 2, username: 'name1', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:student2) { build(:student, id: 3, username: 'name2', name: 'no one', email: 'expertiza@mailinator.com') }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt', rounds_of_reviews: 2) }
  let(:assignment1) { build(:assignment, id: 2, name: 'Test Assgt2', rounds_of_reviews: 2) }

  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:review_response_map1) { build(:review_response_map, id: 2, assignment: assignment, reviewer: participant1, reviewee: team) }
  let(:teammate_review_response_map) { build(:teammate_review_response_map, id: 3, assignment: assignment, reviewer: participant, reviewee: participant2) }
  let(:teammate_review_response_map1) { build(:teammate_review_response_map, id: 4, assignment: assignment, reviewer: participant1, reviewee: participant2) }
  let(:review_response_map2) { build(:review_response_map, id: 5, assignment: assignment, reviewer: participant2, reviewee: team2) }
  let(:metareview_response_map) { build(:meta_review_response_map, id: 6, reviewer: participant1, review_mapping: review_response_map) }
  let(:metareview_response_map1) { build(:meta_review_response_map, reviewed_object_id: review_response_map1.id, reviewer_id: participant2.id, reviewee_id: team.id) }

  # let(:review_response_map1){ build(:review_response_map, id: 2, assignment: assignment,reviewer: participant1, reviewee: team1, reviewed_object_id: 1, response: [response], calibrate_to: 0) }
  let(:response) { build(:response, id: 1, map_id: 1, round: 1, response_map: review_response_map, is_submitted: true) }
  let(:response1) { build(:response, id: 2, map_id: 2, round: 1, response_map: review_response_map1, is_submitted: false) }
  let(:response2) { build(:response, id: 3, map_id: 3, round: 1, response_map: teammate_review_response_map,  is_submitted: true) }
  let(:response3) { build(:response, id: 4, map_id: 4, round: 1, response_map: teammate_review_response_map1, is_submitted: false) }
  let(:response4) { build(:response, id: 5, map_id: 5, round: 1, response_map: review_response_map2, is_submitted: true) }
  let(:response5) { build(:response, id: 6, map_id: 5, round: 1, response_map: review_response_map2, is_submitted: false) }

  before(:each) do
    allow(review_response_map).to receive(:response).and_return([response])
    allow(review_response_map1).to receive(:response).and_return([response1])
    allow(teammate_review_response_map).to receive(:response).and_return([response2])
    allow(teammate_review_response_map1).to receive(:response).and_return([response3])
    allow(review_response_map2).to receive(:response).and_return([response4, response5])
  end

  describe 'self.assessments_for' do
    context 'Getting assessments for Review Response map' do
      it 'returns only submitted responses' do
        allow(Team).to receive(:find).and_return(team)
        allow(ResponseMap).to receive(:where).with(reviewee_id: team.id).and_return([review_response_map, review_response_map1])
        allow(Response).to receive(:where).with(map_id: 1).and_return([response])
        allow(Response).to receive(:where).with(map_id: 2).and_return([response1])
        responses = ResponseMap.assessments_for(team)
        expect(responses).to eq([response])
      end
    end

    context 'Getting assessments for other Response maps' do
      it 'returns all responses' do
        allow(Team).to receive(:find).and_return(team1)
        allow(ResponseMap).to receive(:where).with(reviewee_id: participant2.id).and_return([teammate_review_response_map, teammate_review_response_map1])
        allow(Response).to receive(:where).with(map_id: 3).and_return([response2])
        allow(Response).to receive(:where).with(map_id: 4).and_return([response3])
        responses = ResponseMap.assessments_for(participant2)
        expect(responses).to eq([response2, response3])
      end
    end
  end

  describe 'self.reviewer_assessments_for' do
    context 'Returning latest version of responses by reviewer' do
      it 'returns the second response' do
        allow(ResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant2.id).and_return([review_response_map2])
        allow(Response).to receive(:where).with(map_id: review_response_map2.id).and_return([response4, response5])
        responses = ResponseMap.reviewer_assessments_for(team2, participant2)
        expect(responses).to eq(response5)
      end
      it 'returns the response with the version number' do
        response4.version_num = 2
        allow(ResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant2.id).and_return([review_response_map2])
        allow(Response).to receive(:where).with(map_id: review_response_map2.id).and_return([response4, response5])
        responses = ResponseMap.reviewer_assessments_for(team2, participant2)
        expect(responses).to eq(response4)
      end
      it 'returns the response with the highest version number' do
        response4.version_num = 3
        response5.version_num = 2
        allow(ResponseMap).to receive(:where).with(reviewee_id: team2.id, reviewer_id: participant2.id).and_return([review_response_map2])
        allow(Response).to receive(:where).with(map_id: review_response_map2.id).and_return([response4, response5])
        responses = ResponseMap.reviewer_assessments_for(team2, participant2)
        expect(responses).to eq(response4)
      end
    end
  end

  describe 'metareviewed_by?' do
    context 'Returning whether it is metareviewed' do
      it 'returns true' do
        allow(MetareviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant1.id, reviewed_object_id: review_response_map.id).and_return([metareview_response_map])
        expect(review_response_map.metareviewed_by?(participant1)).to eq(true)
      end
    end
  end

  describe 'assign_metareviewer' do
    context 'Assigns a metareviewer to a review' do
      it 'creates a metareview response map' do
        metareview_response_map_temp = create(:meta_review_response_map, reviewed_object_id: review_response_map1.id, reviewer_id: participant2.id, reviewee_id: participant1.id)
        allow(MetareviewResponseMap).to receive(:create).with(reviewed_object_id: review_response_map1.id, reviewer_id: participant2.id, reviewee_id: participant1.id).and_return(\
          metareview_response_map_temp
        )
        expect(review_response_map1.assign_metareviewer(participant2)).to eq(metareview_response_map_temp)
      end
    end
  end

  describe 'find_team_member' do
    context 'Finds the team of a reviewee' do
      it 'finds the team for a metareview response map' do
        allow(ResponseMap).to receive(:find_by).with(id: metareview_response_map.reviewed_object_id).and_return(metareview_response_map)
        allow(AssignmentTeam).to receive(:find_by).with(id: review_response_map.reviewee_id).and_return(team)
        expect(metareview_response_map.find_team_member).to eq(team)
      end
      it 'finds the team for a regular response map' do
        allow(AssignmentTeam).to receive(:find).with(review_response_map.reviewee_id).and_return(team)
        expect(review_response_map.find_team_member).to eq(team)
      end
    end
  end
end
