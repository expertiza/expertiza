class AddPairProgrammingStatusToTeamsUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :teams_users, :pair_programming_status, :string, limit: 1
  end
end
