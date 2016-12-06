class AddSurveyIdandGlobalSurveyIdToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :survey_id, :integer, :null => true
    add_column :courses, :global_survey_id, :integer, :null => true
  end

  def self.down
  end
end
