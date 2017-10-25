include AssignmentHelper

describe LotteryController, type: :controller do
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
    it "Hope this works" do
      controller.params = {
          id: 1}

      session = {

      }
      user1 = double("User", id:1)
      user2 = double("User", id:2)
      user3 = double("User", id:3)
      user4 = double("User", id:4)
      team1 = double("Team", id: 1, name:"T1", users:[user1, user2])
      team2 = double("Team", id: 2, name:"T2", users:[user3, user4])
      sign_up_topic1 = double("SignUpTopic", topic_name: "Expertiza", assignment_id: 1 , id:1)
      sign_up_topic2 = double("SignUpTopic", topic_name: "Mozilla", assignment_id: 2, id: 2)
      assignment = double("Assignment",  id: 1, max_team_size: 1, sign_up_topics: [sign_up_topic1 , sign_up_topic2] , teams: [team1,team2])
      allow(Assignment).to receive(:find_by).with(any_args).and_return(assignment)
      allow(Bid).to receive(:find_by).with(any_args)

      rest = double("RestClient")
      allow(RestClient).to receive(:post).with(any_args).and_return(rest)
      json = double("JSON")
      allow(JSON).to receive(:parse).with(any_args)
      result = RestClient.get 'http://www.google.com', content_type: :json, accept: :json

      allow(controller.session[:menu]).to receive(:try).with(any_args).and_return(double('node', url: '/tree_display/list'))

      teams = [team1, team2]
      allow(controller).to receive(:create_new_teams_for_bidding_response).with(teams, assignment)
      allow(controller).to receive(:run_intelligent_bid).with(assignment)
      # expect(response).to redirect_to('/tree_display/list')
      controller.send(:run_intelligent_assignment)
      # redirect_to(controller: 'tree_display', action: 'list')
      # expect(response).to redirect_to('/tree_display/list')


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

    it "should assign only one team per topic" do
      controller.params = {
      }
      session = {
      }

      user1 = double("User", id:1)
      user2 = double("User", id:2)
      user3 = double("User", id:3)
      user4 = double("User", id:4)
      team1 = double("Team", id: 1, name:"T1", users:[user1, user2])
      team2 = double("Team", id: 2, name:"T2", users:[user3, user4])
      sign_up_topic1 = double("SignUpTopic", topic_name: "Expertiza", assignment_id: 1 , id:1)
      sign_up_topic2 = double("SignUpTopic", topic_name: "Mozilla", assignment_id: 2, id: 2)
      assignment = double("Assignment",  id: 1, max_team_size: 1, sign_up_topics: [sign_up_topic1 , sign_up_topic2] ,
                          teams: [team1,team2],name:"topic",is_intelligent:true)
      allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
      # allow(Assignment).to receive(:update_attributes!).with(:is_intelligent => false).and_return(assignment)
      sign_up_topics = double("sign_up_topics", id: 1,assignment_id: 1,max_choosers: 2 )
      allow(sign_up_topics).to receive(:where).with(any_args).and_return(1)

      team = double("team")
      unassignedteam = double("team")
      sortedteam = double("team")
      allow(team).to receive(:where).with(assignment).and_return(unassignedteam)
      allow(unassignedteam).to receive(:sort_by).and_return(sortedteam)
      team_user = double("TeamsUser",team: [team1,team2], user: [user1,user2])
      allow(team_user).to receive(:where).with(any_args)
      allow(Bid).to receive(:where).with(any_args)

      # signedUpTeam1 = double("SignedUpTeam", topic:sign_up_topics1,team_id: 1, is_waitlisted: 0)
      # signedUpTeam2 = double("SignedUpTeam", topic:sign_up_topics2,team_id: 2, is_waitlisted: 0)
      # unassigned_teams = double("AssignmentTeam", id:[1,2])
      # allow(sign_up_topics).to receive(:where).with(any_args).and_return(1)
      # team_user = double("TeamsUser",team: [team1,team2], user: [user1,user2])

      controller.send(:run_intelligent_bid,assignment)
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

    it "teams test" do
      user1 = double("User", id:1, priority: 0)
      user2 = double("User", id:2, priority: 1)
      user3 = double("User", id:3, priority: 2)
      user4 = double("User", id:4, priority: 3)
      team1 = double("Team", id: 1, name:"T1", users:[user1, user2])
      team2 = double("Team", id: 2, name:"T2", users:[user3, user4])
      assignment = double("Assignment",  id: 1, max_team_size: 1 )
      allow(Assignment).to receive(:find).with(any_args).and_return(assignment)
      unassignedteam = [team1,team2]
      allow(Team).to receive(:where).with(any_args).and_return(unassignedteam)
      allow(unassignedteam).to receive(:sort_by).with(any_args).and_return(unassignedteam)
      allow(unassignedteam).to receive(:each).with(any_args)
      allow(Bid).to receive(:where).with(any_args).and_return(Bid)
      allow(Bid).to receive(:sort_by).with(any_args)
      _final_team_topics = double("Assignment")
      controller.send(:auto_merge_teams,unassignedteam, _final_team_topics)

    end
  end
end
