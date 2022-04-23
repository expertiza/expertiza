class AddKeyToTeamsUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :teams_users, :participant, index: true, foreign_key: true
  rescue StandardError
  end
end
