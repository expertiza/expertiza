class AddCanMentorToParticipants < ActiveRecord::Migration[5.1]
  def change
    add_column :participants, :can_mentor, :boolean, default: false
  end
end
