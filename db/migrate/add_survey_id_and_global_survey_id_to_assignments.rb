class AddSurveyIdandGlobalSurveyIdToAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :survey_id, :integer, :null => true
    add_column :assignments, :global_survey_id, :integer, :null => true
  end

  def self.down
  end
end
