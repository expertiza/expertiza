class DeletingDutyIdFromAssignmentQuestionnaireTable < ActiveRecord::Migration
  def change
  	
  	remove_column :assignment_questionnaires ,:duty_id
  end
end
