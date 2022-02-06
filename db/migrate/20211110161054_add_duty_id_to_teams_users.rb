class AddDutyIdToTeamsUsers < ActiveRecord::Migration
  def change
    add_reference :teams_users, :duty, index: true, foreign_key: true
  end
end
