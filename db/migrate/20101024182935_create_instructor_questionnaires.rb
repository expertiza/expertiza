class CreateInstructorQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :instructor_questionnaires do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :instructor_questionnaires
  end
end
