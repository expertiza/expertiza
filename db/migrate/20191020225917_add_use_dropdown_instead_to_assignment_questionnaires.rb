class AddUseDropdownInsteadToAssignmentQuestionnaires < ActiveRecord::Migration
  def change
  	add_column :assignment_questionnaires, :use_dropdown_instead, :boolean, default: false
  end
end
