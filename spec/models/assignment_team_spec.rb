describe 'AssignmentTeam' do
  let(:assignment) { build(:assignment) }
  let(:team) { build(:assignment_team) }
  let(:participant) { build(:participant) }
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }

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

  describe "#include?" do
    context "when an assignment team has one participant" do
      it "includes one participant" do
        participant.parent_id = team.parent_id
        Assignment.find(team.parent_id).add_participant(User.find(participant.user_id), true , true , true)
        expect(team.includes?(participant)).to eq true
      end
    end
  end
end
