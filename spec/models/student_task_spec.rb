require 'rails_helper'

describe StudentTask do
  let(:participant) { double("participant") }
  let(:user) { double("user") }
  let(:assignment) { double("assignment") }
  let(:student_task) { StudentTask.new(
    user: user,
    participant: participant,
    assignment: assignment
  )}

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
      expect(StudentTask).to receive :from_participant
      expect(AssignmentParticipant).to receive :find
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
      expect(student_task).to receive :stage_deadline
      student_task.complete?
    end
  end

  describe "#content_submitted_in_current_stage?" do
    it "checks the stage_deadline, resubmission times and hyperlinks" do
      expect(student_task).to receive(:current_stage).and_return ("submission")
      expect(participant).to receive(:resubmission_times).and_return []
      expect(student_task).to receive(:hyperlinks)
      student_task.content_submitted_in_current_stage?
    end
  end

  describe "#course" do
    it "delegates to assignment" do
      expect(assignment).to receive :course
      student_task.course
    end
  end
end
