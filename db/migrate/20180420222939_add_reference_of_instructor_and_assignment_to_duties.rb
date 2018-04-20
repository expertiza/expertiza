class AddReferenceOfInstructorAndAssignmentToDuties < ActiveRecord::Migration
  def change
  	add_reference :duties, :assignments
  end
end
