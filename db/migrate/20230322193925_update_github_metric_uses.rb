class UpdateGithubMetricUses < ActiveRecord::Migration[4.2]

  def change
    add_foreign_key :github_metric_uses, :assignments, column: :assignment_id
  end
end