class AddVisibilityToResponseMaps < ActiveRecord::Migration
  def change
    add_column :response_maps, :visibility, :string, default: "private"
  end
end
