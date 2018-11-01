describe Participant do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  let(:topic1) { build(:topic, topic_name: '') }
  let(:topic2) { build(:topic, topic_name: "topic_name") }
  let(:student) { build(:student, name: "John Smith", email: "sjohn@ncsu.edu", fullname: "Mr.John Smith") }
  let(:student1) { build(:student, name: "Alice") }
  let(:student2) { build(:student, name: "Bob") }
  let(:assignment) { build(:assignment, name: "assignment") }
  let(:participant) { build(:participant, user: student, assignment: assignment, can_review: false, handle: "nb") }
  let(:participant1) { build(:participant, user: student1) }
  let(:participant2) { build(:participant, user: student2) }
  let(:assignment_team) { build(:assignment_team, name: "ChinaNo1") }
  let(:team_user) { build(:team_user, team: assignment_team, user: student) }
  let(:response) { build(:response, response_map: response_map) }
  let(:response_map) { build(:review_response_map, assignment: assignment, reviewer: participant1, reviewee: assignment_team) }
  let(:questions) { build(:question) }
  let(:questionnaire) { build(:questionnaire) }

  describe "#team" do
    it "returns the first team of current user" do
      allow(TeamsUser).to receive(:find_by).with(user: student).and_return(team_user)
      expect(participant.team.name).to eq "ChinaNo1"
    end
  end

  describe "#responses" do
    it "returns all responses this participant received" do
      allow(participant).to receive(:response).and_return(response)
      expect(participant.responses).to eq []
    end
  end

  describe "#name" do
    it "returns the name of the user" do
      expect(participant.name).to eq "John Smith"
    end
  end

  describe "#fullname" do
    it "returns the full name of the user" do
      expect(participant.fullname).to eq "Mr.John Smith"
    end
  end

  describe "#able_to_review" do
    it "returns whether the current participant has permission to review others' work" do
      expect(participant.able_to_review).to be false
    end
  end

  describe "#email" do
    it "sends an assignment registration email to current user" do
      allow(User).to receive(:find_by).with(id: nil).and_return(student)
      allow(Assignment).to receive(:find_by).with(id: nil).and_return(assignment)
      expect(participant.email(12_345, 'homepage').subject).to eq "You have been registered as a participant in the Assignment assignment"
      expect(participant.email(12_345, 'homepage').to[0]).to eq "expertiza.development@gmail.com"
      expect(participant.email(12_345, 'homepage').from[0]).to eq "expertiza.development@gmail.com"
    end
  end

  describe "#topic_name" do
    context "when the topic is nil or the topic name is empty" do
      it "returns em dash (—)" do
        expect(participant.topic_name).to eq "<center>&#8212;</center>"
      end
    end

    context "when the topic is not nil and the topic name is not empty" do
      it "returns the topic name" do
        allow(participant).to receive(:topic).and_return(topic2)
        expect(participant.topic_name).to eq "topic_name"
      end
    end
  end

  describe ".sort_by_name" do
    it "returns sorted participants based on their user names" do
      expect(Participant.sort_by_name([participant1, participant2, participant]).collect {|p| p.user.name }).to eq ["Alice", "Bob", "John Smith"]
    end
  end

  describe "#scores" do
    context "when the round is nil" do
      it "uses questionnaire symbol as a hash key and populates the score hash" do
        allow(AssignmentQuestionnaire).to receive_message_chain(:find_by, :used_in_round).with(assignment_id: 1, questionnaire_id: 2)\
        .with(no_args).and_return(nil)
        allow(assignment).to receive(:questionnaires).and_return([questionnaire])
        allow(questionnaire).to receive(:get_assessments_for).with(participant).and_return(response)
        allow(Answer).to receive(:compute_scores).and_return(max: 10, min: 10, avg: 10)
        allow(assignment).to receive(:compute_total_score).with(any_args).and_return(10)
        expect(participant.scores(questions).inspect).to eq("{:participant=>#<AssignmentParticipant id: nil, can_submit: true, can_review: false, user_id: nil, parent_id: nil, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, type: \"AssignmentParticipant\", handle: \"nb\", time_stamp: nil, digital_signature: nil, duty: nil, can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, :review=>{:assessments=>#<Response id: nil, map_id: nil, additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, is_submitted: false>, :scores=>{:max=>10, :min=>10, :avg=>10}}, :total_score=>10}")
      end
    end

    context "when the round is not nil" do
      it "uses questionnaire symbol with round as hash key and populates the score hash" do
        allow(AssignmentQuestionnaire).to receive_message_chain(:find_by, :used_in_round).with(assignment_id: 1, questionnaire_id: 2)\
        .with(no_args).and_return(3)
        allow(assignment).to receive(:questionnaires).and_return([questionnaire])
        allow(questionnaire).to receive(:get_assessments_for).with(participant).and_return(response)
        allow(Answer).to receive(:compute_scores).and_return(max: 10, min: 10, avg: 10)
        expect(participant.scores(questions).inspect).to eq("{:participant=>#<AssignmentParticipant id: nil, can_submit: true, can_review: false, user_id: nil, parent_id: nil, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, type: \"AssignmentParticipant\", handle: \"nb\", time_stamp: nil, digital_signature: nil, duty: nil, can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, :review3=>{:assessments=>#<Response id: nil, map_id: nil, additional_comment: nil, created_at: nil, updated_at: nil, version_num: nil, round: 1, is_submitted: false>, :scores=>{:max=>10, :min=>10, :avg=>10}}, :total_score=>10}")
      end
    end
  end

  describe ".get_permissions" do
    context "when the current user is a participant" do
      it "returns a hash with value {can_submit: true, can_review: true, can_take_quiz: true}" do
        expect(Participant.get_permissions("participant")).to eq(can_submit: true, can_review: true, can_take_quiz: true)
      end
    end

    context "when the current user is a reader" do
      it "returns a hash with value {can_submit: false, can_review: true, can_take_quiz: true}" do
        expect(Participant.get_permissions("reader")).to eq(can_submit: false, can_review: true, can_take_quiz: true)
      end
    end

    context "when the current user is a submitter" do
      it "returns a hash with value {can_submit: true, can_review: false, can_take_quiz: false}" do
        expect(Participant.get_permissions("submitter")).to eq(can_submit: true, can_review: false, can_take_quiz: false)
      end
    end

    context "when the current user is a reviewer" do
      it "returns a hash with value {can_submit: false, can_review: true, can_take_quiz: false}" do
        expect(Participant.get_permissions("reviewer")).to eq(can_submit: false, can_review: true, can_take_quiz: false)
      end
    end
  end

  describe ".get_authorization" do
    context " when the current user is able to submit work, review others' work and take quizzes" do
      it "indicates the current user is a participant" do
        expect(Participant.get_authorization(true, true, true)).to eq "participant"
      end
    end

    context " when the current user is unable to submit work but is able to review others' work and take quizzes" do
      it "indicates the current user is a reader" do
        expect(Participant.get_authorization(false, true, true)).to eq "reader"
      end
    end

    context " when the current user is able to submit work but is unable to review others' work and take quizzes" do
      it "indicates the current user is a submitter" do
        expect(Participant.get_authorization(true, false, false)).to eq "submitter"
      end
    end

    context " when the current user is unable to submit work and take quizzes but is able to review others' work" do
      it "indicates the current user is a reviewer" do
        expect(Participant.get_authorization(false, true, false)).to eq "reviewer"
      end
    end
  end

  describe "#handle" do
    context "when the anonymized view is turn on" do
      it "always returns 'handle'" do
        allow(User).to receive(:anonymized_view?).with(nil).and_return(true)
        expect(participant.handle).to eq('handle')
      end
    end

    context "when the anonymized view is turn off" do
      it "returns the handle of current participant" do
        allow(User).to receive(:anonymized_view?).with(nil).and_return(false)
        expect(participant.handle).to eq("nb")
      end
    end
  end

  describe "#delete" do
    context "when force deleting the response maps related to current participant" do
      it "force deletes current participant, related response maps, teams, and team users" do
        allow(ResponseMap).to receive(:where).with("reviewee_id = ? or reviewer_id = ?", nil, nil).and_return([response_map])
        expect(participant.delete(true).handle).to eq 'nb'
      end
    end

    context "when not force deleting the response maps related to current participant" do
      context "when there are no related response maps to this participant and current participant did not join any teams" do
        it "force deletes current participant, related response maps, teams, and team users" do
          allow(ResponseMap).to receive(:where).with("reviewee_id = ? or reviewer_id = ?", nil, nil).and_return([])
          allow(participant).to receive(:team).and_return(nil)
          expect(participant.delete(false).handle).to eq 'nb'
        end
      end

      context "when there are some related response maps to this participant or current participant join one or more teams" do
        it "raises an exception saying 'Associations exist for this participant'" do
          allow(participant).to receive(:team).and_return(assignment_team)
          expect { participant.delete(false) }.to raise_error("Associations exist for this participant.")
        end
      end
    end
  end

  describe "#force_delete" do
    context "when current participant has already joined a team" do
      context "when the current participant is the only member in that team" do
        it "deletes that team and current participant" do
          allow(participant).to receive(:team).and_return(assignment_team)
          allow(participant).to receive_message_chain(:team, :teams_users, :length).and_return(1)
          expect(participant.force_delete([response_map]).handle).to eq 'nb'
        end
      end

      context "when the team has other team members" do
        it "removes the current participant from that team and deletes current participant" do
          allow(participant).to receive(:team).and_return(assignment_team)
          allow(participant).to receive_message_chain(:team, :teams_users, :length).and_return(3)
          allow(participant).to receive_message_chain(:team, :teams_users).and_return([student])
          expect(participant.force_delete([response_map]).handle).to eq 'nb'
        end
      end
    end

    context "when the current participant did not join a team" do
      it "deletes current participant directly" do
        allow(participant).to receive(:team).and_return(nil)
        expect(participant.force_delete([response_map]).handle).to eq 'nb'
      end
    end
  end
end

