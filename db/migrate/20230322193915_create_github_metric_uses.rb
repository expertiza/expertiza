class CreateGithubMetricUses < ActiveRecord::Migration[4.2]
  def change
    create_table :github_metric_uses do |t|
      t.integer :assignment_id
    end
    add_index :github_metric_uses, :id, unique: true
  end
end