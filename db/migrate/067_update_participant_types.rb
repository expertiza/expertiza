class UpdateParticipantTypes < ActiveRecord::Migration
  def self.up    
    add_column :participants, :type, :string
    
    begin
      execute "ALTER TABLE `participants` 
             DROP FOREIGN KEY `fk_participant_assignments`" 
    rescue  
    end
  
    begin
      execute "ALTER TABLE `participants` 
             DROP INDEX `fk_participant_assignments`"
    rescue
    end    
    
    rename_column :participants, :assignment_id, :parent_id
    
    participants = Participant.find(:all)
    participants.each{
      |participant|
      participant.type = 'AssignmentParticipant'
      participant.save
    }
    
    course_users = CoursesUsers.find(:all)
    course_users.each{
      |user|
      CourseParticipant.create(:user_id => user.user_id, :parent_id => user.course_id)
    }      
    drop_table :courses_users
  end

  def self.down
    create_table :courses_users do |t|
      t.column :user_id, :integer
      t.column :course_id, :integer
      t.column :active, :boolean
    end
    
    course_users = CourseParticipant.find(:all)
    course_users.each{
      |user|
      CoursesUser.create(:user_id => user.user_id, :course_id => user.parent_id)
      user.destroy
    }
    
    rename_column :participants, :parent_id, :assignment_id
    remove_column :participants, :type
  end
end
