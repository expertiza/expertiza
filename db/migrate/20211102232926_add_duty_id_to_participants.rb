class AddDutyIdToParticipants < ActiveRecord::Migration[4.2]
  def change
    add_reference :participants, :duty, index: true, foreign_key: true
  end
end
