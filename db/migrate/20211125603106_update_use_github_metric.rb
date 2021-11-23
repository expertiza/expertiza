class UpdateUseGithubMetric < ActiveRecord::Migration

  def change
    add_foreign_key :use_github_metrics, :assignments, column: :id
  end
end
