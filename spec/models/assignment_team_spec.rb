describe 'AssignmentTeam' do
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:participant1) { build(:participant, id: 1) }
  let(:participant2) { build(:participant, id: 2) }
  let(:user1) { build(:student, id: 2) }
  let(:user2) { build(:student, id: 3) }
  let(:review_response_map) { build(:review_response_map, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:topic) { build(:topic, id: 1, topic_name: "New Topic") }
  let(:signedupteam) { build(:signed_up_team) }

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

  describe ".export_fields" do
    context "when team has name" do
      it "exports the fields" do
        expect(AssignmentTeam.export_fields(team)).to eq(["Team Name", "Assignment Name"])
      end
    end
  end

  describe "#copy" do
    context "for given assignment team" do
      it "copies the assignment team to course team" do
	assignment = team.assignment
	course = assignment.course
	expect(team.copy(course.id)).to eq([])
      end
    end
  end

  describe "#add_participant" do
    context "when a user is not a part of the team" do
      it "adds the user to the team" do
	user = build(:student, id: 10)
	assignment = team.assignment
	expect(team.add_participant(assignment.id, user)).to be_an_instance_of(AssignmentParticipant)
      end
    end

    context "when a user is already a part of the team" do
      it "returns without adding user to the team" do
	allow(team).to receive(:users).with(no_args).and_return([user1])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
	assignment = team.assignment
	expect(team.add_participant(assignment.id, user1)).to eq(nil)
      end
    end
  end

  describe "#topic" do
    context "when the team has picked a topic" do
      it "provides the topic id" do
        assignment = team.assignment
        allow(SignUpTopic).to receive(:find_by).with(assignment: assignment).and_return(topic)
	allow(SignedUpTeam).to receive_message_chain(:find_by, :try).with(team_id: team.id).with(:topic_id).and_return(topic.id)
	expect(team.topic).to eq(topic.id)
      end
    end
  end

  describe "#delete" do
    it "deletes the team" do
      allow(team).to receive(:users).with(no_args).and_return([user1, user2])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user2.id, parent_id: team.parent_id).and_return(participant2)
      signupteam = build(:signed_up_team, id: 1, team_id: team.id)
      expect(team.delete).to eq(team)
    end
  end

  describe "#path" do
    it "returns the path" do
      expect(team.path).to eq "/home/expertiza_developer/Desktop/expertiza/pg_data/instructor6/csc517/test/final_test/0"
    end
  end

  describe "#set_student_directory_num" do
    it "sets the directory for the team" do      
      team = build(:assignment_team, id: 1, parent_id: 1,directory_num: -1)
      max_num = 0
      allow(AssignmentTeam).to receive_message_chain(:where, :order, :first, :directory_num).with(parent_id: team.parent_id).with(:directory_num, :desc).with(no_args).with(no_args).and_return(max_num)      
      expect(team.set_student_directory_num).to be true
    end
  end

end
