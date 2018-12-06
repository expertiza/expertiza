require 'csv'

describe 'AssignmentTeam' do
  let(:assignment) { build(:assignment) }
  let(:team) { build(:assignment_team) }
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }

  let(:ass1) { build(:assignment, id: 1, name: 'test assignment_team') }
  let(:student1) { build(:student, id: 1, name: 'johns', fullname: 'johns franklin') }
  let(:student2) { build(:student, id: 2, name: 'kate', fullname: 'kate moss') }
  let(:par1) { build(:participant, id: 1, parent_id: 1, user_id: 1) }
  let(:par2) { build(:participant, id: 2, parent_id: 1, user_id: 2) }
  let(:team1) { build(:assignment_team, id: 1, parent_id: 1, name: "team1", submitted_hyperlinks: "http://example.com") }
  let(:team2) { build(:assignment_team, id: 2, parent_id: 1, name: "team2", submitted_hyperlinks: "") }
  let(:team3) { build(:assignment_team, id: 3, parent_id: 1, name: "team3", directory_num: 5) }
  let(:course1) { build(:course_team, id: 1, name: 'test assignment_team') }
  let(:reviews1) { build(:review_response_map, assignment_id: 1, reviewer_id: 1, reviewee_id: 2) }
  let(:reviews2) { build(:review_response_map, assignment_id: 1, reviewer_id: 2, reviewee_id: 1) }
  let(:questionnary1) { build(:questionnaire, id: 1) } 
  let(:question1) { build(:question, id: 1) } 

  describe "#submission" do
    context "when current teams submitted hyperlinks" do
      it "submitted hyperlinks" do
    	expect(team1.has_submissions?).to eq(true)
      end
      it "didn't submit hyperlinks" do
    	expect(team2.has_submissions?).to eq(false)
      end
    end
    context "when current teams submitted files" do
      it "returns false" do
    	expect(team2.has_submissions?).to eq(false)
      end
      it "returns true"	do
	allow(team2).to receive(:submitted_files).and_return([double(:File)])
        expect(team2.has_submissions?).to be true
      end
    end
    context "submitted files" do
      it '#not submitted_files' do
        expect(team3.submitted_files()).to eq([])
      end
      it '#has submitted_files' do
	allow(AssignmentTeam).to receive(:directory_num).and_return(1)
        expect(team3.submitted_files("public/team3/")).to eq([]) #????
      end
    end
  end

  describe "#participants" do
    context "no participants" do
      it '#participants' do
	expect(team1.participants).to eq([])
      end
    end 
    context "add participants" do
      it '#add participants' do
	expect(team1.add_participant(ass1.id, par1)).to be_instance_of(AssignmentParticipant) 
      end
      it '#1 participant' do
	allow(AssignmentTeam).to receive(:users).with(id: team1.id).and_return([par1, par2])
	expect(team1.participants).to eq([])
      end
    end 
  end

  describe "#delete and destroy" do
    context "delete" do
      it '#delete' do
        expect(team1.delete).to be_instance_of(AssignmentTeam)
      end
    end
    context "destroy" do
      it '#destroy' do
        expect(team1.destroy).to be_instance_of(AssignmentTeam)
      end
    end
  end

  describe "#members" do
    context "get_first_member" do
      it '#get_first_member' do
	allow(AssignmentTeam).to receive(:find_by).with(id: team1.id).and_return(team1)
	allow(team1).to receive(:participants).and_return([par1, par2])
	expect(AssignmentTeam.get_first_member(team1.id)).to eq(par1)
      end
      it '#switch_order' do
	allow(AssignmentTeam).to receive(:find_by).with(id: team1.id).and_return(team1)
	allow(team1).to receive(:participants).and_return([par2, par1])
	expect(AssignmentTeam.get_first_member(team1.id)).to eq(par2)
      end
    end
  end

  describe "#import and export" do
    context "import" do
      it '#import an nonexisting assignment id' do
	row = {
	  :teamname => "hello_world",
   	  :teammembers => ["johns", "kate"]
	}
	options = {:has_teamname => "true_first"}
    	expect{AssignmentTeam.import(row, 99999, options)}.to raise_error(ImportError)
      end
      it '#export' do
	options = {}
	csv = CSV.open("assignment_team_export.csv", "w")
	assignment_id = ass1.id
	allow(AssignmentTeam).to receive(:where).with(parent_id: assignment_id).and_return([team1, team2, team3])
	allow(TeamsUser).to receive(:where).and_return([par1, par2])
    	expect(AssignmentTeam.export(csv, assignment_id, options)).to be_instance_of(CSV)
      end
    end
  end

  describe "#copy" do
    context "copy" do
      it '#copy' do
	allow(TeamsUser).to receive(:where).with(team_id: team1.id).and_return([par1])
        expect(team1.copy(course1.id)).to eq([par1])
      end
    end
  end

  describe "#scores" do
    context "getting scores" do
      it '#scores' do
	allow(ass1).to receive(:questionnaires).and_return([questionnary1])
        expect(team1.scores(question1)[:total_score]).to eq(0)
      end
    end
  end

end
