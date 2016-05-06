class CreateGlobalSurveyMaps < ActiveRecord::Migration
  def self.up
    begin
    drop_table :global_survey_maps
    rescue
    end
    create_table :global_survey_maps do |t|
      t.column :courses_id, :integer, :null => true
      t.column :surveys_id, :integer, :null => true
      t.column :global_surveys_id, :integer, :null => true      
    end
   
  end

  def self.down
    drop_table :global_survey_maps
  end
end   

