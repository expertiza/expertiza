class ModifyGithubMetricUsesForAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :use_github_metrics, :boolean, default: false
  end
end
