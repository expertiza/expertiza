class CreateComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :comments do |t|
      t.column :participant_id, :integer, null: false
      t.column :private, :boolean, null: false
      t.column :comment, :text, null: false
    end

    participants = Participant.all
    participants.each do |participant|
      if participant.comments_to_student
        Comment.create(participant_id: participant.id,
                       private: false,
                       comment: participant.comments_to_student)
      end
      next unless participant.private_instructor_comments

      Comment.create(participant_id: participant.id,
                     private: true,
                     comment: participant.private_instructor_comments)
    end

    remove_column :participants, 'comments_to_student'
    remove_column :participants, 'private_instructor_comments'
  end

  def self.down
    add_column :participants, :comments_to_student, :text
    add_column :participants, :private_instructor_comments, :text

    comments = Comment.all
    comments.each do |item|
      participant = Participant.find(item.participant_id)
      if item.private
        participant.private_instructor_comments = item.comment
      else
        participant.comments_to_student = item.comment
      end
    end
    drop_table :comments
  end
end
