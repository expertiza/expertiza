class CorrectAssignmentIdInSubmissionRecordsTable < ActiveRecord::Migration
  def change
    SubmissionRecord.all.each do |record|
      next if record.assignment_id < 900
      participant_id = record.assignment_id
      record.assignment_id = AssignmentParticipant.find(participant_id).try(:parent_id)
      begin
        record.save
      rescue => e
        put e.message
      end
    end
  end
end
