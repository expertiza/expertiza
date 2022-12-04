class UpdateParticipants < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'participants', 'grade', :float
    add_column 'participants', 'comments_to_student', :text
    add_column 'participants', 'private_instructor_comments', :text
  end

  def self.down
    remove_column 'participants', 'grade'
    remove_column 'participants', 'comments_to_student'
    remove_column 'participants', 'private_instructor_comments'
  end
end
