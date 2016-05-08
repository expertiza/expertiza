class AddReputationToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :Hamer, :float, default: 1
    add_column :participants, :Lauw, :float, default: 0
  end

  def self.down
  	remove_column :participants, :Lauw
  	remove_column :participants, :Hamer
  end
end
