class CreateDuties < ActiveRecord::Migration
  def change
    create_table :duties do |t|
      t.integer :team_id
      t.integer :student_id
      t.string :duty
      t.integer :questionnaire_id
    end
  end
end
