class AddCanMentorToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :can_mentor, :boolean, default: false 
  end
end
