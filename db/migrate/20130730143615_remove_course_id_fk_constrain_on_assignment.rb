class RemoveCourseIdFkConstrainOnAssignment < ActiveRecord::Migration
  def self.up
    execute  "alter table assignments drop foreign key fk_assignments_courses;"
    rescue
  end

  def self.down
    execute "ALTER TABLE `assignments`
             ADD CONSTRAINT `fk_assignments_courses`
             FOREIGN KEY (course_id) references courses(id)"
    rescue
  end
end