class AddParticipantIdToQuizResponse < ActiveRecord::Migration
  def self.up
    add_column :quiz_responses, :participant_id, :integer
  end

  def self.down
    remove_column :quiz_responses, :participant_id
  end
end
