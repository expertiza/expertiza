class UpdateParticipantTypes < ActiveRecord::Migration[4.2]
  def self.up    
    add_column :participants, :type, :string

    begin
      execute "ALTER TABLE `participants`
             DROP FOREIGN KEY `fk_participant_assignments`"
    rescue StandardError
    end

    begin
      execute "ALTER TABLE `participants`
             DROP INDEX `fk_participant_assignments`"
    rescue StandardError
    end

    rename_column :participants, :assignment_id, :parent_id

    participants = Participant.all
    participants.each  do |participant|
      participant.type = 'AssignmentParticipant'
      participant.save
    end

    course_users = CoursesUsers.all
    course_users.each do |user|
      CourseParticipant.create(user_id: user.user_id, parent_id: user.course_id)
    end
    drop_table :courses_users
  end

  def self.down
    create_table :courses_users do |t|
      t.column :user_id, :integer
      t.column :course_id, :integer
      t.column :active, :boolean
    end

    course_users = CourseParticipant.all
    course_users.each do |user|
      CoursesUser.create(user_id: user.user_id, course_id: user.parent_id)
      user.destroy
    end

    rename_column :participants, :parent_id, :assignment_id
    remove_column :participants, :type
  end
end
