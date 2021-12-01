class UpdateGithubMetricUses < ActiveRecord::Migration

  def change
    add_foreign_key :github_metric_uses, :assignments, column: :assignment_id
  end
end
