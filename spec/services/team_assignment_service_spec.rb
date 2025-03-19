describe TeamAssignmentService do
    let(:instructor) { create(:instructor, name: 'instructor6', password: 'password', password_confirmation: 'password') }

    let(:assignment) { create(:assignment, is_intelligent: true, name: 'assignment', directory_path: 'assignment') }
    let(:assignment_2) { create(:assignment, is_intelligent: false, name: 'assignment_2', directory_path: 'assignment_2') }
  
    let(:student1) { create(:student, name: 'student1') }
    let(:student2) { create(:student, name: 'student2') }
    let(:student3) { create(:student, name: 'student3') }
    let(:student4) { create(:student, name: 'student4') }
    let(:student5) { create(:student, name: 'student5') }
    let(:student6) { create(:student, name: 'student6') }
  
    let(:topic1) { create(:topic, assignment_id: assignment.id) }
    let(:topic2) { create(:topic, assignment_id: assignment.id) }
    let(:topic3) { create(:topic, assignment_id: assignment.id) }
    let(:topic4) { create(:topic, assignment_id: assignment.id) }
  
    let(:assignment_team1) { create(:assignment_team, parent_id: assignment.id) }
    let(:assignment_team2) { create(:assignment_team, parent_id: assignment.id) }
    let(:assignment_team3) { create(:assignment_team, parent_id: assignment.id) }
    let(:assignment_team4) { create(:assignment_team, parent_id: assignment.id) }
  
    let(:team_user1) { create(:team_user, team_id: assignment_team1.id, user_id: student1.id, id: 1) }
    let(:team_user2) { create(:team_user, team_id: assignment_team1.id, user_id: student2.id, id: 2) }
    let(:team_user3) { create(:team_user, team_id: assignment_team1.id, user_id: student3.id, id: 3) }
    let(:team_user4) { create(:team_user, team_id: assignment_team2.id, user_id: student4.id, id: 4) }
    let(:team_user5) { create(:team_user, team_id: assignment_team3.id, user_id: student5.id, id: 5) }
    let(:team_user6) { create(:team_user, team_id: assignment_team4.id, user_id: student6.id, id: 6) }
  
    before :each do
      assignment_team1.save
      assignment_team2.save
      assignment_team3.save
      assignment_team4.save
  
      team_user1.save
      team_user2.save
      team_user3.save
      team_user4.save
      team_user5.save
      team_user6.save
  
      topic1.save
      topic2.save
      topic3.save
      topic4.save
  
      Bid.create(topic_id: topic1.id, team_id: assignment_team1.id, priority: 1)
      Bid.create(topic_id: topic2.id, team_id: assignment_team2.id, priority: 2)
      Bid.create(topic_id: topic4.id, team_id: assignment_team2.id, priority: 1)
      Bid.create(topic_id: topic3.id, team_id: assignment_team2.id, priority: 5)
      Bid.create(topic_id: topic4.id, team_id: assignment_team3.id, priority: 0)
      Bid.create(topic_id: topic4.id, team_id: assignment_team1.id, priority: 3)
  
      @teams = assignment.teams
      @sign_up_topics = assignment.sign_up_topics
    end

    describe '#construct_teams_bidding_info' do
        it 'should generate teams bidding info hash based on newly created teams' do
            service = TeamAssignmentService.new(assignment.id)
            unassigned_teams = [assignment_team1, assignment_team2]
            sign_up_topics = [topic1, topic2]
            teams_bidding_info = service.send(:construct_teams_bidding_info, unassigned_teams, sign_up_topics)
            expect(teams_bidding_info.size).to eq(2)
        end
    end

    # Validates that the method returns an empty array when no teams are provided
    it 'returns an empty array if no unassigned teams are provided' do
        service = TeamAssignmentService.new(assignment.id)
        sign_up_topics = [topic1, topic2]
        teams_bidding_info = service.send(:construct_teams_bidding_info, [], sign_up_topics)
        expect(teams_bidding_info).to eq([])
    end
    
    # Confirms that fetch_bids and construct_team_bids are called within the method
    it 'calls the fetch_bids and construct_team_bids methods' do
        service = TeamAssignmentService.new(assignment.id)
        unassigned_teams = [assignment_team1, assignment_team2]
        sign_up_topics = [topic1, topic2]
        # Expect fetch_bids and construct_team_bids to be called as part of construct_teams_bidding_info
        expect(service).to receive(:fetch_bids).with(unassigned_teams, sign_up_topics).and_call_original
        expect(service).to receive(:construct_team_bids).at_least(:once).and_call_original

        service.send(:construct_teams_bidding_info, unassigned_teams, sign_up_topics)
    end
end
