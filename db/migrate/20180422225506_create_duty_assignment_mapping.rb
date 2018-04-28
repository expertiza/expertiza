class CreateDutyAssignmentMapping < ActiveRecord::Migration
  def change
	    
	 create_table :assignments_duty_mappings do |t|
		 t.timestamps null: false
	end
  end
end