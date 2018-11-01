require 'csv'
describe 'AssignmentTeam' do
  # let(:assignment) { build(:assignment) }
  # let(:team) { build(:assignment_team) }
  let(:team_without_submitted_hyperlinks) { build(:assignment_team) }
  let(:assignment_team) { build(:assignment_team, id: 1, parent_id: 1, name: "full name") }
  let(:assignment_team2) { build(:assignment_team, id: 2, parent_id: 2) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }
  let(:reviewer) { build(:participant, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, id: 1, team_id: 1, is_waitlisted: 0, topic_id: 1) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: reviewer, reviewee: assignment_team) }
  let(:user) { build(:student, id: 1, master_permission_granted: 0) }
  let(:participant1) { build(:participant, id: 2, user: user) }
  let(:participant2) { build(:participant, id: 3) }

  describe "#include" do
    context "when it contains a given participant" do
      it "returns true" do
        # AssignmentParticipant.create(parent_id: assignment.id, user_id: user.id, permission_granted: user.master_permission_granted)
        # expect(assignment_team.includes?(AssignmentParticipant.find_by(user_id: user.id, parent_id: assignment_team.parent_id))).to eq true
        allow(assignment_team).to receive(:add_participants).with(participant1)
        expect(assignment_team.includes?(participant1))
      end
    end

    context "when it does not contain a given participant" do
      it "returns false" do
        allow(assignment_team).to receive(:add_participants).with(participant1)
        expect(assignment_team.includes?(participant2))
      end
    end
  end

  describe "#parent_model" do
    it "returns Assignment as result" do
      expect(assignment_team.parent_model).to eq("Assignment")
    end
  end

  describe ".parent_model" do
    context "when it has correct parent id" do
      it "returns an assignemt" do
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        expect(AssignmentTeam.parent_model(1)).to eq(assignment)
      end
    end

    context "when it has wrong id" do
      it "raises an exception" do
        expect { AssignmentTeam.parent_model 2 }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe ".fullname" do
    it "returns the full name of assignment team" do
      expect(assignment_team.fullname).to eq("full name")
    end
  end

  describe ".review_map_type" do
    it "returns ReviewResponseMap as result" do
      expect(assignment_team.review_map_type).to eq("ReviewResponseMap")
    end
  end

  describe ".prototype" do
    it "returns an new instance of AssignmentTeam" do
      expect(AssignmentTeam.prototype).to be_instance_of(AssignmentTeam)
    end
  end

  describe "#assign_reviewer" do
    context "when the team has assignment" do
      it "returns an instance of ReviewResponseMap" do
        expect(assignment_team.assign_reviewer(reviewer)).to be_instance_of(ReviewResponseMap)
      end
    end

    context "when the assignment record can not be found" do
      it "returns an exception" do
        expect { assignment_team2.assign_reviewer(reviewer) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#reviewd_by?" do
    it "returns true" do
      allow(ReviewResponseMap).to receive(:where).\
        with('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?', 1, 1, 1).and_return([review_response_map])
      expect(assignment_team.reviewed_by?(reviewer)).to be true
    end
  end

  describe "#topic" do
    it "returns a topic id" do
      allow(SignedUpTeam).to receive(:find_by).with(team_id: 1, is_waitlisted: 0).and_return(signed_up_team)
      expect(assignment_team.topic).to eq(1)
    end
  end

  describe "#has_submissions?" do
    context "when the team has submitted hyperlinks" do
      it "returns true" do
        assignment_team.submitted_hyperlinks << ""
        expect(assignment_team.has_submissions?).to be true
      end
    end
  end
end

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
      it "returns true" do
        allow(team2).to receive(:submitted_files).and_return([double(:File)])
        expect(team2.has_submissions?).to be true
      end
    end
    context "submitted files" do
      it '#not submitted_files' do
        expect(team3.submitted_files).to eq([])
      end
      it '#has submitted_files' do
        allow(AssignmentTeam).to receive(:directory_num).and_return(1)
        expect(team3.submitted_files("public/team3/")).to eq([])
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
    end
    # context" when they switch_order" do
    #   it '#switch_order' do
    #     allow(AssignmentTeam).to receive(:find_by).with(id: team1.id).and_return(team1)
    #     allow(team1).to receive(:participants).and_return([par2, par1])
    #     expect(AssignmentTeam.get_first_member(team1.id)).to eq(par2)
    #   end
    # end
  end

  describe "#import and export" do
    context "import" do
      it '#import an nonexisting assignment id' do
        row = {teamname: "hello_world", teammembers: %w[johns kate]}
        options = {has_teamname: "true_first"}
        expect { AssignmentTeam.import(row, 99_999, options) }.to raise_error(ImportError)
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

describe AssignmentTeam do
  let(:assignment) { build(:assignment) }
  let(:assignment_team) { build(:assignment_team) }
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }
  let(:assignment_team1) { build(:assignment_team, directory_num: nil) }
  let(:participant) { build(:participant) }
  let(:team_user) { build(:team_user) }

  describe "#hyperlinks" do
    context "when current teams submitted hyperlinks" do
      it "returns the hyperlinks submitted by the team" do
        expect(assignment_team.hyperlinks).to eq(["https://www.expertiza.ncsu.edu"])
      end
    end

    context "when current teams did not submit hyperlinks" do
      it "returns an empty array" do
        expect(team_without_submitted_hyperlinks.hyperlinks).to eq([])
      end
    end
  end

  describe '#files' do
    before :each do
      @directory = "a"
      @files = ["b.txt", "c.java", "d.txt"]
      @files1 = ["b/c", "d/e"]
    end
    it "call the method in Dir" do
      expect(Dir).to receive(:[]).with(@directory + "/*").and_return(@files)
      assignment_team.files(@directory)
    end
  end

  describe '#submit_hyperlink' do
    context "when the hyperlink is empty" do
      it "raise excpetion" do
        expect { (assignment_team.submit_hyperlink "") }.to raise_error('The hyperlink cannot be empty!')
      end
    end
    context "the link does not start with http:// or https://" do
      context "the link is invalid" do
        before :each do
          @link = "htp.aa/.."
        end
        it "call the method on NET::HTTP" do
          expect(Net::HTTP).to receive(:get_response).with(URI(@link + 'http://'))
          assignment_team.submit_hyperlink(@link)
        end
        it "raise error" do
          allow(Net::HTTP).to receive(:get_response).with(URI(@link + 'http://')).and_return("402")
          expect { assignment_team.submit_hyperlink @link }.to raise_error('HTTP status code: 402')
        end
      end
    end
  end

  describe '#remove_hyperlink' do
    before :each do
      @hyperlink = "http://a.com"
    end
    it 'call the hyperlinks method' do
      expect(assignment_team).to receive(:hyperlinks).and_return(["https://www.expertiza.ncsu.edu"])
      assignment_team.remove_hyperlink(@hyperlink)
    end
  end

  describe '.team' do
    context 'when the participant is nil then this method will return nil' do
      it 'the participant is nil' do
        expect(AssignmentTeam.team(nil)).to eq(nil)
      end
    end
    context 'can find the participant' do
      it 'send the correct user_id to the TeamsUser.where method' do
        expect(TeamsUser).to receive(:where).with(user_id: participant.user_id).and_return([team_user])
        AssignmentTeam.team(participant)
      end
      context 'the team user exists' do
        before :each do
          allow(TeamsUser).to receive(:where).with(user_id: 1).and_return([team_user])
          AssignmentTeam.team(participant)
        end
      end
    end
  end

  describe '#export_fields' do
    it 'the team_name equals false' do
      options = {team_name: "false"}
      expect(AssignmentTeam.export_fields(options)).to eq(["Team Name", "Team members", "Assignment Name"])
    end
    it 'the team_name equals true' do
      options = {team_name: "true"}
      expect(AssignmentTeam.export_fields(options)).to eq(["Team Name", "Assignment Name"])
    end
  end

  describe '#remove_team_by_id' do
    it 'send find to Assignment' do
      expect(AssignmentTeam).to receive(:find).with(1)
      AssignmentTeam.remove_team_by_id(1)
    end
  end

  describe '#path' do
    it 'can get the path' do
      expect(assignment_team.path).to eq(Rails.root.to_s + '/pg_data/instructor6/csc517/test/final_test/0')
      assignment_team.path
    end
  end

  describe '#set_student_directory_num' do
    context 'directory_num >= 0' do
      it 'return when num>=0' do
        expect(assignment_team.set_student_directory_num).to eq(nil)
      end
    end
    context 'the directory_num does not exist' do
      it 'get max num' do
        expect(AssignmentTeam).to receive_message_chain(:where, :order, :first, :directory_num).\
          with(parent_id: assignment_team1.parent_id).with('directory_num desc').with(no_args).with(no_args).and_return(1)
        assignment_team1.set_student_directory_num
      end
      it 'update attribute' do
        allow(AssignmentTeam).to receive_message_chain(:where, :order, :first, :directory_num).\
          with(parent_id: assignment_team1.parent_id).with('directory_num desc').with(no_args).with(no_args).and_return(1)
        expect(assignment_team1).to receive(:update_attributes).with(directory_num: 2)
        assignment_team1.set_student_directory_num
      end
    end
  end

  describe '#received_any_peer_review?' do
    it 'send the request to where of the ResponseMap' do
      expect(ResponseMap).to receive(:where).with(reviewee_id: assignment_team.id, reviewed_object_id: assignment_team.parent_id).and_return([])
      assignment_team.received_any_peer_review?
    end
  end
end
