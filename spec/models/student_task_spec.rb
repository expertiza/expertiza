require 'rails_helper'

describe StudentTask do
  let(:participant) { Participant.new }
  let(:user) { User.new }
  let(:assignment) { Assignment.new }
  let(:student_task) do
    StudentTask.new(
      user: user,
      participant: participant,
      assignment: assignment
    )
  end

  def init
      team = build(:assignment_team)
      team.save!
      user = User.new
      user.email = "test@test.com"
      user.name = "user1"
      user.teams << team
      user.parent_id = team.parent_id
      user.save!
      participant = AssignmentParticipant.new
      participant.user_id = user.id
      participant.parent_id = user.parent_id
      participant.handle="testHandle"
      participant.save!

      new_user = Student.new
      new_user.email = "newtest@test.com"
      new_user.name = "user2"
      new_user.fullname = "User2 FullName"
      new_user.teams << team
      new_user.parent_id = team.parent_id
      new_user.save!

      participant = AssignmentParticipant.new
      participant.user_id = new_user.id
      participant.parent_id = new_user.parent_id
      participant.handle="testHandle"
      participant.save!
      return new_user,user
  end

  describe ".from_participant" do
    it "creates a StudentTask from a participant" do
      expect(participant).to receive(:assignment)
      expect(participant).to receive(:topic)
      expect(participant).to receive(:current_stage)
      expect(participant).to receive(:stage_deadline)
      expect(StudentTask.from_participant(participant).participant).to be participant
    end
  end

  describe ".from_participant_id" do
    it "creates a StudentTask from a participant id" do
      expect(StudentTask).to receive(:from_participant)
      expect(AssignmentParticipant).to receive(:find)
      StudentTask.from_participant_id 0
    end
  end

  describe ".from_user" do
    it "creates StudentTasks from a user" do
      expect(user).to receive(:assignment_participants).and_return [participant]
      expect(StudentTask).to receive(:from_participant).and_return student_task
      expect(student_task).to receive(:stage_deadline)
      StudentTask.from_user(user)
    end
  end

  describe "#topic_name" do
    it "delegates topic_name to topic" do
      expect(student_task).to receive :topic
      expect(student_task.topic_name).to eq '-'
    end
  end

  describe "#complete?" do
    it "checks the stage_deadline" do
      expect(student_task).to receive(:stage_deadline)
      student_task.complete?
    end
  end

  describe "#content_submitted_in_current_stage?" do
    it "checks the stage_deadline, resubmission times and hyperlinks" do
      expect(student_task).to receive(:current_stage).and_return "submission"
      expect(student_task).to receive(:hyperlinks)
      student_task.content_submitted_in_current_stage?
    end
  end

  describe "#course" do
    it "delegates to assignment" do
      expect(assignment).to receive(:course)
      student_task.course
    end
  end

  describe "Get teamed students" do
    it "Tests if team history is empty if the user have not teamed up before" do
      user = User.new
      expect(StudentTask.teamed_students user).to eq ({})
    end

    it "Tests if the team history is empty if the user only has course team" do
      team = CourseTeam.new
      team.save!
      user = User.new
      user.email = "test@test.com"
      user.name = "user1"
      user.teams << team
      user.save!
      expect(StudentTask.teamed_students user).to eq ({})
    end

    it "Tests if the team history is empty if the user has assignment team
        and no teammates" do
      team = build(:assignment_team)
      team.save!
      user = User.new
      user.email = "test@test.com"
      user.name = "user1"
      user.teams << team
      user.parent_id = team.parent_id
      user.save!
      participant = AssignmentParticipant.new
      participant.user_id = user.id
      participant.parent_id = user.parent_id
      participant.handle="testHandle"
      participant.save!
      expect(StudentTask.teamed_students user).to eq ({})
    end

    it "Tests if the team history is correct if the user has assignment team
        and one team mate. The name is expected to be returned" do
      new_user,user = init
      returnVal = StudentTask.teamed_students user
      expect(returnVal[1]).to eq ([new_user.fullname])
    end

    it "Tests if the team history is correct if the user has assignment team
        and one team mate. The id is expected to be returned" do
      new_user,user = init
      returnVal = StudentTask.teamed_students user,nil,false
      expect(returnVal[1]).to eq ([new_user.id])
    end

    it "Tests if the team history is empty if the user has assignment team
        and one team mate but the assignment id is passed to be excluded" do
      new_user,user = init
      assignment = Assignment.find(user.parent_id)
      returnVal = StudentTask.teamed_students user,nil,false,assignment.id
      expect(returnVal).to eq ({})
    end

    it "Tests if the team history is empty if the user has assignment team
        and one team mate and the assignment id is passed to be included" do
      new_user,user = init
      assignment = Assignment.find(user.parent_id)
      returnVal = StudentTask.teamed_students user,nil,false,nil,assignment.id
      expect(returnVal[1]).to eq ([new_user.id])
    end
  end
end
