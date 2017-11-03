class AddDropdownToAssignmentQuestionnairesTable < ActiveRecord::Migration
  def self.up
  	add_column :assignment_questionnaires, :dropdown, :boolean, default: true
  end

  def self.down
  	remove_colmun :assignment_questionnaires, :dropdown
  end
end
