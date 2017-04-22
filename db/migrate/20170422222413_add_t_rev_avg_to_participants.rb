class AddTRevAvgToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :t_rev_avg, :float, :default => -1
  end
end
