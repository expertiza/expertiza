describe AssignmentTeam do
  
  let(:user) { User.new(id: 1) }
  let(:assignment_team) { build(:assignment_team, id: 2, parent_id: 2, name: "team2", users: [user], submitted_hyperlinks: "https://www.1.ncsu.edu") }
  let(:assignment_team1) { build(:assignment_team, id: 1, parent_id: 1, name: "team1", submitted_hyperlinks: "") }
  let(:questions) { { QuizQuestionnaire: double(:question) } }
  let(:questionnaire) { build(:questionnaire) }
  let(:assignment) { build(:assignment, id: 1, questionnaires: [questionnaire], name: 'Test Assgt') }
  let(:courseTeam) { build(:course_team, id: 1) }
  let(:team) { build(:assignment_team) }
  let(:team_user) { build(:team_user) }
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }
  let(:participant1) { build(:participant, id: 1, user: build(:student, id: 1, name: 'no name', fullname: 'no one')) }
  let(:participant2) { build(:participant, id: 2) }
  let(:review_response_map) { build(:review_response_map, id: 1, assignment: assignment, reviewer: participant1, reviewee: assignment_team1) }
  let(:signed_up_team) { build(:signed_up_team, id: 1, team_id: 1, is_waitlisted: 0, topic_id: 1) }

  describe "#includes?" do
    context "when participant list includes this participant" do
      it "returns true if the participants is in the list" do
        participants = [participant1]
        allow(assignment_team).to receive(:participants).and_return(participants)
        allow(participants).to receive(:include?).with(participant1).and_return(true)
        expect(assignment_team.includes?(participant1)).to eq(true)
      end
    end
    context "when participant list does not include this participant" do
      it "returns false if the participant is not in the list" do
        allow(assignment_team.participants).to receive(:include?).with(participant2).and_return(false)
        expect(assignment_team.includes?(participant2)).to eq(false)
      end
    end
  end

  describe "#parent_model" do
    it "returns 'Assignment'" do
      expect(assignment_team.parent_model).to eq("Assignment")
    end
  end

  describe ".parent_model" do
    context "when there is an assignment with this id" do
      it "returns corresponding assignment object" do
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        expect(AssignmentTeam.parent_model(1)).to eq(assignment)
      end
    end
    context "when there is no assignment with this id" do
      it "raises ActiveRecord::RecordNotFound exception" do
        expect{ AssignmentTeam.parent_model(1) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe ".fullname" do
    it "returns the name of the current assignment team" do
      expect(assignment_team.fullname).to eq("team2")
    end
  end

  describe ".review_map_type" do
    it "returns 'ReviewResponseMap'" do
      expect(assignment_team.review_map_type).to eq("ReviewResponseMap")
    end
  end

  describe ".prototype" do
    it "returns a new assignment team" do
      expect(AssignmentTeam.prototype).to be_instance_of(AssignmentTeam)
    end
  end

  describe "#assign_reviewer" do
    context "when the assignment record cannot be found by the parent id of the current assignment team" do
      it "raises a customized exception" do
        expect{ assignment_team.assign_reviewer(participant2) }.to raise_exception("The assignment cannot be found.")
      end
    end

    context "when the assignment record can be found by the parent id of the current assignment team" do
      it "create a new ReviewResponseMap" do
        expect(assignment_team1.assign_reviewer(participant1)).to be_instance_of(ReviewResponseMap)
      end
    end
  end

  describe "#reviewd_by?" do
    context "when one or more submissions of this assignment team were reviewed by this reviewer" do
      it "returns true" do
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',
                                                         1, 1, 1).and_return([review_response_map])
        expect(assignment_team1.reviewed_by?(participant1)).to be true
      end
    end

    context "when no submission of this assignment team was reviewed by this reviewer" do
      it "returns false" do
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?',
                                                         1, 1, 1).and_return([])
        expect(assignment_team1.reviewed_by?(participant1)).to be false
      end
    end
  end

  describe "#topic" do
    it "returns the topic id chosen by this team" do
      allow(SignedUpTeam).to receive(:find_by).with(team_id: 1, is_waitlisted: 0).and_return(signed_up_team)
      expect(assignment_team1.topic).to eq(1)
    end
  end

  describe "has_submissions?" do
    context "when current assignment team submitted files" do
      it "returns true" do
        allow(assignment_team1).to receive(:submitted_files).and_return([double(:File)])
        expect(assignment_team1.has_submissions?).to be true
      end
    end

    context "when current assignment team did not submit files but submitted hyperlinks" do
      it "returns true" do
        allow(assignment_team1).to receive(:submitted_hyperlinks).and_return([double(:Hyperlink)])
        expect(assignment_team1.has_submissions?).to be true
      end
    end
    context "when current assignment team did not submit either files or hyperlinks" do
      it "returns false" do
        expect(assignment_team1.has_submissions?).to be false
      end
    end
  end

  describe "#participants" do
    it "returns participants of the current assignment team" do
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: 2).and_return(participant2)
      expect(assignment_team.participants).to eq([participant2])
    end
  end

  describe "#delete" do
    context "when the current team is an assignment team" do
      it "deletes topic sign up record, team users, team node and the team itself"
    end

    context "when the current team is not an assignment team" do
      it "deletes team users, team node and the team itself" do
        expect(assignment_team.delete).to eq(assignment_team)
      end
    end
  end

  describe "#destroy" do
    it "deletes review response map records"
  end

  describe ".get_first_member" do
    it "returns the first participant of current assignment team" do
      allow(AssignmentTeam).to receive_message_chain(:find_by, :try, :try).with(id: 1).with(:participants).with(:first).and_return(participant1)
      expect(AssignmentTeam.get_first_member(1)).to eq(participant1)
    end
  end

  describe "#submitted_files" do
    it "returns the submitted files of current assignment team"
  end

  describe ".import" do
    context "when there is no assignment with this assignment id" do
      it "raises an ImportError" do
        allow(Assignment).to receive(:find_by).with(id: 1).and_return(nil)
        expect{ AssignmentTeam.import([], 1, {has_column_names: 'false' })}.to raise_error(ImportError, "The assignment with the id \"1\" was not found. <a href='/assignment/new'>Create</a> this assignment?")
      end
    end

    context "when there exists an assignment with this assignment id" do
      it "imports a csv file to form assignment teams" do
        allow(Assignment).to receive(:find_by).with(id: 2).and_return(double("Assignment", id: 2))
        allow(AssignmentTeam).to receive(:prototype).and_return(assignment_team)
        allow(Team).to receive(:import).with([], 2, {}, assignment_team).and_return(true)
        expect(AssignmentTeam.import([], 2, {})).to eq(true)
      end
    end
  end

  describe ".export" do
    it "exports assignment teams to an array" do
      allow(AssignmentTeam).to receive(:prototype).and_return(assignment_team)
      allow(Team).to receive(:export).with([], 2, {team_name: 'false'}, assignment_team).and_return([["no team"], ["no name"]])
      expect(AssignmentTeam.export([], 2, {team_name: 'false'})).to eq([["no team"], ["no name"]])
    end
  end

  describe "#copy" do
    it "copies the current assignment team and team members to a new course team" do
      allow(CourseTeam).to receive(:create_team_and_node).with(1).and_return(courseTeam)
      allow(Team).to receive(:copy_members).with(courseTeam).and_return([])
      expect(assignment_team.copy(1)).to eq([])
    end
  end

  describe "#add_participant" do
    context "when there is no assignment participant mapping" do
      it "adds this user to the assignment" do
        allow(AssignmentParticipant).to receive(:find_by).with(parent_id: 1, user_id: user.id).and_return(nil)
        expect(assignment_team.add_participant(1, user)).to be_instance_of(AssignmentParticipant)
      end
    end
  end

  describe "#scores" do
    it "returns a hash of scores that current assignment team has received for the questions" do
      allow(assignment_team).to receive(:assignment).and_return(assignment)
      allow(ReviewResponseMap).to receive(:where).with(reviewee_id: 2).and_return(review_response_map)
      allow(Answer).to receive(:compute_scores).with(review_response_map, questions[QuizQuestionnaire]).and_return(10)
      allow(assignment).to receive(:compute_total_score).and_return(10)
      # expect(assignment_team.scores(questions)[:QuizQuestionnaire]).equal?({assessments: review_response_map, scores: 10}).to be true
      expect(assignment_team.scores(questions)[:team]).to eq(assignment_team)
      expect(assignment_team.scores(questions)[:total_score]).to eq(10)
    end
  end

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

  describe "#files" do
    it "returns all files in certain directory" do
      expect(assignment_team1.files('./hooks')).to eq(["./hooks/pre-commit"])
    end
  end

  describe "#submit_hyperlink" do
    context "when the hyperlink is empty" do
      it "raises an exception saying 'The hyperlink cannot be empty'" do
        hyperlink = ''
        expect{ assignment_team1.submit_hyperlink(hyperlink) }.to raise_exception("The hyperlink cannot be empty!")
      end
    end

    context "when the hyperlink is not empty" do
      context "when Expertiza is unable to get the response from pinging the hyperlink" do
        it "raises an exception with corresponding HTTP status code"
      end

      context "when Expertiza is able to get the response from the hyperlink" do
        it "saves the hyperlink to submitted_hyperlinks field" do
          allow(Net::HTTP).to receive(:get_response).with(URI("https://www.expertiza.ncsu.edu"))
          allow(assignment_team1).to receive(:hyperlink).and_return([])
          expect(assignment_team1.submit_hyperlink("https://www.expertiza.ncsu.edu")).to eq(true)
          expect(assignment_team1.hyperlinks).to eq(["https://www.expertiza.ncsu.edu"])
        end
      end
    end
  end

  describe "#remove_hyperlink" do
    it "removes the hyperlink from the submitted_hyperlinks field" do
      allow(team).to receive(:hyperlinks).and_return(["https://www.expertiza.ncsu.edu"])
      expect(team.remove_hyperlink("https://www.expertiza.ncsu.edu")).to eq(true)
      expect(team.hyperlinks).to eq([])
    end
  end

  describe ".team" do
    context "when the participant is nil" do
      it "returns nil" do
        expect(AssignmentTeam.team(participant1)).to eq(nil)
      end
    end

    context "when there are not team users records" do
      it "returns nil" do
        allow(TeamsUser).to receive(:where).with(user_id: 1).and_return(nil)
        expect(AssignmentTeam.team(participant1)).to eq(nil)
      end
    end

    context "when the participant is not nil and there exist team users records" do
      it "returns the team given the participant" do
        allow(TeamsUser).to receive(:where).with(user_id: 1).and_return([team_user])
        allow(Team).to receive(:find).with(1).and_return(team)
        expect(AssignmentTeam.team(participant1)).to eq(team)
      end
    end
  end

  describe ".export_fields" do
    it "exports the fields of the csv file" do
      expect(AssignmentTeam.export_fields({team_name: 'false'})).to eq(["Team Name", "Team members", "Assignment Name"])
    end
  end

  describe ".remove_team_by_id" do
    it "deletes a team geiven the team id" do
      allow(AssignmentTeam).to receive(:find).with(1).and_return(assignment_team1)
      allow(assignment_team1).to receive(:destroy).and_return(assignment_team1)
      expect(AssignmentTeam.remove_team_by_id(1)).to eq(assignment_team1)
    end
  end

  describe "#path" do
    it "returns the directory path of the assignment team" do
      expect(assignment_team1.path).to match('pg_data/instructor6/csc517/test/final_test/0')
    end
  end

  describe "#set_student_directory_num" do
    context "when there is no directory number for the assignment team" do
      it "sets a directory number for the assignment team" do
        allow(AssignmentTeam).to receive(:where).with(parent_id: 1).and_return(4)
        allow(AssignmentTeam).to receive(:update_attributes).with(directory_num: 5)
        expect(assignment_team1.set_student_directory_num).to eq(nil)
      end
    end
  end

  describe "#received_any_peer_review?" do
    context "when there exist corresponding response maps" do
      it "returns true" do
        allow(ResponseMap).to receive(:where).with(reviewee_id: 1, reviewed_object_id: 1).and_return([double(:ResponseMap)])
        expect(assignment_team1.received_any_peer_review?).to be true
      end
    end

    context "when there does not exist corresponding response maps" do
      it "returns false" do
        allow(ResponseMap).to receive(:where).with(reviewee_id: 1, reviewed_object_id: 1).and_return([])
        expect(assignment_team1.received_any_peer_review?).to be false
      end
    end
  end
end




