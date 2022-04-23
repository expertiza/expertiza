class AddKeyToTeamsUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :teams_users, :participants, index: true, foreign_key: true
  rescue StandardError
  end
end
