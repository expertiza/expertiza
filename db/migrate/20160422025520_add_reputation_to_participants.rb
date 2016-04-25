class AddReputationToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :Hamer, :float, default: 1
    add_column :participants, :Lauw, :float, default: 0
  end
end
