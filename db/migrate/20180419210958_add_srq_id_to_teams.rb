class AddSrqIdToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :srq_id, :integer
  end
end
