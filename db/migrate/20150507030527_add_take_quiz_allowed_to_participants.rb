class AddTakeQuizAllowedToParticipants < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'participants', 'take_quiz_allowed', :boolean, default: true
  end

  def self.down
    remove_column 'participants', 'take_quiz_allowed'
  end
end
