class AddDutyIdToTeamsUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :teams_users, :duty, index: true, foreign_key: true
  end
end
