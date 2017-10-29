class CreateGitData < ActiveRecord::Migration
  def change
    create_table :git_data do |t|
      t.integer :pull_request
      t.references :submission_record
      t.string :author
      t.integer :commits
      t.integer :files
      t.integer :additions
      t.integer :deletions
      t.integer :lines_modified
      t.datetime :date

      t.timestamps
    end
  end
end
