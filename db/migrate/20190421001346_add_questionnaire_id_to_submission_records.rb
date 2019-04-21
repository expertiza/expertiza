class AddQuestionnaireIdToSubmissionRecords < ActiveRecord::Migration
  def change
    add_column :submission_records, :questionnaire_id, :int
  end
end
