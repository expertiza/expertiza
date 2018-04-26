class AddingDutyIdToAssignmentQuestionnaireTable < ActiveRecord::Migration
  def change
  	add_column :assignment_questionnaires ,:duty_id,:integer
  end
end
