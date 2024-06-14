class DropRoundFieldFromResponseMaps < ActiveRecord::Migration[4.2]
  def change
    remove_column 'response_maps', 'round'
  end
end
