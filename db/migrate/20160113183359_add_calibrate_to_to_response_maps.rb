class AddCalibrateToToResponseMaps < ActiveRecord::Migration
  def change
    add_column :response_maps, :calibrate_to, :boolean, default: false
  end
end
