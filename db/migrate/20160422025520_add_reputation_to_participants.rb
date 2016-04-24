class AddReputationToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :Hamer, :decimal, default: 1
    add_column :participants, :Lauw, :decimal, default: 0
  end
end
