class LinkBadgesToCourses < ActiveRecord::Migration
  def change
  	rename_column :assignment_badges, :assignment_id, :course_id
  end
end
