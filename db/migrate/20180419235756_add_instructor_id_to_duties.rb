class AddInstructorIdToDuties < ActiveRecord::Migration
  def change
  	add_column :duties, :instructor_id , :integer 
  end
end
