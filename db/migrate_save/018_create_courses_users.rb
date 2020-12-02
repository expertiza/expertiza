class CreateCoursesUsers < ActiveRecord::Migration
  def self.up
    # This table is used as a mapping table associating users with courses,
    # but it also contains info as to whether a user has dropped a courses.
    # If it didn't, when a user dropped a courses, all his submitted work
    # would become inaccessible to PG.
    create_table :courses_users do |t|
      t.column :user_id, :integer
      t.column :course_id, :integer
      t.column :active, :boolean  # whether user is still actively enrolled in courses
    end
    execute "alter table courses_users
             add constraint fk_courses_users
             foreign key (user_id) references users(id)"
    execute "alter table courses_users
             add constraint fk_users_courses
             foreign key (course_id) references courses(id)"
  end

  def self.down
    drop_table :courses_users
  end
end
