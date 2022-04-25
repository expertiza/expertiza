describe WaitlistTeam do
    let(:assignment) { build(:assignment, id: 1, name: 'no assgt') }
    let(:participant) { build(:participant, user_id: 1) }
    # let(:participant2) { build(:participant, user_id: 2) }
    # let(:participant3) { build(:participant, user_id: 3) }
    let(:user) { build(:student, id: 1, name: 'no name', fullname: 'no one', participants: [participant]) }
    # let(:user2) { build(:student, id: 2, name: 'no name2', fullname: 'no one2', participants: [participant2]) }
    let(:team) { build(:assignment_team, id: 1, name: 'no team1', users: [user]) }
    # let(:team2) { build(:assignment_team, id: 2, name: 'no team2', users: [user2]) }
    let(:team_user) { build(:team_user, id: 1, user: user) }
    # let(:team_user2) { build(:team_user, id: 2, user: user2) }
    before(:each) do
        allow(TeamsUser).to receive(:where).with(team_id: 1).and_return([team_user])
        # allow(TeamsUser).to receive(:where).with(team_id: 2).and_return([team_user2])
    end

    let(:topic1) { build(:topic, id: 1) }
    let(:topic2) { build(:topic, id: 2) }
    let(:waitlist_team1) { build(:waitlist_team) }
    let(:waitlist_team2) { build(:waitlist_team) }
    let(:waitlist_team3) { build(:waitlist_team) }
    let(:signedupteam1) { build(:signed_up_team) }
    # before(:each) do
    #     allow(waitlist_team1).to receive(:topic_id).and_return(1)
    #     allow(waitlist_team1).to receive(:team_id).and_return(1)
    #     allow(waitlist_team2).to receive(:topic_id).and_return(2)
    #     allow(waitlist_team2).to receive(:team_id).and_return(2)
    #     allow(waitlist_team3).to receive(:topic_id).and_return(1)
    #     allow(waitlist_team3).to receive(:team_id).and_return(3)
    #     allow(signedupteam1).to receive(:topic_id).and_return(3)
    # end


    describe 'CRUD WaitlistTeam' do
        before(:each) do
            allow(waitlist_team1).to receive(:topic_id).and_return(1)
            allow(waitlist_team1).to receive(:team_id).and_return(1)
            allow(waitlist_team2).to receive(:topic_id).and_return(1)
            allow(waitlist_team2).to receive(:team_id).and_return(2)
        end

        it 'adds and removes a team from the topic waitlist' do
            expect(WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)).to be_truthy
            expect(WaitlistTeam.remove_team_from_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)).to be_truthy
        end

        it 'cannot remove a team that does not exist from the topic waitlist' do
            WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)
            expect(WaitlistTeam.remove_team_from_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)).to be_truthy
            expect(WaitlistTeam.remove_team_from_topic_waitlist(waitlist_team1.team_id, waitlist_team2.topic_id,1)).to be_truthy
        end

        it 'adds first waitlist team in the topic waitlist' do    
            WaitlistTeam.add_team_to_topic_waitlist(waitlist_team1.team_id, waitlist_team1.topic_id,1)        
            signed_up_team = WaitlistTeam.signup_first_waitlist_team(1)
            expect(signed_up_team).to be_instance_of(SignedUpTeam) or  expect(signed_up_team).to be_nil
            expect(WaitlistTeam.team_has_any_waitlists?(waitlist_team1.team_id)).to be_truthy
        end
    end

    # describe '#cancel_all_waitlists' do
    #     it 'destroys signed up teams' do
    #       allow(SignUpTopic).to receive(:find_waitlisted_topics).and_return([topic1, topic2])
    #       allow(SignedUpTeam).to receive(:find_by).with(topic_id: 1).and_return(signedupteam1)
    #       allow(SignedUpTeam).to receive(:find_by).with(topic_id: 2).and_return(signedupteam2)
    #       allow_any_instance_of(SignedUpTeam).to receive(:destroy).and_return(true)
    #       expect(Waitlist.cancel_all_waitlists(0, 0)).to be_truthy
    # end

    # end
    # describe '#remove_from_waitlists' do
    #     it 'reassigns other teams' do
    #       allow(SignedUpTeam).to receive(:where).with(team_id: 1).and_return([signedupteam1])
    #       allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: false).and_return([])
    #       allow(SignedUpTeam).to receive(:find_by).with(topic_id: 1, is_waitlisted: true).and_return(signedupteam4)
    #       allow(SignUpTopic).to receive(:find).and_return(topic1)
    #       allow_any_instance_of(SignedUpTeam).to receive(:destroy).and_return(true)
    #       allow(SignUpTopic).to receive(:assign_to_first_waiting_team).and_return(true)
    #       expect(SignUpTopic).to receive(:assign_to_first_waiting_team)
    #       Waitlist.remove_from_waitlists(1)
    #     end
    # end
    
   
  end
  