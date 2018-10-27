describe 'AssignmentTeam' do
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:participant1) { build(:participant, id: 1) }
  let(:participant2) { build(:participant, id: 2) }
  let(:user1) { build(:student, id: 2) }
  let(:user2) { build(:student, id: 3) }
  let(:review_response_map) { build(:review_response_map, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }

  describe "#hyperlinks" do
    context "when current teams submitted hyperlinks" do
      it "returns the hyperlinks submitted by the team" do
        expect(team.hyperlinks).to eq(["https://www.expertiza.ncsu.edu"])
      end
    end

    context "when current teams did not submit hyperlinks" do
      it "returns an empty array" do
        expect(team_without_submitted_hyperlinks.hyperlinks).to eq([])
      end
    end
  end

  describe "#includes?" do
    context "when an assignment team has one participant" do
      it "includes one participant" do
        allow(team).to receive(:users).with(no_args).and_return([user1])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
        expect(team.includes?(participant1)).to eq true
      end
    end
    
    context "when an assignment team has no users" do
      it "includes no participants" do
        allow(team).to receive(:users).with(no_args).and_return([])
        expect(team.includes?(participant1)).to eq false
      end
    end
  end

  describe "#parent_model" do
    it "provides the name of the parent model" do
      expect(team.parent_model).to eq "Assignment"
    end
  end

  describe ".parent_model" do
    it "provides the instance of the parent model" do
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      expect(AssignmentTeam.parent_model(1)).to eq assignment
    end
  end

  describe "#fullname" do
    context "when the team has a name" do
      it "provides the name of the class" do
        team = build(:assignment_team, id: 1, name: "abcd")
        expect(team.fullname).to eq "abcd"
      end
    end
  end

 describe ".remove_team_by_id" do
    context "when a team has an id" do
      it "delete the team by id" do
        team = build(:assignment_team, id: 1)
	allow(AssignmentTeam).to receive(:find).with(1).and_return(team)
	expect(AssignmentTeam.remove_team_by_id(team.id)).to eq(team)
      end
    end
  end

  describe ".get_first_member" do
    context "when team id is present" do
      it "get first member of the  team" do

	team = build(:assignment_team, id: 1)
        build(:student, id: 3)
        participant1 = build(:participant, id: 1, user_id: 3)
        team_user1 = build(:team_user, team_id: 1, user_id: 3)	        				
		
	allow(AssignmentTeam).to receive_message_chain(:find_by, :try, :try).with(id: team.id).with(:participant).with(:first).and_return(participant1)
	expect(AssignmentTeam.get_first_member(team.id)).to eq(participant1)
      end
    end
  end

  describe "#review_map_type" do
    it "provides the review map type" do
      expect(team.review_map_type).to eq "ReviewResponseMap"
    end
  end

  describe ".prototype" do
    it "provides the instance of the AssignmentTeam" do
      expect(AssignmentTeam).to receive(:new).with(no_args)
      AssignmentTeam.prototype
    end
  end

  describe "#reviewed_by?" do
    context "when a team has a reviewer" do
      it "has been reviewed by this reviewer" do
         template = 'reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?'
         allow(ReviewResponseMap).to receive(:where).with(template, team.id, participant1.id, team.assignment.id).and_return([review_response_map])
         expect(team.reviewed_by?(participant1)).to eq true
      end
    end

    context "when a team does not have any reviewers" do
      it "has not been reviewed by this reviewer" do
         template = 'reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?'
         allow(ReviewResponseMap).to receive(:where).with(template, team.id, participant1.id, team.assignment.id).and_return([])
         expect(team.reviewed_by?(participant1)).to eq false
      end
    end
  end

  describe "#participants" do
    context "when an assignment team has two participants" do
      it "has those two participants" do
        allow(team).to receive(:users).with(no_args).and_return([user1, user2])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user2.id, parent_id: team.parent_id).and_return(participant2)
        expect(team.participants).to eq [participant1, participant2]
      end
    end
    
    context "when an assignment team has a user but no participants" do
      it "includes no participants" do
        allow(team).to receive(:users).with(no_args).and_return([user1])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(nil)
        expect(team.participants).to eq []
      end
    end
  end

  
end
