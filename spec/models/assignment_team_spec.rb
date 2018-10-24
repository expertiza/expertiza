describe 'AssignmentTeam' do
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }
  let(:team) { build(:assignment_team) }
  let(:assignment) { build(:assignment) }

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
        team = create(:assignment_team, id: 1)
        create(:student, id: 2)
        participant = create(:participant, user_id: 2)
        create(:team_user, team_id: 1, user_id: 2)
        expect(team.includes?(participant)).to eq true
      end
    end
    
    context "when an assignment team has no participants" do
      it "includes no participants" do
        team = create(:assignment_team, id: 1)
        create(:student, id: 2)
        participant = create(:participant, user_id: 2)
        expect(team.includes?(participant)).to eq false
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
        expect(team.fullname()).to eq "abcd"
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

      expect(AssignmentTeam).to receive(:new).with(no_args())
      AssignmentTeam.prototype
    end
  end
end
