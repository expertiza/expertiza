class AddCalibrateToToResponseMaps < ActiveRecord::Migration[4.2]
  def change
    add_column :response_maps, :calibrate_to, :boolean, default: false
  end
end
