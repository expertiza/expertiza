class AddRoundToResponseMaps < ActiveRecord::Migration[4.2]
  def self.up
    add_column 'response_maps', 'round', :integer
  end

  def self.down
    remove_column 'response_maps', 'round', :integer
  end
end
