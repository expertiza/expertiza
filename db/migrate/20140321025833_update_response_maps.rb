class UpdateResponseMaps < ActiveRecord::Migration[4.2]
  def self.up
    add_column :response_maps, :created_at, :datetime
    add_column :response_maps, :updated_at, :datetime
  end

  def self.down
    remove_column :courses, :created_at
    remove_column :courses, :updated_at
  end
end
