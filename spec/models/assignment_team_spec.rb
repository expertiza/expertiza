describe AssignmentTeam do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  # Write your mocked object here!
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'emma', fullname: 'emma bleu')) }
  let(:participant2) { build(:participant, id: 2) }
  let(:assignment) { build(:assignment) }
  let(:team) { build(:assignment_team) }
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: "") }

  describe "#includes?" do
    context "when participant list includes this participant" do
      it "returns true"
      expect(participants.includes?(participant)).to eq 1;
    end

    context "when participant list does not include this participant" do
      it "returns false"
      # Write your test here!
    end
  end

  describe "#parent_model" do
    it "returns 'Assignment'"
    # Write your test here!
  end

  describe ".parent_model" do
    context "when there is an assignment with this id" do
      it "returns corresponding assignment object"
      # Write your test here!
    end

    context "when there is no assignment with this id" do
      it "raises ActiveRecord::RecordNotFound exception"
      # Write your test here!
    end
  end

  describe ".fullname" do
    it "returns the name of the current assignment team"
    # Write your test here!
  end

  describe ".review_map_type" do
    it "returns 'ReviewResponseMap'"
    # Write your test here!
  end

  describe ".prototype" do
    it "returns a new assignment team"
    # Write your test here!
  end

  describe "#assign_reviewer" do
    context "when the assignment record cannot be found by the parent id of the current assignment team" do
      it "raises a customized exception"
      # Write your test here!
    end

    context "when the assignment record can be found by the parent id of the current assignment team" do
      it "create a new ReviewResponseMap"
      # Write your test here!
    end
  end

  describe "#reviewd_by?" do
    context "when one or more submissions of this assignment team were reviewed by this reviewer" do
      it "returns true"
      # Write your test here!
    end

    context "when no submission of this assignment team was reviewed by this reviewer" do
      it "returns false"
      # Write your test here!
    end
  end

  describe "#topic" do
    it "returns the topic id chosen by this team"
    # Write your test here!
  end

  describe "has_submissions?" do
    context "when current assignment team submitted files" do
      it "returns true"
      # Write your test here!
    end

    context "when current assignment team did not submit files but submitted hyperlinks" do
      it "returns true"
      # Write your test here!
    end

    context "when current assignment team did not submit either files or hyperlinks" do
      it "returns false"
      # Write your test here!
    end
  end

  describe "#participants" do
    it "returns participants of the current assignment team"
    # Write your test here!
  end

  describe "#delete" do
    context "when the current team is an assignment team" do
      it "deletes topic sign up record, team users, team node and the team itself"
      # Write your test here!
    end

    context "when the current team is not an assignment team" do
      it "deletes team users, team node and the team itself"
      # Write your test here!
    end
  end

  describe "#destroy" do
    it "deletes review response map records"
    # Write your test here!
  end

  describe ".get_first_member" do
    it "returns the first participant of current assignment team"
    # Write your test here!
  end

  describe "#submitted_files" do
    it "returns the submitted files of current assignment team"
    # Write your test here!
  end

  describe ".import" do
    context "when there is no assignment with this assignment id" do
      it "raises an ImportError"
      # Write your test here!
    end

    context "when there exists an assignment with this assignment id" do
      it "imports a csv file to form assignment teams"
      # Write your test here!
    end
  end

  describe ".export" do
    it "exports assignment teams to an array"
    # Write your test here!
  end

  describe "#copy" do
    it "copies the current assignment team and team members to a new course team"
    # Write your test here!
  end

  describe "#add_participant" do
    context "when there is no assignment participant mapping" do
      it "adds this user to the assignment"
      # Write your test here!
    end
  end

  describe "#scores" do
    it "returns a hash of scores that current assignment team has received for the questions"
    # Write your test here!
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
    it "returns all files in certain directory"
    # Write your test here!
  end

  describe "#submit_hyperlink" do
    context "when the hyperlink is empty" do
      it "raises an exception saying 'The hyperlink cannot be empty'"
      # Write your test here!
    end

    context "when the hyperlink is not empty" do
      context "when Expertiza is unable to get the response from pinging the hyperlink" do
        it "raises an exception with corresponding HTTP status code"
        # Write your test here!
      end

      context "when Expertiza is able to get the response from the hyperlink" do
        it "saves the hyperlink to submitted_hyperlinks field"
        # Write your test here!
      end
    end
  end

  describe "#remove_hyperlink" do
    it "removes the hyperlink from the submitted_hyperlinks field"
    # Write your test here!
  end

  describe ".team" do
    context "when the participant is nil" do
      it "returns nil"
      # Write your test here!
    end

    context "when there are not team users records" do
      it "returns nil"
      # Write your test here!
    end

    context "when the participant is not nil and there exist team users records" do
      it "returns the team given the participant"
      # Write your test here!
    end
  end

  describe ".export_fields" do
    it "exports the fields of the csv file"
    # Write your test here!
  end

  describe ".remove_team_by_id" do
    it "deletes a team geiven the team id"
    # Write your test here!
  end

  describe "#path" do
    it "returns the directory path of the assignment team"
    # Write your test here!
  end

  describe "#set_student_directory_num" do
    context "when there is no directory number for the assignment team" do
      it "sets a directory number for the assignment team"
      # Write your test here!
    end
  end

  describe "#received_any_peer_review?" do
    context "when there exist corresponding response maps" do
      it "returns true"
      # Write your test here!
    end

    context "when there does not exist corresponding response maps" do
      it "returns false"
      # Write your test here!
    end
  end
end
