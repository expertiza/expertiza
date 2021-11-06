class DropRoundFieldFromResponseMaps < ActiveRecord::Migration
  def change
    remove_column "response_maps","round"
  end
end
