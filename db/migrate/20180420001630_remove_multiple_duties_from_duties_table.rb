class RemoveMultipleDutiesFromDutiesTable < ActiveRecord::Migration
  def change
  	remove_column :duties, :allow_multiple_duties
  end
end
