class CreateGithubContributors < ActiveRecord::Migration
  def change
    create_table :github_contributors do |t|
      t.string :user_name
      t.string :github_id
      t.integer :total_commits
      t.integer :files_changed
      t.integer :lines_changed
      t.integer :lines_added
      t.integer :lines_removed
      t.integer :lines_persisted
      t.references :teams, index: true
      t.timestamp :week_timestamp
      t.timestamps null: false
    end

  end
end
