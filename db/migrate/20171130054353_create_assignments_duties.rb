class CreateAssignmentsDuties < ActiveRecord::Migration
  def change
    create_table :assignments_duties do |t|
      t.integer :assignment_id, :null => false
      t.integer :duty_id, :null => false
      t.timestamps null: false
    end
  end
end
