class AddTRevAvgToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :t_rev_avg, :float, :default => -1
  end
end
