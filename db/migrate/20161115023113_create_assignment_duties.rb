class CreateAssignmentDuties < ActiveRecord::Migration
  def change
    create_table :assignment_duties do |t|
      t.integer :assignment_id
      t.string  :duty_name
      t.integer :questionnaire_id
    end
  end
end
