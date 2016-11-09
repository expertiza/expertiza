class CreateSurveyDeployments < ActiveRecord::Migration
  def self.up
    create_table :survey_deployments do |t|
      # Note: Table name pluralized by convention.
      t.column :course_evaluation_id, :integer  # the course to which this survey pertains.
      t.column :start_date, :datetime  # the time when the survey was deployed
      t.column :end_date, :datetime  # time that the survey ended
      t.column :num_of_students, :integer # no. of students participating in the survey
      t.column :last_reminder, :datetime # last reminder date
  end

  def self.down
    drop_table :survey_deployments
  end
  end
end
