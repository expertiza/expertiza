class RemoveNumOfStudentsColumnFromSurveyDeployment < ActiveRecord::Migration
  def change
    remove_column :survey_deployments, :num_of_students, :int
  end
end
