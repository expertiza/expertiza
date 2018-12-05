class AddCourseStaffToResponseMap < ActiveRecord::Migration
  def change
    add_column :response_maps, :course_staff, :bool, default: false 
  end
end
