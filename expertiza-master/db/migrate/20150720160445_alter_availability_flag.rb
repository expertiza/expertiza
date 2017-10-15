class AlterAvailabilityFlag < ActiveRecord::Migration
  def change
    change_column :assignments, :availability_flag, :boolean, :default => 1
  end
end
