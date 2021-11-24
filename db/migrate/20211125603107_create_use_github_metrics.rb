class CreateUseGithubMetrics < ActiveRecord::Migration
  def change
    create_table :use_github_metrics do |t|
      t.integer :assignment_id
    end
    add_index :use_github_metrics, :id, unique: true
  end
end
