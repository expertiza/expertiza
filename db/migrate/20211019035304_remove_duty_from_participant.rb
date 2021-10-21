class RemoveDutyFromParticipant < ActiveRecord::Migration
  def change
    remove_column :participants, :duty, :varchar
  end
end
