class CreateSubmissionrecords < ActiveRecord::Migration
  def change
    create_table :submissionrecords do |t|

      t.timestamps null: false
    end


  end
end
