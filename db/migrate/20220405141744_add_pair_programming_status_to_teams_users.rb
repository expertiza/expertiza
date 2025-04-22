class AddPairProgrammingStatusToTeamsUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :teams_participants, :pair_programming_status, :string, limit: 1
  end
end
