class AddParticipantIdToQuizResponse < ActiveRecord::Migration[4.2]
  def self.up
    add_column :quiz_responses, :participant_id, :integer
  end

  def self.down
    remove_column :quiz_responses, :participant_id
  end
end
