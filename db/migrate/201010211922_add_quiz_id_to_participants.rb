class AddQuizIdToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :quiz_id, :integer, :null => true  
  end

  def self.down
  end
end
