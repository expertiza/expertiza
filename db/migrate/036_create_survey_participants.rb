class CreateSurveyParticipants < ActiveRecord::Migration
  def self.up
    create_table :survey_participants do |t|
      # Note: Table name pluralized by convention.
      t.column :user_id, :integer  # the user participating in the course evaluation.
      t.column :survey_deployment_id, :integer  # the survey deployment
    end
  end

  def self.down
    drop_table :survey_participants
  end
end
