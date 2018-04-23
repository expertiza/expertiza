class CreateDutyAssignmentMapping < ActiveRecord::Migration
  def change
	    
  add_column :assignments_duty_mappings ,:duty_id,:integer
  add_column :assignments_duty_mappings ,:assignment_id,:integer
  end
end
