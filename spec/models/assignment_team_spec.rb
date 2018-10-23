describe 'AssignmentTeam' do
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }
  let(:team) { build(:assignment_team) }
  
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
        create(:assignment, id: 1)
        team = create(:assignment_team, id: 1, parent_id: 1)
        create(:student, id: 2)
        participant = create(:participant, parent_id: 1, user_id: 2)
        create(:team_user, id: 1, team_id: 1, user_id: 2)
        expect(team.includes?(participant)).to eq true
      end
    end
  end
end
