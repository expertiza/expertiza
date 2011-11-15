class CreateCoursesUsers < ActiveRecord::Migration
  def self.up
  create_table "courses_users", :force => true do |t|
    t.column "user_id", :integer
    t.column "course_id", :integer
    t.column "active", :boolean
  end

  add_index "courses_users", ["user_id"], :name => "fk_courses_users"
  
  execute "alter table courses_users 
             add constraint fk_courses_users
             foreign key (user_id) references users(id)"
             
  add_index "courses_users", ["course_id"], :name => "fk_users_courses"
 
  execute "alter table courses_users 
             add constraint fk_users_courses
             foreign key (course_id) references courses(id)"
  
  end

  def self.down
    drop_table "courses_users"
  end
end
