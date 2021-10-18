class AddKeyToAssignmentQuestionnaires < ActiveRecord::Migration
  def change
    add_reference :assignment_questionnaires, :duty, foreign_key: true
  end
end
