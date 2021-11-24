class UpdateUseGithubMetric < ActiveRecord::Migration

  def change
    add_foreign_key :use_github_metrics, :assignments, column: :assignment_id
  end
end
