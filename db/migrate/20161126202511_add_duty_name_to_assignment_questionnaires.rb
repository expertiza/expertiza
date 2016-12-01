class AddDutyNameToAssignmentQuestionnaires < ActiveRecord::Migration
  def change
    add_column :assignment_questionnaires, :duty_name, :string
  end
end
