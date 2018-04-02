class CreateGithubData < ActiveRecord::Migration
  def change
    create_table :github_data do |t|
      t.references :submission_record, index: true, foreign_key: true
      t.string :oid, limit: 255
      t.string :committer, limit: 255
      t.datetime :committed_date
      t.integer :additions, limit: 4
      t.integer :deletions, limit: 4
      t.integer :changed_files, limit: 4
      t.string :message, limit: 255

      t.timestamps null: false
    end
  end
end
