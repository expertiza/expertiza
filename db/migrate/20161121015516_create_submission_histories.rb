class CreateSubmissionHistories < ActiveRecord::Migration
  def change
    create_table :submission_histories do |t|
      t.string :submitted_detail
      t.datetime :submitted_at
       t.string :type
      t.string :action
      t.references :team, index: true
      t.timestamps null: false
    end
  end
end
