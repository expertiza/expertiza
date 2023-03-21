class RemoveCourseIdFkConstrainOnAssignment < ActiveRecord::Migration[4.2]
  def self.up
    execute 'alter table assignments drop foreign key fk_assignments_courses;'
  rescue StandardError
  end

  def self.down
    execute "ALTER TABLE `assignments`
             ADD CONSTRAINT `fk_assignments_courses`
             FOREIGN KEY (course_id) references courses(id)"
  rescue StandardError
  end
end
