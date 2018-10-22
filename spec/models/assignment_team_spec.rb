describe 'AssignmentTeam' do
  let(:team) { build(:assignment_team) }
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

  describe "#includes?" do
    let(:assignment) { build(:assignment, id: 1) }
    let(:team) { build(:assignment_team, parent_id: 1) }
    let(:user) { build(:student, id: 2) }
    let(:participant) { build(:participant, parent_id: 1, user_id: 2) }

    context "when an assignment team has one participant" do
      it "includes one participant" do
        assignment
        user
        expect(team.includes?(participant)).to eq true
      end
    end
  end
end
