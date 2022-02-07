class AddDutyIdToParticipants < ActiveRecord::Migration
  def change
    add_reference :participants, :duty, index: true, foreign_key: true
  end
end
