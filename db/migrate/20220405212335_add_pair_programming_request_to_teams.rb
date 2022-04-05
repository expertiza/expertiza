class AddPairProgrammingRequestToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :pair_programming_request, :boolean
  end
end
