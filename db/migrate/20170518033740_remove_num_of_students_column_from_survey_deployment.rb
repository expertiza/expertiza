class RemoveNumOfStudentsColumnFromSurveyDeployment < ActiveRecord::Migration[4.2]
  def change
    remove_column :survey_deployments, :num_of_students, :int
  end
end
