class AlterAvailabilityFlag < ActiveRecord::Migration[4.2]
  def change
    change_column :assignments, :availability_flag, :boolean, default: 1
  end
end
