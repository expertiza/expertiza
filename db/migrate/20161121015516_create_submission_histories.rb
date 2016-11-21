class CreateSubmissionHistories < ActiveRecord::Migration
  def change
    create_table :submission_histories do |t|

      t.timestamps null: false
    end
  end
end
