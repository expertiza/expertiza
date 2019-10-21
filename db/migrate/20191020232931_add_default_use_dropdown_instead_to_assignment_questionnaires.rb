class AddDefaultUseDropdownInsteadToAssignmentQuestionnaires < ActiveRecord::Migration
  def change
  	change_column :assignment_questionnaires, :use_dropdown_instead, :boolean, default: false
  end
end
