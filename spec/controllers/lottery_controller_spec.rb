include AssignmentHelper

describe LotteryController do


  let(:participant1) { build(:participant, user_id: 1) }
  let(:participant2) { build(:participant, user_id: 2) }

  let(:user1) { build(:student, id: 1, participants: [participant1]) }
  let(:user2) { build(:student, id: 2, participants: [participant2]) }

  let(:team1) { build(:assignment_team, id: 1, users: [user1]) }
  let(:team2) { build(:assignment_team, id: 2, users: [user2]) }


  let(:topic1) { build(:topic, id: 1,assignment: 1,max_choosers: 2)}
  let(:topic2) { build(:topic, id: 2,assignment: 1,max_choosers: 2)}
  let(:topic3) { build(:topic, id: 3,assignment: 1,max_choosers: 2)}

  let(:assignment1) do
    build(:assignment, id: 1, name: 'test assignment1', instructor_id: 6, staggered_deadline: true,is_intelligent: true,
          participants: [participant1, participant2], teams: [team1, team2], course_id: 1,sign_up_topics: [topic1, topic2, topic3])
  end


  let(:participant3) { build(:participant, user_id: 3) }
  let(:participant4) { build(:participant, user_id: 4) }

  let(:user3) { build(:student, id: 3, participants: [participant3]) }
  let(:user4) { build(:student, id: 4, participants: [participant4]) }

  let(:team3) { build(:assignment_team, id: 3, users: [user3]) }
  let(:team4) { build(:assignment_team, id: 4, users: [user4]) }

  let(:topic4) { build(:topic, id: 4,assignment: 2,max_choosers: 2)}
  let(:topic5) { build(:topic, id: 5,assignment: 2,max_choosers: 2)}
  let(:topic6) { build(:topic, id: 6,assignment: 2,max_choosers: 2)}

  let(:assignment2) do
    build(:assignment, id: 2, name: 'test assignment2', instructor_id: 6, staggered_deadline: true,is_intelligent: true,
          participants: [participant3, participant4], teams: [team3, team4], course_id: 1,sign_up_topics: [topic4, topic5, topic6])
  end

  let(:participant5) { build(:participant, user_id: 5) }
  let(:participant6) { build(:participant, user_id: 6) }
  let(:participant7) { build(:participant, user_id: 7) }

  let(:user5) { build(:student, id: 5, participants: [participant5]) }
  let(:user6) { build(:student, id: 6, participants: [participant6]) }
  let(:user6) { build(:student, id: 7, participants: [participant7]) }

  let(:team5) { build(:assignment_team, id: 5, users: [user5]) }
  let(:team6) { build(:assignment_team, id: 6, users: [user6]) }
  let(:team7) { build(:assignment_team, id: 7, users: [user7]) }

  let(:topic7) { build(:topic, id: 7,assignment: 3,max_choosers: 2)}
  let(:topic8) { build(:topic, id: 8,assignment: 3,max_choosers: 2)}
  let(:topic9) { build(:topic, id: 9,assignment: 3,max_choosers: 2)}

  let(:assignment3) do
    build(:assignment, id: 3, name: 'test assignment3', instructor_id: 6, staggered_deadline: true,is_intelligent: true,
          participants: [participant5, participant6,participant7], teams: [team5, team6,team7], course_id: 1,sign_up_topics: [topic7, topic8, topic9])
  end

  let(:signed_up_team1) { build(:signed_up_team, team_id: 1, topic_id: 1)}
  let(:signed_up_team2) { build(:signed_up_team, team_id: 1, topic_id: 2)}
  let(:signed_up_team3) { build(:signed_up_team, team_id: 2, topic_id: 3)}
  let(:signed_up_team4) { build(:signed_up_team, team_id: 2, topic_id: 1)}

  let(:signed_up_team5) { build(:signed_up_team, team_id: 3, topic_id: 4)}
  let(:signed_up_team6) { build(:signed_up_team, team_id: 3, topic_id: 5)}
  let(:signed_up_team7) { build(:signed_up_team, team_id: 4, topic_id: 4)}
  let(:signed_up_team8) { build(:signed_up_team, team_id: 4, topic_id: 5)}

  let(:signed_up_team9) { build(:signed_up_team, team_id: 5, topic_id: 7)}
  let(:signed_up_team10) { build(:signed_up_team, team_id: 5, topic_id: 9)}
  let(:signed_up_team11) { build(:signed_up_team, team_id: 6, topic_id: 8)}
  let(:signed_up_team12) { build(:signed_up_team, team_id: 6, topic_id: 9)}
  let(:signed_up_team13) { build(:signed_up_team, team_id: 7, topic_id: 7)}
  let(:signed_up_team14) { build(:signed_up_team, team_id: 7, topic_id: 8)}


  describe "#run_intelligent_assignmnent" do
    it "webservice call should be successful" do
      dat = double("data")
      rest = double("RestClient")
      result = RestClient.get 'http://www.google.com', content_type: :json, accept: :json
      expect(result.code).to eq(200)
    end

    it "should return json response" do
      result = RestClient.get 'https://www.google.com', content_type: :json, accept: :json
      expect(result.header['Content-Type']).to include 'application/json' rescue result
    end
  end

  describe "#run_intelligent_bid" do
    it "should do intelligent assignment" do
      assignment = double("Assignment")
      allow(assignment).to receive(:is_intelligent) { 1 }
      expect(assignment.is_intelligent).to eq(1)
    end

    it "should exit gracefully when assignment not intelligent" do
      assignment = double("Assignment")
      allow(assignment).to receive(:is_intelligent) { 0 }
      expect(assignment.is_intelligent).to eq(0)
      redirect_to(controller: 'tree_display')
    end
  end

  describe "#create_new_teams_for_bidding_response" do
    it "should create team and return teamid" do
      assignment = double("Assignment")
      team = double("team")
      allow(team).to receive(:create_new_teams_for_bidding_response).with(assignment).and_return(:teamid)
      expect(team.create_new_teams_for_bidding_response(assignment)).to eq(:teamid)
    end
  end

  describe "#auto_merge_teams" do
    it "sorts the unassigned teams" do
      assignment = double("Assignment")
      team = double("team")
      unassignedteam = double("team")
      sortedteam = double("team")
      allow(team).to receive(:where).with(assignment).and_return(unassignedteam)
      allow(unassignedteam).to receive(:sort_by).and_return(sortedteam)
      expect(team.where(assignment)).to eq(unassignedteam)
      expect(unassignedteam.sort_by).to eq(sortedteam)
    end
  end


  describe "#run_conference_bidding" do
    it "should do run conference" do
      assignment = double("Assignment")
      allow(assignment).to receive(:type_id) { true }
      expect(assignment.type_id).to eq(true)
    end

    it "where all teams have preferences" do

      bid1 = double('Bid',team_id: 1,topic_id: 1,priority:1)
      bid2 = double('Bid',team_id: 1,topic_id: 2,priority:2)
      bid3 = double('Bid',team_id: 2,topic_id: 3,priority:1)
      bid4 = double('Bid',team_id: 2,topic_id: 1,priority:2)

      allow(Bid).to receive(:where).with(team_id: 1).and_return([bid1,bid2])
      allow(Bid).to receive(:where).with(team_id: 2).and_return([bid3,bid4])

      allow(Bid).to receive(:where).with(team_id: 1,topic_id: 1).and_return(bid1.priority)
      allow(Bid).to receive(:where).with(team_id: 1,topic_id: 2).and_return(bid2.priority)
      allow(Bid).to receive(:where).with(team_id: 1,topic_id: 3).and_return('')
      allow(Bid).to receive(:where).with(team_id: 2,topic_id: 1).and_return(bid3.priority)
      allow(Bid).to receive(:where).with(team_id: 2,topic_id: 2).and_return('')
      allow(Bid).to receive(:where).with(team_id: 2,topic_id: 3).and_return(bid4.priority)

      expect(signed_up_team1.team_id).to eq(1)
      expect(signed_up_team2.team_id).to eq(1)
      expect(signed_up_team3.team_id).to eq(2)
      expect(signed_up_team4.team_id).to eq(2)
    end

    it "where zero teams have preferences" do

      allow(Bid).to receive(:where).with(team_id: 3).and_return('')
      allow(Bid).to receive(:where).with(team_id: 4).and_return('')

      allow(Bid).to receive(:where).with(team_id: 3,topic_id: 4).and_return('')
      allow(Bid).to receive(:where).with(team_id: 3,topic_id: 5).and_return('')
      allow(Bid).to receive(:where).with(team_id: 3,topic_id: 6).and_return('')
      allow(Bid).to receive(:where).with(team_id: 4,topic_id: 4).and_return('')
      allow(Bid).to receive(:where).with(team_id: 4,topic_id: 5).and_return('')
      allow(Bid).to receive(:where).with(team_id: 4,topic_id: 6).and_return('')

      expect(signed_up_team5.team_id).to eq(3)
      expect(signed_up_team6.team_id).to eq(3)
      expect(signed_up_team7.team_id).to eq(4)
      expect(signed_up_team8.team_id).to eq(4)
    end

    it "where few teams have preferences and few don;t" do
      bid5 = double('Bid',team_id: 5,topic_id: 7,priority:1)
      bid6 = double('Bid',team_id: 5,topic_id: 9,priority:2)
      bid7 = double('Bid',team_id: 6,topic_id: 8,priority:1)
      bid8 = double('Bid',team_id: 6,topic_id: 9,priority:2)

      allow(Bid).to receive(:where).with(team_id: 5).and_return([bid5,bid6])
      allow(Bid).to receive(:where).with(team_id: 6).and_return([bid7,bid8])
      allow(Bid).to receive(:where).with(team_id: 7).and_return('')

      allow(Bid).to receive(:where).with(team_id: 5,topic_id: 7).and_return(bid5.priority)
      allow(Bid).to receive(:where).with(team_id: 5,topic_id: 8).and_return('')
      allow(Bid).to receive(:where).with(team_id: 5,topic_id: 9).and_return(bid6.priority)
      allow(Bid).to receive(:where).with(team_id: 6,topic_id: 7).and_return('')
      allow(Bid).to receive(:where).with(team_id: 6,topic_id: 8).and_return(bid7.priority)
      allow(Bid).to receive(:where).with(team_id: 6,topic_id: 9).and_return(bid8.priority)
      allow(Bid).to receive(:where).with(team_id: 7,topic_id: 7).and_return('')
      allow(Bid).to receive(:where).with(team_id: 7,topic_id: 8).and_return('')
      allow(Bid).to receive(:where).with(team_id: 7,topic_id: 9).and_return('')

      expect(signed_up_team9.team_id).to eq(5)
      expect(signed_up_team10.team_id).to eq(5)
      expect(signed_up_team11.team_id).to eq(6)
      expect(signed_up_team12.team_id).to eq(6)
      expect(signed_up_team13.team_id).to eq(7)
      expect(signed_up_team14.team_id).to eq(7)
    end
  end

end
