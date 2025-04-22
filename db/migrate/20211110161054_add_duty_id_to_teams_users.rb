class AddDutyIdToTeamsUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :teams_participants, :duty, index: true, foreign_key: true
  end
end
