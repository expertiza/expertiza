class AddLockedByToResponseMaps < ActiveRecord::Migration
  def change
    add_column :response_maps, :locked_by, :integer, limit: 4, default: 0, null: false
  end
end
