class AddIsLockedToResponseMaps < ActiveRecord::Migration
  def change
    add_column :response_maps, :is_locked, :boolean, default: false, null: false
  end
end
