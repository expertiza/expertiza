class AddTimestampsToResponseMaps < ActiveRecord::Migration
  def self.up
    add_column :response_maps, :created_at, :datetime
    add_column :response_maps, :updated_at, :datetime
  end

  def self.down
    remove_column :response_maps, :created_at
    remove_column :response_maps, :updated_at
  end
end
