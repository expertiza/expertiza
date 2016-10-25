class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
	t.column :title, :string
        t.column :instructor_id, :int
	t.column :directory_path, :string # the directory for this course; all assgts. will be in subdirectories of this
	t.column :info, :text  # this is used to hold semester, section #, etc., anything the instructor wants
    end

    execute "alter table courses 
             add constraint fk_course_users
             foreign key (instructor_id) references users(id)"
  end

  def self.down
    drop_table :courses
  end
end
