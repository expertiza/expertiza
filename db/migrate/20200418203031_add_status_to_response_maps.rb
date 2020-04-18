class AddStatusToResponseMaps < ActiveRecord::Migration
  def change
    add_column :response_maps, :status, :string
  end
end
