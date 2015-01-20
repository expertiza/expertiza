class AddRoundToResponseMaps < ActiveRecord::Migration
  def self.up
    add_column "response_maps","round",:integer
  end

  def self.down
    remove_column "response_maps","round"
  end
end