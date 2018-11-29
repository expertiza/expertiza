class AddSubmissionRecordToQuestionnaire < ActiveRecord::Migration
  def up
    add_reference :questionnaires, :submission_record, index: true
  end

  def down
    remove_reference :questionnaires, :submission_record, index: true
  end
end
