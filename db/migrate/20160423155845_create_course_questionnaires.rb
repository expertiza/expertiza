class CreateCourseQuestionnaires < ActiveRecord::Migration
  def self.up
    begin
    drop_table :course_questionnaires
    rescue
    end
    create_table :course_questionnaires do |t|
      t.column :course_id,        :integer, :null => true
      t.column :questionnaire_id,     :integer, :null => true
      t.column :user_id,              :integer, :null => true
      t.column :notification_limit,   :integer, :null => false, :default => 15
      t.column :questionnaire_weight, :integer, :null => false, :default => 0
    end
    
    execute 'ALTER TABLE `course_questionnaires`
             ADD CONSTRAINT fk_aq_user_id
             FOREIGN KEY (user_id) REFERENCES users(id)'
  
    
    execute 'ALTER TABLE `course_questionnaires`
             ADD CONSTRAINT fk_aq_courses_id
             FOREIGN KEY (course_id) REFERENCES courses(id)'
  
    
  end

  def self.down
    drop_table :course_questionnaires
  end
end   

